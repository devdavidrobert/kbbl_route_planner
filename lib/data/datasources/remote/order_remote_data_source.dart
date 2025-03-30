import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:logging/logging.dart';
import '../../models/order_model.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/core/failures.dart';

class OrderRemoteDataSource {
  final ApiClient apiClient;
  final _logger = Logger('OrderRemoteDataSource');

  OrderRemoteDataSource({
    required this.apiClient,
    required firebase_auth.FirebaseAuth auth,
  });


  Future<List<OrderModel>> getOrders(String userId) async {
    try {
      final response = await apiClient.get('/orders?userId=$userId');
      
      if (response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else if (response['error'] == 'not_found') {
        return [];
      }
      
      throw ServerFailure('Failed to fetch orders');
    } catch (e) {
      _logger.severe('Error fetching orders: $e');
      throw ServerFailure('Failed to fetch orders: $e');
    }
  }

  Future<void> placeOrder(OrderModel order) async {
    try {
      final response = await apiClient.post('/orders', order.toJson());
      
      if (response['error'] != null) {
        _logger.severe('Server error response: ${response['error']}');
        throw ServerFailure('Failed to place order: ${response['error']}');
      }
    } catch (e) {
      _logger.severe('Error placing order: $e');
      throw ServerFailure('Failed to place order: $e');
    }
  }
} 