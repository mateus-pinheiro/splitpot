import '../../features/auth/data/repositories/mock_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/update_profile.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import 'di_container.dart';

/// Registra todas as dependências da aplicação no container.
///
/// Chamado uma única vez no bootstrap (main.dart).
void registerAppDependencies(DIContainer di) {
  // Auth — data
  di.registerLazySingleton<AuthRepository>(() => MockAuthRepository());

  // Auth — usecases
  di.registerFactory(() => SignInWithGoogle(di.get<AuthRepository>()));
  di.registerFactory(() => GetCurrentUser(di.get<AuthRepository>()));
  di.registerFactory(() => UpdateProfile(di.get<AuthRepository>()));
  di.registerFactory(() => SignOut(di.get<AuthRepository>()));

  // Auth — cubit (singleton porque é estado global de sessão)
  di.registerLazySingleton(
    () => AuthCubit(
      signInWithGoogle: di.get<SignInWithGoogle>(),
      getCurrentUser: di.get<GetCurrentUser>(),
      updateProfile: di.get<UpdateProfile>(),
      signOut: di.get<SignOut>(),
    ),
  );
}
