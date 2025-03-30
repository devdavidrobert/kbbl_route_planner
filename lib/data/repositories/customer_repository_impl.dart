// lib/data/repositories/customer_repository_impl.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/local/customer_local_data_source.dart';
import '../datasources/remote/customer_remote_data_source.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDataSource localDataSource;
  final CustomerRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  CustomerRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  @override
  Future<List<Customer>> getCustomers(String userId) async {
    if (await connectivity.checkConnectivity() != ConnectivityResult.none) {
      final remoteCustomers = await remoteDataSource.getCustomers(userId);
      for (var customer in remoteCustomers) {
        await localDataSource.addCustomer(customer);
      }
      return remoteCustomers.map((model) => model.toEntity()).toList();
    }
    final localCustomers = await localDataSource.getCustomers(userId);
    return localCustomers.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    final model = CustomerModel.fromEntity(customer);
    if (await connectivity.checkConnectivity() != ConnectivityResult.none) {
      await remoteDataSource.addCustomer(model);
    }
    await localDataSource.addCustomer(model);
  }
}
