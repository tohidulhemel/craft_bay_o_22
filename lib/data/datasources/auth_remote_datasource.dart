import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<dynamic> signup(Map<String, dynamic> body) =>
      _client.post(ApiEndpoints.signup, body: body);

  Future<dynamic> login(String email, String password) => _client.post(
        ApiEndpoints.login,
        body: {'email': email, 'password': password},
      );

  Future<dynamic> verifyOtp(String email, String otp) => _client.post(
        ApiEndpoints.verifyOtp,
        body: {'email': email, 'otp': otp},
      );

  Future<dynamic> resendOtp(String email) =>
      _client.post(ApiEndpoints.resendOtp, body: {'email': email});
}