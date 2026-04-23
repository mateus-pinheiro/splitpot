/// Abstração da injeção de dependências.
///
/// O código da aplicação sempre consome esta interface — nunca o package
/// de DI diretamente (GetIt, Riverpod, injectable, etc.). Isso permite
/// trocar a implementação sem tocar em Cubits, usecases ou widgets.
abstract class DIContainer {
  void registerSingleton<T extends Object>(T instance);

  void registerLazySingleton<T extends Object>(T Function() factory);

  void registerFactory<T extends Object>(T Function() factory);

  T get<T extends Object>();

  bool isRegistered<T extends Object>();

  Future<void> reset();
}

/// Container globalmente acessível pela aplicação.
///
/// Inicializado uma única vez no bootstrap via [setAppDI]. Widgets e Cubits
/// leem dependências através de `appDI.get<T>()` em vez de depender do
/// package de DI diretamente.
late DIContainer _appDI;

DIContainer get appDI => _appDI;

void setAppDI(DIContainer di) {
  _appDI = di;
}
