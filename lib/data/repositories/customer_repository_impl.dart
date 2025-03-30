// lib/data/repositories/customer_repository_impl.dart
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import Connectivity
import '../datasources/local/customer_local_data_source.dart';
import '../datasources/remote/customer_remote_data_source.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../models/customer_model.dart';

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
  final Connectivity connectivity; // Added connectivity parameter
  final Logger _logger = Logger();

  CustomerRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity, // Added connectivity initialization
  });

  @override
  Future<List<Customer>> getCustomers(String userId) async {
    try {
      _logger.i('Fetching customers for user: $userId');
      final customers = await remoteDataSource.getCustomers(userId);
      for (var customer in customers) {
        await localDataSource.addCustomer(customer);
      }
      return customers.map((model) => model.toEntity()).toList();
    } catch (e) {
      _logger
          .w('No internet connection. Fetching customers from local storage.');
      final customers = await localDataSource.getCustomers(userId);
      return customers.map((model) => model.toEntity()).toList();
    }
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    try {
      _logger.i('Adding customer: ${customer.name}');
      final customerModel = CustomerModel.fromEntity(customer);
      await remoteDataSource
          .createCustomer(customerModel); // Use createCustomer here
      await localDataSource.addCustomer(customerModel);
    } catch (e) {
      _logger.e('Failed to add customer: $e');
      throw Exception('Unable to add customer. Please try again later.');
    }
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    try {
      _logger.i('Deleting customer with ID: $customerId');
      await remoteDataSource.deleteCustomer(customerId);
      await localDataSource.deleteCustomer(customerId);
    } catch (e) {
      _logger.e('Failed to delete customer: $e');
      throw Exception('Unable to delete customer. Please try again later.');
    }
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    try {
      _logger.i('Updating customer: ${customer.name}');
      final customerModel = CustomerModel.fromEntity(customer);
      await remoteDataSource.updateCustomer(customerModel);
      await localDataSource.updateCustomer(customerModel);
    } catch (e) {
      _logger.e('Failed to update customer: $e');
      throw Exception('Unable to update customer. Please try again later.');
    }
  }
}
