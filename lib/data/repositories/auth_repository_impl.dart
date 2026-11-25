import '../../core/network/api_exception.dart';
import '../../core/storage/auth_storage.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/catalog_json_parser.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final AuthStorage _storage;

  @override
  Future<void> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String city,
    required String address,
  }) async {
    await _remote.signup({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'phone': phone,
      'city': city,
      'address': address,
    });
  }

  @override
  Future<void> login({required String email, required String password}) async {
    final body = await _remote.login(email, password);
    final token = _findToken(body);
    if (token == null) {
      throw const ApiException('Login failed: no token received from server.');
    }
    await _storage.saveToken(token);
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    await _remote.verifyOtp(email, otp);
  }

  @override
  Future<void> resendOtp(String email) async {
    await _remote.resendOtp(email);
  }

  @override
  Future<UserProfile> getProfile() async {
    final body = await _remote.getProfile();
    return _parseProfile(body);
  }

  @override
  Future<UserProfile> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String address,
  }) async {
    final body = await _remote.updateProfile({
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'city': city,
      'address': address,
    });
    return _parseProfile(body);
  }

  @override
  Future<void> logout() => _storage.clear();

  UserProfile _parseProfile(dynamic body) {
    final root = CatalogJsonParser.asMap(body);
    final data = CatalogJsonParser.asMap(root['data']);
    final nestedUser = data['user'] is Map
        ? CatalogJsonParser.asMap(data['user'])
        : data;

    return UserProfile(
      id: CatalogJsonParser.asString(nestedUser['_id']),
      firstName: CatalogJsonParser.asString(nestedUser['first_name']),
      lastName: CatalogJsonParser.asString(nestedUser['last_name']),
      email: CatalogJsonParser.asString(nestedUser['email']),
      phone: CatalogJsonParser.asString(nestedUser['phone']),
      city: CatalogJsonParser.asString(nestedUser['city']),
      address: CatalogJsonParser.asString(nestedUser['address']),
      avatarUrl: CatalogJsonParser.asNullableString(nestedUser['avatar_url']),
    );
  }

  // We don't know the exact response shape yet, so check the usual places.
  String? _findToken(dynamic body) {
    if (body is! Map) return null;

    final direct = body['token'] ?? body['access_token'];
    if (direct is String && direct.isNotEmpty) return direct;

    final data = body['data'];
    if (data is Map) {
      final nested = data['token'] ?? data['access_token'];
      if (nested is String && nested.isNotEmpty) return nested;
    }
    return null;
  }
}