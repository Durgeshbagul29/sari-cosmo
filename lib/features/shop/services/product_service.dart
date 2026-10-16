import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saris_cosmo_center/core/network/api_endpoints.dart';

class ProductService {
  Future<Map<String, dynamic>> getProducts(String token, {int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.products}?page=$page'),
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

  Future<Map<String, dynamic>> getProductDetail(String token, String slug) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.productDetail(slug)),
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

  Future<Map<String, dynamic>> getProductReviews(String token, String slug) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.products}/$slug/reviews'),
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

  Future<Map<String, dynamic>> submitReview(String token, String slug, Map<String, dynamic> reviewData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.products}/$slug/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(reviewData),
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
      String errorMessage = 'An error occurred';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
