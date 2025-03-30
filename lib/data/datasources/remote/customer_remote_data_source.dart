// lib/data/datasources/remote/customer_remote_data_source.dart
import '../../models/customer_model.dart';
import '../../../core/network/api_client.dart';

class CustomerRemoteDataSource {
  final ApiClient apiClient;

  CustomerRemoteDataSource(this.apiClient);

  Future<List<CustomerModel>> getCustomers(String userId) async {
    final response =
        await apiClient.get('/customers', queryParameters: {'userId': userId});
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((json) => CustomerModel.fromJson(json))
          .toList();
    }
    throw Exception('Failed to fetch customers');
  }

  Future<void> addCustomer(CustomerModel customer) async {
    final response =
        await apiClient.post('/customers', data: customer.toJson());
    if (response.statusCode != 201) throw Exception('Failed to add customer');
  }
}
