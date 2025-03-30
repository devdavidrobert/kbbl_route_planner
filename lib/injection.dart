// lib/injection.dart
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'core/network/api_client.dart';
import 'data/datasources/local/database_helper.dart';
import 'data/datasources/local/customer_local_data_source.dart';
import 'data/datasources/local/route_plan_local_data_source.dart';
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
import 'domain/usecases/enroll_customer.dart';
import 'domain/usecases/fetch_routes.dart';
import 'domain/usecases/create_route_plan.dart';
import 'domain/usecases/update_route_plan.dart';
import 'domain/usecases/place_order.dart';
import 'domain/usecases/track_stock.dart';
import 'domain/usecases/get_customer_performance.dart';
import 'domain/usecases/get_customers.dart';
import 'domain/usecases/login_use_case.dart';
import 'domain/usecases/logout_use_case.dart';
import 'domain/usecases/check_profile_use_case.dart';
import 'domain/usecases/create_profile_use_case.dart';
import 'domain/usecases/update_profile_use_case.dart';
import 'domain/usecases/fetch_orders_use_case.dart'; // Renamed to match Order entity
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/profile/profile_bloc.dart';
import 'presentation/blocs/route_plan/route_plan_bloc.dart';
import 'presentation/blocs/sales/sales_bloc.dart';

final sl = GetIt.instance;
bool _isInitialized = false;

Future<void> init() async {
  if (_isInitialized) return;

  // Core
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => DatabaseHelper());

  // Data Sources
  sl.registerLazySingleton<CustomerLocalDataSource>(
      () => CustomerLocalDataSource(sl()));
  sl.registerLazySingleton<RoutePlanLocalDataSource>(
      () => RoutePlanLocalDataSource(sl()));
  sl.registerLazySingleton<OrderLocalDataSource>(
      () => OrderLocalDataSource(sl()));
  sl.registerLazySingleton<StockLocalDataSource>(
      () => StockLocalDataSource(sl()));
  sl.registerLazySingleton<CustomerRemoteDataSource>(
      () => CustomerRemoteDataSource(sl()));
  sl.registerLazySingleton<RoutePlanRemoteDataSource>(
      () => RoutePlanRemoteDataSource(sl()));
  sl.registerLazySingleton<OrderRemoteDataSource>(
      () => OrderRemoteDataSource(sl()));
  sl.registerLazySingleton<StockRemoteDataSource>(
      () => StockRemoteDataSource(sl()));
  sl.registerLazySingleton<UserProfileRemoteDataSource>(
      () => UserProfileRemoteDataSource(sl()));
  sl.registerLazySingleton<SalesRemoteDataSource>(
      () => SalesRemoteDataSource(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  sl.registerLazySingleton<CustomerRepository>(() => CustomerRepositoryImpl(
        localDataSource: sl(),
        remoteDataSource: sl(),
        connectivity: sl(),
      ));
  sl.registerLazySingleton<RoutePlanRepository>(() => RoutePlanRepositoryImpl(
        localDataSource: sl(),
        remoteDataSource: sl(),
        connectivity: sl(),
      ));
  sl.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(
        localDataSource: sl(),
        remoteDataSource: sl(),
        connectivity: sl(),
      ));
  sl.registerLazySingleton<StockRepository>(() => StockRepositoryImpl(
        localDataSource: sl(),
        remoteDataSource: sl(),
        connectivity: sl(),
      ));

  sl.registerLazySingleton<UserProfileRepository>(
      () => UserProfileRepositoryImpl(
            remoteDataSource: sl(),
            connectivity: sl(),
          ));
  sl.registerLazySingleton<SalesRepository>(() => SalesRepositoryImpl(
        remoteDataSource: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => EnrollCustomer(sl()));
  sl.registerLazySingleton(() => FetchRoutes(sl()));
  sl.registerLazySingleton(() => CreateRoutePlan(sl()));
  sl.registerLazySingleton(() => UpdateRoutePlan(sl()));
  sl.registerLazySingleton(() => PlaceOrder(sl()));
  sl.registerLazySingleton(() => TrackStock(sl()));
  sl.registerLazySingleton(() => GetCustomerPerformance(sl(), sl()));
  sl.registerLazySingleton(() => GetCustomers(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckProfileUseCase(sl()));
  sl.registerLazySingleton(() => CreateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => FetchOrdersUseCase(sl())); // Renamed

  // Blocs
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        logoutUseCase: sl(),
        checkProfileUseCase: sl(),
        createProfileUseCase: sl(),
        updateProfileUseCase: sl(),
      ));
  sl.registerFactory(() => ProfileBloc(sl()));
  sl.registerFactory(() => RoutePlanBloc(
        fetchRoutes: sl(),
        createRoutePlan: sl(),
        updateRoutePlan: sl(),
      ));
  sl.registerFactory(() => SalesBloc(
        fetchOrdersUseCase: sl(),
        placeOrderUseCase: sl(),
        enrollCustomerUseCase: sl(),
      ));

  _isInitialized = true;
}
