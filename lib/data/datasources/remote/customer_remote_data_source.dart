// lib/data/datasources/remote/customer_remote_data_source.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:logging/logging.dart';
import '../../../core/network/api_client.dart';
import '../../models/customer_model.dart';
import '../../../domain/core/failures.dart';

class CustomerRemoteDataSource {
  final ApiClient apiClient;
  final firebase_auth.FirebaseAuth _auth;
  final _logger = Logger('CustomerRemoteDataSource');

  CustomerRemoteDataSource({
    required this.apiClient,
    required firebase_auth.FirebaseAuth auth,
  }) : _auth = auth;


  Future<String> _getMongoUserId(String email) async {
    try {
      final response = await apiClient.get('/users?email=$email');
      
      if (response['data'] != null) {
        return response['data']['_id']; // MongoDB _id field
      }
      throw ServerFailure('User not found in MongoDB');
    } catch (e) {
      _logger.severe('Error getting MongoDB user ID: $e');
      throw ServerFailure('Failed to get MongoDB user ID: $e');
    }
  }

  Future<List<CustomerModel>> getCustomers(String userId) async {
    try {
      final response = await apiClient.get('/customers?userId=$userId');
      
      if (response['data'] != null) {
        final List<dynamic> data = response['data']['customers'] ?? [];
        return data.map((json) => CustomerModel.fromJson(json)).toList();
      }

      throw ServerFailure('Failed to fetch customers');
    } catch (e) {
      _logger.severe('Error fetching customers: $e');
      throw ServerFailure('Failed to fetch customers: $e');
    }
  }

  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw AuthFailure('No authenticated user');

      // Get MongoDB user ID
      final mongoUserId = await _getMongoUserId(currentUser.email!);
      
      // Create a copy of the customer with MongoDB user ID
      final customerData = customer.toJson();
      customerData['userId'] = mongoUserId;

      _logger.info('Creating customer with data: $customerData');
      
      final response = await apiClient.post('/customers', customerData);
      
      if (response['data'] != null) {
        return CustomerModel.fromJson(response['data']);
      }

      _logger.severe('Server error response: ${response['error']}');
      throw ServerFailure('Failed to create customer: ${response['error'] ?? 'Unknown error'}');
    } catch (e) {
      _logger.severe('Error creating customer: $e');
      throw ServerFailure('Failed to create customer: $e');
    }
  }

  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    try {
      final response = await apiClient.put('/customers/${customer.id}', customer.toJson());
      
      if (response['data'] != null) {
        return CustomerModel.fromJson(response['data']);
      }

      throw ServerFailure('Failed to update customer');
    } catch (e) {
      _logger.severe('Error updating customer: $e');
      throw ServerFailure('Failed to update customer: $e');
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await apiClient.delete('/customers/$customerId');
    } catch (e) {
      _logger.severe('Error deleting customer: $e');
      throw ServerFailure('Failed to delete customer: $e');
    }
  }
}
