import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saris_cosmo_center/core/network/api_endpoints.dart';

class SearchService {
  Future<Map<String, dynamic>> search(String token, String query, String type) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.search}?q=$query&type=$type&limit=10'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Failed to connect to server: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'An error occurred during search';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
