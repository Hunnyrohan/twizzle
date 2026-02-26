import 'package:dio/dio.dart';
import 'package:twizzle/core/api/dio_client.dart';

class PaymentService {
  final DioClient _client;

  PaymentService(this._client);

  // Initiate Verification
  Future<Map<String, dynamic>> initiateVerification() async {
    try {
      final response = await _client.post('/payments/esewa/verification/initiate');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to initiate verification';
    }
  }

  // Confirm Verification
  Future<Map<String, dynamic>> confirmVerification({
    required String pid,
    required String refId,
    required double amt,
  }) async {
    try {
      final response = await _client.get(
        '/payments/esewa/verification/confirm',
        queryParameters: {
          'pid': pid,
          'refId': refId,
          'amt': amt,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Payment confirmation failed';
    }
  }

  // Get Verification Status
  Future<Map<String, dynamic>> getVerificationStatus() async {
    try {
      final response = await _client.get('/payments/esewa/verification/status');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch verification status';
    }
  }
}
