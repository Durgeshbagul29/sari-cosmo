import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saris_cosmo_center/core/network/api_endpoints.dart';

class OrderService {
  /// GET /v1/orders — Fetch all orders
  Future<Map<String, dynamic>> getOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.orders),
        headers: _headers(token),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// GET /v1/orders/:order — Fetch order details by number/id
  Future<Map<String, dynamic>> getOrderDetails(String token, int orderId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.orderDetail(orderId.toString())),
        headers: _headers(token),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// POST /v1/orders/:order/cancel — Cancel order
  Future<Map<String, dynamic>> cancelOrder(String token, int orderId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.cancelOrder(orderId)),
        headers: _headers(token),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to connect to server: $e');
    }
  }

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
    'Connection': 'close',
  };

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
