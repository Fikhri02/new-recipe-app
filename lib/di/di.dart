import 'package:get_it/get_it.dart';
import '../services/api_service.dart';

final GetIt di = GetIt.instance;

Future<void> setupDependencies() async {
  di.registerLazySingleton<ApiService>(() => ApiService());
}
