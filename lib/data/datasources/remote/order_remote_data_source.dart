import '../../models/order_model.dart';
import '../../../core/network/api_client.dart';

class OrderRemoteDataSource {
  final ApiClient apiClient;

  OrderRemoteDataSource(this.apiClient);

  Future<List<OrderModel>> getOrders(String userId) async {
    final response =
        await apiClient.get('/orders', queryParameters: {'userId': userId});
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    }
    throw Exception('Failed to fetch orders');
  }

  Future<void> placeOrder(OrderModel order) async {
    final response = await apiClient.post('/orders', data: order.toJson());
    if (response.statusCode != 201) throw Exception('Failed to place order');
  }
}
