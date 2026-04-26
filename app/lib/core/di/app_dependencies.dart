import 'package:splitpot/features/tables/domain/usecases/rejoin_table.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/services/firebase_rest_auth_service.dart';
import '../../features/auth/data/services/firebase_token_store.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/observe_sign_in_outcomes.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/update_profile.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/tables/data/repositories/participations_repository_impl.dart';
import '../../features/tables/data/repositories/tables_repository_impl.dart';
import '../../features/tables/domain/repositories/participations_repository.dart';
import '../../features/tables/domain/repositories/tables_repository.dart';
import '../../features/home/presentation/cubit/home_stats_cubit.dart';
import '../../features/tables/domain/usecases/add_buy_in.dart';
import '../../features/tables/domain/usecases/create_table.dart';
import '../../features/tables/domain/usecases/get_table.dart';
import '../../features/tables/domain/usecases/get_table_preview.dart';
import '../../features/tables/domain/usecases/get_user_stats.dart';
import '../../features/tables/domain/usecases/join_table.dart';
import '../../features/tables/domain/usecases/set_cash_out.dart';
import '../../features/tables/presentation/cubit/cashout_cubit.dart';
import '../../features/tables/presentation/cubit/create_table_cubit.dart';
import '../../features/tables/presentation/cubit/initial_buy_in_cubit.dart';
import '../../features/tables/presentation/cubit/join_by_id_cubit.dart';
import '../../features/tables/presentation/cubit/live_cubit.dart';
import '../../features/tables/presentation/cubit/qr_cubit.dart';
import '../../features/tables/presentation/cubit/rebuy_cubit.dart';
import '../../features/tables/presentation/cubit/table_detail_cubit.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/token_provider.dart';
import 'di_container.dart';

/// Registra todas as dependências da aplicação no container.
///
/// Chamado uma única vez no bootstrap (main.dart).
void registerAppDependencies(DIContainer di) {
  // Core
  di.registerSingleton<AppConfig>(AppConfig.fromEnvironment());
  di.registerSingleton<FirebaseTokenStore>(FirebaseTokenStore());
  di.registerSingleton<TokenProvider>(di.get<FirebaseTokenStore>());
  di.registerLazySingleton<ApiClient>(
    () => ApiClient(
      config: di.get<AppConfig>(),
      tokenProvider: di.get<TokenProvider>(),
    ),
  );
  di.registerLazySingleton<FirebaseRestAuthService>(
    () => FirebaseRestAuthService(config: di.get<AppConfig>()),
  );

  // Auth — data
  di.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      apiClient: di.get<ApiClient>(),
      firebaseService: di.get<FirebaseRestAuthService>(),
      tokenStore: di.get<FirebaseTokenStore>(),
    ),
  );

  // Auth — usecases
  di.registerFactory(() => SignInWithGoogle(di.get<AuthRepository>()));
  di.registerFactory(() => ObserveSignInOutcomes(di.get<AuthRepository>()));
  di.registerFactory(() => GetCurrentUser(di.get<AuthRepository>()));
  di.registerFactory(() => UpdateProfile(di.get<AuthRepository>()));
  di.registerFactory(() => SignOut(di.get<AuthRepository>()));

  // Auth — cubit (singleton: estado global de sessão)
  di.registerLazySingleton(
    () => AuthCubit(
      signInWithGoogle: di.get<SignInWithGoogle>(),
      observeSignInOutcomes: di.get<ObserveSignInOutcomes>(),
      getCurrentUser: di.get<GetCurrentUser>(),
      updateProfile: di.get<UpdateProfile>(),
      signOut: di.get<SignOut>(),
    ),
  );

  // Tables — data
  di.registerLazySingleton<TablesRepository>(
    () => TablesRepositoryImpl(di.get<ApiClient>()),
  );
  di.registerLazySingleton<ParticipationsRepository>(
    () => ParticipationsRepositoryImpl(di.get<ApiClient>()),
  );

  // Tables — usecases
  di.registerFactory(() => CreateTable(di.get<TablesRepository>()));
  di.registerFactory(() => GetTable(di.get<TablesRepository>()));
  di.registerFactory(() => GetTablePreview(di.get<TablesRepository>()));
  di.registerFactory(() => GetUserStats(di.get<TablesRepository>()));
  di.registerFactory(() => JoinTable(di.get<ParticipationsRepository>()));
  di.registerFactory(() => AddBuyIn(di.get<ParticipationsRepository>()));
  di.registerFactory(() => RejoinTable(di.get<ParticipationsRepository>()));
  di.registerFactory(() => SetCashOut(di.get<ParticipationsRepository>()));

  // Tables — cubits (factory: instância nova por view)
  di.registerFactory(() => CreateTableCubit(di.get<CreateTable>()));
  di.registerFactory(() => TableDetailCubit(di.get<GetTable>()));
  di.registerFactory(() => QrCubit(di.get<GetTable>()));
  di.registerFactory(() => LiveCubit(di.get<GetTable>()));
  di.registerFactory(
    () => RebuyCubit(
      addBuyIn: di.get<AddBuyIn>(),
      rejoinTable: di.get<RejoinTable>(),
    ),
  );
  di.registerFactory(
    () => InitialBuyInCubit(
      getTable: di.get<GetTable>(),
      addBuyIn: di.get<AddBuyIn>(),
    ),
  );
  di.registerFactory(() => HomeStatsCubit(di.get<GetUserStats>()));
  di.registerFactory(
    () => JoinByIdCubit(
      getTablePreview: di.get<GetTablePreview>(),
      joinTable: di.get<JoinTable>(),
    ),
  );
  di.registerFactory(
    () => CashoutCubit(
      getTable: di.get<GetTable>(),
      setCashOut: di.get<SetCashOut>(),
    ),
  );
}
