import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:osho/utils/constants/api_constants.dart';

class OHttpHelper {
  static const String _baseUrl = APIConstants.oBaseUrl;
  static final _storage = GetStorage();

  // Helper method to get headers with authentication token
  static Map<String, String> _getHeaders() {
    final token = _storage.read('TOKEN');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper method to make a GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      print('DEBUG: HTTP GET to $_baseUrl/$endpoint');
      final response = await http
          .get(
            Uri.parse('$_baseUrl/$endpoint'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to make a POST request
  static Future<Map<String, dynamic>> post(
      String endpoint, dynamic data) async {
    try {
      print('DEBUG: HTTP POST to $_baseUrl/$endpoint');
      final response = await http
          .post(
            Uri.parse('$_baseUrl/$endpoint'),
            headers: _getHeaders(),
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 30));
      print('DEBUG: HTTP Response Code: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('DEBUG: HTTP Error: $e');
      rethrow;
    }
  }

  // Helper method to make a PUT request
  static Future<Map<String, dynamic>> put(String endpoint, dynamic data) async {
    try {
      print('DEBUG: HTTP PUT to $_baseUrl/$endpoint');
      final response = await http
          .put(
            Uri.parse('$_baseUrl/$endpoint'),
            headers: _getHeaders(),
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to make a DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      print('DEBUG: HTTP DELETE to $_baseUrl/$endpoint');
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/$endpoint'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Handle the HTTP Response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    dynamic responseData;
    try {
      responseData = json.decode(response.body);
    } catch (_) {
      throw 'Server returned an invalid response: ${response.statusCode}';
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    } else {
      throw responseData['message'] ??
          'Error ${response.statusCode}: ${response.reasonPhrase}';
    }
  }
}
