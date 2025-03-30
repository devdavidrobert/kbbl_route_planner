// lib/core/network/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../error/exceptions.dart';

class ApiClient {
  final String baseUrl;
  final http.Client client;
  final Logger _logger = Logger();

  ApiClient({required this.baseUrl, required this.client});

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl$path'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw ServerException('Resource not found: $path');
      } else {
        throw ServerException(
            'Server error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      _logger.e('GET request failed for $path: $e');
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl$path'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw ServerException(
            'Server error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      _logger.e('POST request failed for $path: $e');
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  Future<Map<String, dynamic>> put(
      String path, Map<String, dynamic> body) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl$path'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ServerException(
            'Server error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      _logger.e('PUT request failed for $path: $e');
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  Future<void> delete(String path) async {
    try {
      final response = await client.delete(Uri.parse('$baseUrl$path'));

      if (response.statusCode != 200) {
        throw ServerException(
            'Server error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      _logger.e('DELETE request failed for $path: $e');
      throw NetworkException('Failed to connect to server: $e');
    }
  }
}
