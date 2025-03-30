import 'package:connectivity_plus/connectivity_plus.dart';
import '../datasources/local/customer_local_data_source.dart';
import '../datasources/remote/customer_remote_data_source.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../models/customer_model.dart';
import 'package:logging/logging.dart';

class CustomerRepositoryException implements Exception {
  final String message;
  final dynamic originalError;
  CustomerRepositoryException(this.message, [this.originalError]);
  @override
  String toString() =>
      'CustomerRepositoryException: $message${originalError != null ? ' (Original error: $originalError)' : ''}';
}

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;
  final CustomerLocalDataSource localDataSource;
  final Connectivity connectivity;
  final Logger _logger;

  CustomerRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
    required Logger logger,
  }) : _logger = logger;

  @override
  Future<List<Customer>> getCustomers(String userId) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        _logger.info('Fetching customers for user: $userId from remote');
        final customers = await remoteDataSource.getCustomers(userId);
        for (var customer in customers) {
          await localDataSource.addCustomer(customer, isSynced: true);
        }
        return customers.map((model) => model.toEntity()).toList();
      } else {
        _logger.warning('No internet connection. Fetching customers from local storage.');
        final customers = await localDataSource.getCustomers(userId);
        return customers.map((model) => model.toEntity()).toList();
      }
    } catch (e) {
      _logger.severe('Failed to get customers: $e');
      throw CustomerRepositoryException('Unable to fetch customers', e);
    }
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    try {
      _logger.info('Adding customer: ${customer.name}');
      final customerModel = CustomerModel.fromEntity(customer);
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        await remoteDataSource.createCustomer(customerModel);
        await localDataSource.addCustomer(customerModel, isSynced: true);
      } else {
        await localDataSource.addCustomer(customerModel, isSynced: false);
      }
    } catch (e) {
      _logger.severe('Failed to add customer: $e');
      throw CustomerRepositoryException('Unable to add customer', e);
    }
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    try {
      _logger.info('Deleting customer with ID: $customerId');
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        await remoteDataSource.deleteCustomer(customerId);
      }
      await localDataSource.deleteCustomer(customerId);
    } catch (e) {
      _logger.severe('Failed to delete customer: $e');
      throw CustomerRepositoryException('Unable to delete customer', e);
    }
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    try {
      _logger.info('Updating customer: ${customer.name}');
      final customerModel = CustomerModel.fromEntity(customer);
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        await remoteDataSource.updateCustomer(customerModel);
        await localDataSource.updateCustomer(customerModel, isSynced: true);
      } else {
        await localDataSource.updateCustomer(customerModel, isSynced: false);
      }
    } catch (e) {
      _logger.severe('Failed to update customer: $e');
      throw CustomerRepositoryException('Unable to update customer', e);
    }
  }

  Future<void> syncUnsyncedCustomers() async {
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _logger.warning('No connectivity for sync');
      return;
    }
    try {
      _logger.info('Syncing unsynced customers');
      final unsynced = await localDataSource.getUnsyncedCustomers();
      for (var customer in unsynced) {
        try {
          await remoteDataSource.createCustomer(customer);
          await localDataSource.updateCustomer(customer, isSynced: true);
          _logger.info('Synced customer: ${customer.id}');
        } catch (e) {
          _logger.severe('Sync failed for customer ${customer.id}: $e');
        }
      }
    } catch (e) {
      _logger.severe('Failed to sync customers: $e');
    }
  }
}