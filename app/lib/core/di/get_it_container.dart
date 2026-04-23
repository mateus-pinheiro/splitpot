import 'package:get_it/get_it.dart';

import 'di_container.dart';

class GetItContainer implements DIContainer {
  GetItContainer({GetIt? getIt}) : _getIt = getIt ?? GetIt.instance;

  final GetIt _getIt;

  @override
  void registerSingleton<T extends Object>(T instance) {
    _getIt.registerSingleton<T>(instance);
  }

  @override
  void registerLazySingleton<T extends Object>(T Function() factory) {
    _getIt.registerLazySingleton<T>(factory);
  }

  @override
  void registerFactory<T extends Object>(T Function() factory) {
    _getIt.registerFactory<T>(factory);
  }

  @override
  T get<T extends Object>() => _getIt.get<T>();

  @override
  bool isRegistered<T extends Object>() => _getIt.isRegistered<T>();

  @override
  Future<void> reset() => _getIt.reset();
}
