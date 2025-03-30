// lib/injection.dart
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/network/api_client.dart';
import 'core/network/network_info.dart';
import 'core/helpers/database_helper.dart';
import 'core/constants/app_constants.dart';
import 'data/datasources/local/customer_local_data_source.dart';
import 'data/datasources/local/order_local_data_source.dart';
import 'data/datasources/local/stock_local_data_source.dart';
import 'data/datasources/remote/customer_remote_data_source.dart';
import 'data/datasources/remote/route_plan_remote_data_source.dart';
import 'data/datasources/remote/order_remote_data_source.dart';
import 'data/datasources/remote/sales_remote_data_source.dart';
import 'data/datasources/remote/stock_remote_data_source.dart';
import 'data/datasources/remote/user_profile_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/customer_repository_impl.dart';
import 'data/repositories/route_plan_repository_impl.dart';
import 'data/repositories/order_repository_impl.dart';
import 'data/repositories/sales_repository_impl.dart';
import 'data/repositories/stock_repository_impl.dart';
import 'data/repositories/user_profile_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/customer_repository.dart';
import 'domain/repositories/order_repository.dart';
import 'domain/repositories/route_plan_repository.dart';
import 'domain/repositories/sales_repository.dart';
import 'domain/repositories/stock_repository.dart';
import 'domain/repositories/user_profile_repository.dart';
import 'domain/usecases/fetch_routes.dart';
import 'domain/usecases/create_route_plan.dart';
import 'domain/usecases/update_route_plan.dart';
import 'domain/usecases/track_stock.dart';
import 'domain/usecases/get_customer_performance.dart';
import 'domain/usecases/get_customers.dart';
import 'domain/usecases/login_use_case.dart';
import 'domain/usecases/logout_use_case.dart';
import 'domain/usecases/check_profile_use_case.dart';
import 'domain/usecases/create_profile_use_case.dart';
import 'domain/usecases/update_profile_use_case.dart';
import 'domain/usecases/fetch_orders_use_case.dart';
import 'domain/usecases/fetch_sales_data_use_case.dart';
import 'domain/usecases/place_order.dart';
import 'domain/usecases/enroll_customer.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/profile/profile_bloc.dart';
import 'presentation/blocs/route_plan/route_plan_bloc.dart';
import 'presentation/blocs/sales/sales_bloc.dart';

final getIt = GetIt.instance;
bool _isInitialized = false;

Future<void> init() async {
  if (_isInitialized) return;

  // Configure logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {});

  final logger = Logger('DependencyInjection');
  logger.info('Initializing dependencies');

  // Core
  logger.info('Registering core dependencies');
  getIt.registerLazySingleton(() => Connectivity());
  getIt.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(getIt<Connectivity>()));
getIt.registerLazySingleton<ApiClient>(() => ApiClient(
      baseUrl: AppConstants.apiBaseUrl,
      client: http.Client(),
      logger: getIt<Logger>(),
    ));
getIt.registerLazySingleton<CustomerRepository>(() => CustomerRepositoryImpl(
      localDataSource: getIt(),
      remoteDataSource: getIt(),
      connectivity: getIt<Connectivity>(),
      logger: getIt<Logger>(),
    ));
  getIt.registerLazySingleton<Logger>(() => Logger('KBBLRoutePlanner'));
  getIt.registerLazySingleton(() => DatabaseHelper());

  // External
  logger.info('Registering external dependencies');
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => GoogleSignIn());

  // Data Sources
  logger.info('Registering data sources');
  getIt.registerLazySingleton<CustomerLocalDataSource>(
      () => CustomerLocalDataSource(getIt()));
  getIt.registerLazySingleton<CustomerRemoteDataSource>(
      () => CustomerRemoteDataSource(
            apiClient: getIt(),
            auth: getIt<FirebaseAuth>(),
          ));
  getIt.registerLazySingleton<OrderLocalDataSource>(
      () => OrderLocalDataSource(getIt()));
  getIt
      .registerLazySingleton<OrderRemoteDataSource>(() => OrderRemoteDataSource(
            apiClient: getIt(),
            auth: getIt<FirebaseAuth>(),
          ));
  getIt
      .registerLazySingleton<SalesRemoteDataSource>(() => SalesRemoteDataSource(
            apiClient: getIt(),
            auth: getIt<FirebaseAuth>(),
          ));
  getIt.registerLazySingleton<RoutePlanRemoteDataSource>(
      () => RoutePlanRemoteDataSource(
            apiClient: getIt(),
            auth: getIt<FirebaseAuth>(),
          ));
  getIt.registerLazySingleton<StockLocalDataSource>(
      () => StockLocalDataSource(getIt()));
  getIt.registerLazySingleton<StockRemoteDataSource>(
      () => StockRemoteDataSource(getIt<ApiClient>()));
  getIt.registerLazySingleton<UserProfileRemoteDataSource>(
    () => UserProfileRemoteDataSource(getIt()),
  );

  // Repositories
  logger.info('Registering repositories');
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: getIt(),
      userProfileRepository: getIt(),
      googleSignIn: getIt(),
    ),
  );
  getIt
      .registerLazySingleton<RoutePlanRepository>(() => RoutePlanRepositoryImpl(
            localDataSource: getIt(),
            remoteDataSource: getIt(),
            connectivity: getIt<Connectivity>(),
      ));
  getIt.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(
        localDataSource: getIt(),
        remoteDataSource: getIt(),
        connectivity: getIt<Connectivity>(),
      ));
  getIt.registerLazySingleton<StockRepository>(() => StockRepositoryImpl(
        localDataSource: getIt(),
        remoteDataSource: getIt(),
        connectivity: getIt<Connectivity>(),
      ));
  getIt.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(
      remoteDataSource: getIt(),
      connectivity: getIt<Connectivity>(),
    ),
  );
  getIt.registerLazySingleton<SalesRepository>(() => SalesRepositoryImpl(
        remoteDataSource: getIt(),
        connectivity: getIt<Connectivity>(),
      ));

  // Use Cases
  logger.info('Registering use cases');
  getIt.registerLazySingleton(() => FetchRoutes(getIt()));
  getIt.registerLazySingleton(() => CreateRoutePlan(getIt()));
  getIt.registerLazySingleton(() => UpdateRoutePlan(getIt()));
  getIt.registerLazySingleton(() => TrackStock(getIt()));
  getIt.registerLazySingleton(() => GetCustomerPerformance(getIt(), getIt()));
  getIt.registerLazySingleton(() => GetCustomers(getIt()));
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => CheckProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => FetchOrdersUseCase(getIt()));
  getIt.registerLazySingleton(() => FetchSalesDataUseCase(getIt()));
  getIt.registerLazySingleton(() => PlaceOrderUseCase(getIt()));
  getIt.registerLazySingleton(() => EnrollCustomerUseCase(getIt()));

  // Blocs
  logger.info('Registering BLoCs');
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt(),
      logoutUseCase: getIt(),
      checkProfileUseCase: getIt(),
      createProfileUseCase: getIt(),
      updateProfileUseCase: getIt(),
      authRepository: getIt(),
    ),
  );
  getIt.registerFactory(
    () => ProfileBloc(
      createProfileUseCase: getIt(),
      updateProfileUseCase: getIt(),
      checkProfileUseCase: getIt(),
    ),
  );
  getIt.registerFactory(() => RoutePlanBloc(
        fetchRoutes: getIt(),
        createRoutePlan: getIt(),
        updateRoutePlan: getIt(),
      ));
  getIt.registerFactory(() => SalesBloc(
        fetchOrdersUseCase: getIt(),
        placeOrderUseCase: getIt(),
        enrollCustomerUseCase: getIt(),
        fetchSalesDataUseCase: getIt(),
      ));

  _isInitialized = true;
  logger.info('Dependency injection completed');
}
