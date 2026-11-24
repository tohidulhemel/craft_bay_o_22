import '../core/network/api_client.dart';
import '../core/storage/auth_storage.dart';

// Holds the shared objects. Repositories and providers will be built
// from these in later steps.
class AppDependencies {
  AppDependencies._();

  static final AuthStorage authStorage = AuthStorage();
  static late final ApiClient apiClient;

  static Future<void> init() async {
    await authStorage.init();
    apiClient = ApiClient(authStorage);
  }
}