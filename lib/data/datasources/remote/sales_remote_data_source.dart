// lib/data/datasources/remote/sales_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../core/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/order_model.dart';
import '../../models/customer_model.dart';

class SalesRemoteDataSource {
  final ApiClient apiClient;

  SalesRemoteDataSource(this.apiClient);

  Future<List<OrderModel>> fetchOrders(String userId) async {
    try {
      final idToken =
          await firebase_auth.FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) throw Exception('User not authenticated');

      print(
          'SalesRemoteDataSource: Fetching orders from: ${AppConstants.apiBaseUrl}/orders?userId=$userId');
      final response = await apiClient
          .get(
            '/orders',
            queryParameters: {'userId': userId},
            options: Options(
              headers: {'Authorization': 'Bearer $idToken'},
              validateStatus: (status) {
                if (status == 500) {
                  print(
                      'SalesRemoteDataSource: Received 500 error from server');
                }
                return status != null && (status == 200 || status == 500);
              },
            ),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timed out'),
          );

      print(
          'SalesRemoteDataSource: Response: ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => OrderModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch orders: ${response.statusMessage}');
      }
    } catch (e) {
      print('SalesRemoteDataSource: Error fetching orders: $e');
      rethrow;
    }
  }

  Future<void> placeOrder(OrderModel order) async {
    try {
      final idToken =
          await firebase_auth.FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) throw Exception('User not authenticated');

      print(
          'SalesRemoteDataSource: Placing order at: ${AppConstants.apiBaseUrl}/orders');
      print('Request body: ${order.toJson()}');
      final response = await apiClient.post(
        '/orders',
        data: order.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
          validateStatus: (status) =>
              status != null && (status == 201 || status == 500),
        ),
      );

      print(
          'SalesRemoteDataSource: Response: ${response.statusCode} ${response.data}');
      if (response.statusCode != 201) {
        throw Exception('Failed to place order: ${response.statusMessage}');
      }
    } catch (e) {
      print('SalesRemoteDataSource: Error placing order: $e');
      rethrow;
    }
  }

  Future<void> enrollCustomer(CustomerModel customer) async {
    try {
      final idToken =
          await firebase_auth.FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) throw Exception('User not authenticated');

      print(
          'SalesRemoteDataSource: Enrolling customer at: ${AppConstants.apiBaseUrl}/customers');
      print('Request body: ${customer.toJson()}');
      final response = await apiClient.post(
        '/customers',
        data: customer.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
          validateStatus: (status) =>
              status != null && (status == 201 || status == 500),
        ),
      );

      print(
          'SalesRemoteDataSource: Response: ${response.statusCode} ${response.data}');
      if (response.statusCode != 201) {
        throw Exception('Failed to enroll customer: ${response.statusMessage}');
      }
    } catch (e) {
      print('SalesRemoteDataSource: Error enrolling customer: $e');
      rethrow;
    }
  }

  Future<void> updateCustomer({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    try {
      final idToken =
          await firebase_auth.FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) throw Exception('User not authenticated');

      final data = {
        'customerName': customerName,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
      };

      print(
          'SalesRemoteDataSource: Updating customer at: ${AppConstants.apiBaseUrl}/customers/$customerId');
      print('Request body: $data');
      final response = await apiClient.put(
        '/customers/$customerId',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
          validateStatus: (status) =>
              status != null && (status == 200 || status == 500),
        ),
      );

      print(
          'SalesRemoteDataSource: Response: ${response.statusCode} ${response.data}');
      if (response.statusCode != 200) {
        throw Exception('Failed to update customer: ${response.statusMessage}');
      }
    } catch (e) {
      print('SalesRemoteDataSource: Error updating customer: $e');
      rethrow;
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      final idToken =
          await firebase_auth.FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) throw Exception('User not authenticated');

      print(
          'SalesRemoteDataSource: Deleting customer at: ${AppConstants.apiBaseUrl}/customers/$customerId');
      final response = await apiClient.delete(
        '/customers/$customerId',
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
          validateStatus: (status) =>
              status != null && (status == 200 || status == 500),
        ),
      );

      print(
          'SalesRemoteDataSource: Response: ${response.statusCode} ${response.data}');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete customer: ${response.statusMessage}');
      }
    } catch (e) {
      print('SalesRemoteDataSource: Error deleting customer: $e');
      rethrow;
    }
  }

  Future<void> trackStock(String stockId, int quantity) async {
    try {
      final idToken =
          await firebase_auth.FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) throw Exception('User not authenticated');

      final data = {'stockId': stockId, 'quantity': quantity};

      print(
          'SalesRemoteDataSource: Tracking stock at: ${AppConstants.apiBaseUrl}/stock');
      print('Request body: $data');
      final response = await apiClient.post(
        '/stock',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
          validateStatus: (status) =>
              status != null && (status == 201 || status == 500),
        ),
      );

      print(
          'SalesRemoteDataSource: Response: ${response.statusCode} ${response.data}');
      if (response.statusCode != 201) {
        throw Exception('Failed to track stock: ${response.statusMessage}');
      }
    } catch (e) {
      print('SalesRemoteDataSource: Error tracking stock: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCustomerPerformance(
      String customerId, String userId) async {
    try {
      final idToken =
          await firebase_auth.FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) throw Exception('User not authenticated');

      print(
          'SalesRemoteDataSource: Fetching customer performance from: ${AppConstants.apiBaseUrl}/customers/$customerId/performance?userId=$userId');
      final response = await apiClient.get(
        '/customers/$customerId/performance',
        queryParameters: {'userId': userId},
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
          validateStatus: (status) =>
              status != null && (status == 200 || status == 500),
        ),
      );

      print(
          'SalesRemoteDataSource: Response: ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to fetch customer performance: ${response.statusMessage}');
      }
    } catch (e) {
      print('SalesRemoteDataSource: Error fetching customer performance: $e');
      rethrow;
    }
  }
}
