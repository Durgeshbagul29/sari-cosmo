import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/api_endpoints.dart';

class ApiService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e, 'Failed to login');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String phone, String password, String passwordConfirmation) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.register),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e, 'Failed to register');
    }
  }

  Future<Map<String, dynamic>> logout(String token, {String? fcmToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.logout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: fcmToken != null ? jsonEncode({'fcm_token': fcmToken}) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.forgotPassword),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e, 'Failed to request password reset');
    }
  }

  Future<Map<String, dynamic>> getDashboardData(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.dashboard),
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

  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.profile),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e, 'Failed to load profile');
    }
  }

  Future<Map<String, dynamic>> updateProfile(String token, String name, String phone) async {
    try {
      final response = await http.put(
        Uri.parse(ApiEndpoints.profile),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'phone': phone,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e, 'Failed to update profile');
    }
  }

  Future<Map<String, dynamic>> uploadAvatar(String token, String filePath) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(ApiEndpoints.profile));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      request.fields['_method'] = 'PUT';
      request.files.add(await http.MultipartFile.fromPath('avatar', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e, 'Failed to upload profile image');
    }
  }

  Future<Map<String, dynamic>> removeAvatar(String token) async {
    try {
      final response = await http.put(
        Uri.parse(ApiEndpoints.profile),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'remove_avatar': true,
          'avatar': null,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e, 'Failed to remove profile image');
    }
  }

  Future<Map<String, dynamic>> changePassword(
    String token,
    String currentPassword,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(ApiEndpoints.changePassword),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e, 'Failed to change password');
    }
  }

  Future<Map<String, dynamic>> getAddresses(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.addresses),
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

  Future<Map<String, dynamic>> addAddress(String token, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.addresses),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Map<String, dynamic>> updateAddress(String token, String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiEndpoints.addresses}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Map<String, dynamic>> deleteAddress(String token, String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiEndpoints.addresses}/$id'),
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

  Future<Map<String, dynamic>> setDefaultAddress(String token, String id) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.addresses}/$id/set-default'),
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

  Future<Map<String, dynamic>> registerFcmToken(String token, String fcmToken, {String? deviceName}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.fcmToken),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'token': fcmToken,
          if (deviceName != null) 'device_name': deviceName,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Failed to register FCM token: $e');
    }
  }

  Future<Map<String, dynamic>> deleteFcmToken(String token, String fcmToken) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiEndpoints.fcmToken),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'token': fcmToken,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Failed to delete FCM token: $e');
    }
  }

  Future<Map<String, dynamic>> getNotifications(String token, {int page = 1, int perPage = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.notifications}?page=$page&per_page=$perPage'),
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
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  Future<Map<String, dynamic>> getUnreadCount(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.unreadCount),
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
      throw Exception('Failed to fetch unread count: $e');
    }
  }

  Future<Map<String, dynamic>> markNotificationRead(String token, String notificationId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.markNotificationRead(notificationId)),
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
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<Map<String, dynamic>> markAllNotificationsRead(String token) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.markAllNotificationsRead),
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
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // In case body is empty
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'An error occurred';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['errors'] != null && errorData['errors'] is Map) {
          // Flatten nested errors
          final Map<String, dynamic> errors = errorData['errors'];
          errorMessage = errors.values.map((e) {
            if (e is List) return e.join('\n');
            return e.toString();
          }).join('\n');
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          errorMessage = errorData['error'];
        }
      } catch (_) {
        // If the body is not JSON or cannot be decoded
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw Exception(errorMessage);
    }
  }

  Exception _handleException(dynamic e, [String defaultMessage = 'Failed to connect to server']) {
    if (e is Exception) {
      return e;
    }
    if (e.toString().contains('SocketException') || e.toString().contains('ClientException') || e.toString().contains('Software caused connection abort') || e.toString().contains('Network is unreachable')) {
      return Exception('No internet connection. Please check your network and try again.');
    }
    return Exception('$defaultMessage: $e');
  }
}
