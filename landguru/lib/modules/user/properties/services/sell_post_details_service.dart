import 'package:get/get.dart';

import '../../../../core/models/models.dart';
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

  Future<DraftEntityResponse> updateSellPost({
    required String postId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiClient.patch(
      '/sell-posts/$postId',
      data: payload,
    );

    return DraftEntityResponse.fromPayload(response.data);
  }

  Future<void> deleteSellPost(String postId) async {
    await _apiClient.delete('/sell-posts/$postId');
  }

  Future<DraftEntityResponse> requoteSellPost({
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

    return DraftEntityResponse.fromPayload(response.data);
  }

  Future<DraftEntityResponse> acceptQuotedPrice({
    required String postId,
  }) async {
    final response = await _apiClient.post('/sell-posts/$postId/accept-quote');
    return DraftEntityResponse.fromPayload(response.data);
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
