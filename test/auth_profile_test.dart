import 'package:craft_bay_app/core/network/api_client.dart';
import 'package:craft_bay_app/core/storage/auth_storage.dart';
import 'package:craft_bay_app/data/datasources/auth_remote_datasource.dart';
import 'package:craft_bay_app/data/repositories/auth_repository_impl.dart';
import 'package:craft_bay_app/presentation/state/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRemoteDataSource extends AuthRemoteDataSource {
  _FakeAuthRemoteDataSource() : super(ApiClient(AuthStorage()));

  Map<String, dynamic> profileData = {
    '_id': 'u1',
    'first_name': 'Rabbil',
    'last_name': 'Hasan',
    'email': 'rabbil@example.com',
    'phone': '01711111111',
    'city': 'Dhaka',
    'address': 'Mirpur 10',
    'avatar_url': null,
  };

  @override
  Future<dynamic> getProfile() async => {
        'code': 200,
        'status': 'success',
        'data': Map<String, dynamic>.from(profileData),
      };

  @override
  Future<dynamic> updateProfile(Map<String, dynamic> body) async {
    profileData = {...profileData, ...body};
    return {
      'code': 200,
      'status': 'success',
      'data': Map<String, dynamic>.from(profileData),
    };
  }
}

void main() {
  test('AuthState loads, updates, and clears profile on logout', () async {
    SharedPreferences.setMockInitialValues({'auth_token': 'jwt-token'});
    final storage = AuthStorage();
    await storage.init();

    final state = AuthState(
      AuthRepositoryImpl(_FakeAuthRemoteDataSource(), storage),
    );

    final loaded = await state.loadProfile();
    expect(loaded, isTrue);
    expect(state.profile?.fullName, 'Rabbil Hasan');
    expect(state.profile?.email, 'rabbil@example.com');
    expect(state.profile?.city, 'Dhaka');

    final updated = await state.updateProfile(
      firstName: 'Rabbil',
      lastName: 'Islam',
      phone: '01722222222',
      city: 'Chattogram',
      address: 'GEC Circle',
    );
    expect(updated, isTrue);
    expect(state.profile?.fullName, 'Rabbil Islam');
    expect(state.profile?.city, 'Chattogram');

    await state.logout();
    expect(state.profile, isNull);
    expect(storage.isLoggedIn, isFalse);
  });
}
