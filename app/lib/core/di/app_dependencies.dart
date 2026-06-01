import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/tables/data/repositories/repositories.dart';
import '../../features/tables/domain/repositories/repositories.dart';
import '../../features/tables/domain/usecases/usecases.dart';
import '../../features/tables/presentation/cubit/cubit.dart';
import '../../features/auth/data/services/services.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/usecases.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/home/presentation/cubit/home_stats_cubit.dart';
import '../config/app_config.dart';
import '../network/network.dart';
import 'di_container.dart';

/// Registra todas as dependências da aplicação no container.
///
/// Chamado uma única vez no bootstrap (main.dart).
void registerAppDependencies(DIContainer di) {
  // Core
  di.registerSingleton<AppConfig>(AppConfig.fromEnvironment());
  di.registerSingleton<FirebaseTokenStore>(FirebaseTokenStore());
  di.registerSingleton<TokenProvider>(di.get<FirebaseTokenStore>());
  di.registerSingleton<SessionExpiredNotifier>(SessionExpiredNotifier());
  di.registerLazySingleton<ApiClient>(
    () => ApiClient(
      config: di.get<AppConfig>(),
      tokenProvider: di.get<TokenProvider>(),
      sessionExpiredNotifier: di.get<SessionExpiredNotifier>(),
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
  di.registerFactory(() => ObserveSignInAttempts(di.get<AuthRepository>()));
  di.registerFactory(() => GetCurrentUser(di.get<AuthRepository>()));
  di.registerFactory(() => UpdateProfile(di.get<AuthRepository>()));
  di.registerFactory(() => SignOut(di.get<AuthRepository>()));

  // Auth — cubit (singleton: estado global de sessão)
  di.registerLazySingleton(
    () => AuthCubit(
      signInWithGoogle: di.get<SignInWithGoogle>(),
      observeSignInOutcomes: di.get<ObserveSignInOutcomes>(),
      observeSignInAttempts: di.get<ObserveSignInAttempts>(),
      getCurrentUser: di.get<GetCurrentUser>(),
      updateProfile: di.get<UpdateProfile>(),
      signOut: di.get<SignOut>(),
      sessionExpiredNotifier: di.get<SessionExpiredNotifier>(),
    ),
  );

  // Tables — data
  di.registerLazySingleton<TablesRepository>(
    () => TablesRepositoryImpl(di.get<ApiClient>()),
  );
  di.registerLazySingleton<ParticipationsRepository>(
    () => ParticipationsRepositoryImpl(di.get<ApiClient>()),
  );
  di.registerLazySingleton<SettlementsRepository>(
    () => SettlementsRepositoryImpl(di.get<ApiClient>()),
  );
  di.registerLazySingleton<ActionRequestsRepository>(
    () => ActionRequestsRepositoryImpl(di.get<ApiClient>()),
  );
  di.registerLazySingleton<UserSearchRepository>(
    () => UserSearchRepositoryImpl(di.get<ApiClient>()),
  );

  // Tables — usecases
  di.registerFactory(() => CreateTable(di.get<TablesRepository>()));
  di.registerFactory(() => GetTable(di.get<TablesRepository>()));
  di.registerFactory(() => GetTablePreview(di.get<TablesRepository>()));
  di.registerFactory(() => CloseTable(di.get<TablesRepository>()));
  di.registerFactory(() => ReconcileAndClose(di.get<TablesRepository>()));
  di.registerFactory(() => TransferHost(di.get<TablesRepository>()));
  di.registerFactory(() => GetUserStats(di.get<TablesRepository>()));
  di.registerFactory(() => JoinTable(di.get<ParticipationsRepository>()));
  di.registerFactory(() => AddBuyIn(di.get<ParticipationsRepository>()));
  di.registerFactory(() => RejoinTable(di.get<ParticipationsRepository>()));
  di.registerFactory(() => SetCashOut(di.get<ParticipationsRepository>()));
  di.registerFactory(
      () => AddGuestPlayer(di.get<ParticipationsRepository>()));
  di.registerFactory(
      () => AddRegisteredPlayer(di.get<ParticipationsRepository>()));
  di.registerFactory(() => UpdateBuyIn(di.get<ParticipationsRepository>()));
  di.registerFactory(() => RemoveBuyIn(di.get<ParticipationsRepository>()));
  di.registerFactory(() => LeaveTable(di.get<ParticipationsRepository>()));
  di.registerFactory(() => SearchUsers(di.get<UserSearchRepository>()));
  di.registerFactory(() => ListSettlements(di.get<SettlementsRepository>()));
  di.registerFactory(() => ConfirmSettlement(di.get<SettlementsRepository>()));
  di.registerFactory(
      () => ConfirmSettlementOnBehalf(di.get<SettlementsRepository>()));
  di.registerFactory(
      () => RequestAction(di.get<ActionRequestsRepository>()));
  di.registerFactory(
      () => ApproveActionRequest(di.get<ActionRequestsRepository>()));
  di.registerFactory(
      () => RejectActionRequest(di.get<ActionRequestsRepository>()));

  // Tables — cubits (factory: instância nova por view)
  di.registerFactory(() => CreateTableCubit(di.get<CreateTable>()));
  di.registerFactory(() => TableDetailCubit(di.get<GetTable>()));
  di.registerFactory(() => QrCubit(di.get<GetTable>()));
  di.registerFactory(() => LiveCubit(di.get<GetTable>()));
  di.registerFactory(
    () => RebuyCubit(
      addBuyIn: di.get<AddBuyIn>(),
      rejoinTable: di.get<RejoinTable>(),
      requestAction: di.get<RequestAction>(),
    ),
  );
  di.registerFactory(() => HomeStatsCubit(di.get<GetUserStats>(), di.get<ConfirmSettlement>()));
  di.registerFactory(
    () => JoinByIdCubit(
      getTablePreview: di.get<GetTablePreview>(),
      joinTable: di.get<JoinTable>(),
      requestAction: di.get<RequestAction>(),
    ),
  );
  di.registerFactory(
    () => CashoutCubit(
      getTable: di.get<GetTable>(),
      setCashOut: di.get<SetCashOut>(),
      requestAction: di.get<RequestAction>(),
    ),
  );
  di.registerFactory(
    () => PendingApprovalsCubit(
      approveActionRequest: di.get<ApproveActionRequest>(),
      rejectActionRequest: di.get<RejectActionRequest>(),
    ),
  );
  di.registerFactory(
    () => PixCubit(
      listSettlements: di.get<ListSettlements>(),
      confirmSettlement: di.get<ConfirmSettlement>(),
      confirmOnBehalf: di.get<ConfirmSettlementOnBehalf>(),
    ),
  );
  di.registerFactory(
    () => CheckTableCubit(
      getTable: di.get<GetTable>(),
      setCashOut: di.get<SetCashOut>(),
      closeTable: di.get<CloseTable>(),
      reconcileAndClose: di.get<ReconcileAndClose>(),
    ),
  );
  di.registerFactory(
    () => AddPlayerCubit(
      searchUsers: di.get<SearchUsers>(),
      addGuest: di.get<AddGuestPlayer>(),
      addRegistered: di.get<AddRegisteredPlayer>(),
    ),
  );
  di.registerFactory(
    () => EditBuyInsCubit(
      getTable: di.get<GetTable>(),
      updateBuyIn: di.get<UpdateBuyIn>(),
      removeBuyIn: di.get<RemoveBuyIn>(),
    ),
  );
}
