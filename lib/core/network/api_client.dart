import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

class ApiClient {
  final String baseUrl;
  final http.Client client;
  final Logger _logger;

  ApiClient({
    required this.baseUrl,
    required this.client,
    required Logger logger,
  }) : _logger = logger;

  Future<Map<String, dynamic>> get(String path) async {
    try {
      _logger.info('GET request to $baseUrl$path');
      final response = await client
          .get(Uri.parse('$baseUrl$path'))
          .timeout(AppConstants.connectTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      _logger.severe('GET request timed out for $path');
      throw NetworkException('Request timed out');
    } catch (e) {
      _logger.severe('GET request failed for $path: $e');
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    try {
      _logger.info('POST request to $baseUrl$path with body: $body');
      final response = await client
          .post(
            Uri.parse('$baseUrl$path'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(AppConstants.connectTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      _logger.severe('POST request timed out for $path');
      throw NetworkException('Request timed out');
    } catch (e) {
      _logger.severe('POST request failed for $path: $e');
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    try {
      _logger.info('PUT request to $baseUrl$path with body: $body');
      final response = await client
          .put(
            Uri.parse('$baseUrl$path'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(AppConstants.connectTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      _logger.severe('PUT request timed out for $path');
      throw NetworkException('Request timed out');
    } catch (e) {
      _logger.severe('PUT request failed for $path: $e');
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  Future<void> delete(String path) async {
    try {
      _logger.info('DELETE request to $baseUrl$path');
      final response = await client
          .delete(Uri.parse('$baseUrl$path'))
          .timeout(AppConstants.connectTimeout);
      if (response.statusCode != 200) {
        throw ServerException(
            'Server error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } on TimeoutException {
      _logger.severe('DELETE request timed out for $path');
      throw NetworkException('Request timed out');
    } catch (e) {
      _logger.severe('DELETE request failed for $path: $e');
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = json.decode(response.body) as Map<String, dynamic>;
    _logger.fine('Response status: ${response.statusCode}, body: $body');
    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 401:
        throw UnauthorizedException('Unauthorized access');
      case 404:
        return {'status': 404, 'message': 'Resource not found'};
      default:
        throw ServerException(
            'Server error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }
}