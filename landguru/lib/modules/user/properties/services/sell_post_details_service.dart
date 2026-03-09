import 'package:get/get.dart';

import '../../../../core/services/api_client.dart';
import 'models/sell_post_details_payload.dart';

class SellPostDetailsService extends GetxService {
  SellPostDetailsService(this._apiClient);

  final ApiClient _apiClient;

  Future<SellPostDetailsPayload> getSellPostById(String postId) async {
    final response = await _apiClient.get('/sell-posts/$postId');

    final payload = response.data;
    if (payload is! Map) {
      throw Exception('Invalid response');
    }

    return SellPostDetailsPayload.fromJson(Map<String, dynamic>.from(payload));
  }

  Future<Map<String, dynamic>> updateSellPost({
    required String postId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiClient.patch(
      '/sell-posts/$postId',
      data: payload,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map && data['data'] is Map<String, dynamic>) {
      return data['data'] as Map<String, dynamic>;
    }

    throw Exception('Invalid response');
  }

  Future<void> deleteSellPost(String postId) async {
    await _apiClient.delete('/sell-posts/$postId');
  }

  Future<Map<String, dynamic>> requoteSellPost({
    required String postId,
    required double proposedMandatoryFee,
    required double proposedOptionalFee,
  }) async {
    final response = await _apiClient.post(
      '/sell-posts/$postId/requote',
      data: {
        'proposedMandatoryFee': proposedMandatoryFee,
        'proposedOptionalFee': proposedOptionalFee,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map && data['data'] is Map<String, dynamic>) {
      return data['data'] as Map<String, dynamic>;
    }

    throw Exception('Invalid response');
  }

  Future<Map<String, dynamic>> acceptQuotedPrice({
    required String postId,
  }) async {
    final response = await _apiClient.post('/sell-posts/$postId/accept-quote');

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map && data['data'] is Map<String, dynamic>) {
      return data['data'] as Map<String, dynamic>;
    }

    throw Exception('Invalid response');
  }

  Future<void> requestAppointment({
    required String sellPostId,
    required String buyerName,
    required String buyerPhone,
    required String buyerAddress,
  }) async {
    await _apiClient.post(
      '/sell-posts/appointments/request',
      data: {
        'sellPostId': sellPostId,
        'buyerName': buyerName,
        'buyerPhone': buyerPhone,
        'buyerAddress': buyerAddress,
      },
    );
  }
}
