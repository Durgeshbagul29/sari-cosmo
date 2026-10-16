import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_filex/open_filex.dart';
import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:saris_cosmo_center/core/network/api_endpoints.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import 'package:saris_cosmo_center/core/utils/app_snackbar.dart';

class OrderController extends GetxController {
  final OrderService _orderService = OrderService();

  var orders = <Order>[].obs;
  var orderDetail = Rxn<OrderDetail>();
  var isLoading = false.obs;
  var isDetailLoading = false.obs;
  var isDownloadingInvoice = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Fetch all orders
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final token = await _getToken();
      if (token == null) {
        debugPrint('Fetch Orders: auth_token is null, skipping fetch.');
        return;
      }

      debugPrint('Fetching orders from GET /v1/orders...');
      final response = await _orderService.getOrders(token);
      debugPrint('GET /v1/orders Response: $response');
      if (response['success'] == true && response['data'] != null) {
        final List dataList = response['data'] ?? [];
        final parsedOrders = dataList.map((e) => Order.fromJson(e)).toList();
        orders.assignAll(parsedOrders);
        debugPrint('Parsed ${parsedOrders.length} orders successfully.');
      }
    } catch (e) {
      debugPrint('Fetch Orders Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch order detail
  Future<void> fetchOrderDetail(int orderId) async {
    try {
      isDetailLoading.value = true;
      orderDetail.value = null; // Clear previous selection
      final token = await _getToken();
      if (token == null) {
        debugPrint('Fetch Order Detail: auth_token is null, skipping fetch.');
        return;
      }

      debugPrint('Fetching order detail for ID: $orderId from GET /v1/orders/$orderId...');
      final response = await _orderService.getOrderDetails(token, orderId);
      debugPrint('GET /v1/orders/$orderId Response: $response');
      if (response['success'] == true && response['data'] != null) {
        orderDetail.value = OrderDetail.fromJson(response['data']);
        debugPrint('Parsed OrderDetail successfully: ${orderDetail.value?.orderNumber}');
      }
    } catch (e) {
      debugPrint('Fetch Order Detail Error: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }

  /// Cancel an order
  Future<bool> cancelOrder(int orderId) async {
    try {
      isDetailLoading.value = true;
      final token = await _getToken();
      if (token == null) return false;

      debugPrint('Cancelling order ID: $orderId via POST /v1/orders/$orderId/cancel...');
      final response = await _orderService.cancelOrder(token, orderId);
      debugPrint('POST /v1/orders/$orderId/cancel Response: $response');
      
      if (response['success'] == true) {
        // Refresh detail and list
        await fetchOrderDetail(orderId);
        fetchOrders();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Cancel Order Error: $e');
      AppSnackbar.error(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    } finally {
      isDetailLoading.value = false;
    }
  }

  /// Download and Share Invoice PDF
  Future<void> downloadInvoice(int orderId, String orderNumber) async {
    try {
      isDownloadingInvoice.value = true;
      final token = await _getToken();
      if (token == null) {
        AppSnackbar.error(
          'Error',
          'Not authenticated.',
        );
        return;
      }

      final urlString = '${ApiEndpoints.baseUrl}/v1/orders/$orderId/invoice/pdf';
      debugPrint('Downloading invoice from GET $urlString...');
      
      final response = await http.get(
        Uri.parse(urlString),
        headers: {
          'Authorization': 'Bearer $token',
          'Connection': 'close',
        },
      );

      debugPrint('Invoice Download response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        
        // 1. Save to a temporary file first
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/invoice_$orderNumber.pdf');
        await tempFile.writeAsBytes(bytes);
        debugPrint('Saved temp invoice to ${tempFile.path}');

        // 2. Copy the file into the device\'s public Downloads folder
        final success = await copyFileIntoDownloadFolder(
          tempFile.path,
          'invoice_$orderNumber',
          desiredExtension: 'pdf',
        );
        
        String savedPath;
        if (success == true) {
          final downloadDir = await getDownloadDirectory();
          savedPath = '${downloadDir.path}/invoice_$orderNumber.pdf';
          debugPrint('Successfully copied file to downloads folder: $savedPath');
        } else {
          // Fallback to temp file path if copy failed
          savedPath = tempFile.path;
          debugPrint('Failed to copy file to downloads folder, falling back to: $savedPath');
        }

        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: AppTheme.surface,
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            title: const Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppTheme.success,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Success',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Invoice PDF has been successfully downloaded and saved to your phone\'s download location.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMedium,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Saved Path:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: SelectableText(
                    savedPath,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: AppTheme.textDark,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppTheme.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        OpenFilex.open(savedPath);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Open',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Download Invoice Error: $e');
      AppSnackbar.error(
        'Error',
        'Failed to download invoice: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      isDownloadingInvoice.value = false;
    }
  }
}
