import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../app/app_constants.dart';
import '../storage/auth_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(this._authStorage);

  final AuthStorage _authStorage;

  Future<dynamic> get(String url, {Map<String, dynamic>? query}) =>
      _send('GET', url, query: query);

  Future<dynamic> post(String url, {Map<String, dynamic>? body}) =>
      _send('POST', url, body: body);

  Future<dynamic> patch(String url, {Map<String, dynamic>? body}) =>
      _send('PATCH', url, body: body);

  Future<dynamic> delete(String url) => _send('DELETE', url);

  Future<dynamic> _send(
    String method,
    String url, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
  }) async {
    // Build the URL, skipping null query values.
    final params = <String, String>{};
    query?.forEach((key, value) {
      if (value != null) params[key] = value.toString();
    });
    final uri = Uri.parse(url)
        .replace(queryParameters: params.isEmpty ? null : params);

    // This API reads the token from a header named "token".
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = _authStorage.token;
    if (token != null && token.isNotEmpty) {
      headers['token'] = token;
    }

    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);

      final response = await (() async {
        final streamed = await request.send();
        return http.Response.fromStream(streamed);
      })()
          .timeout(AppConstants.requestTimeout);

      if (kDebugMode) {
        debugPrint('[$method] $uri -> ${response.statusCode}');
      }

      final decoded = _decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      }
      throw ApiException(
        _extractMessage(decoded) ??
            'Something went wrong (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on http.ClientException {
      throw const ApiException('Could not reach the server.');
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond. Please try again.',
      );
    }
  }

  dynamic _decode(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  // The message keys are a guess. We will adjust them after seeing
  // the real error responses from this API.
  String? _extractMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      for (final key in ['message', 'error', 'msg']) {
        final value = decoded[key];
        if (value is String && value.isNotEmpty) return value;
      }
    }
    return null;
  }
}