import 'package:get/get.dart';

import '../../../../core/models/models.dart';
import '../../../../core/services/api_client.dart';
import '../my_posts/sell_posts/models/sell_post_models.dart';
import 'models/sell_post_details_payload.dart';
import 'models/sell_post_request_payloads.dart';

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
    required UpdateSellPostPayload payload,
  }) async {
    final response = await _apiClient.patch(
      '/sell-posts/$postId',
      data: payload.toJson(),
    );

    return DraftEntityResponse.fromPayload(response.data);
  }

  Future<void> deleteSellPost(String postId) async {
    await _apiClient.delete('/sell-posts/$postId');
  }

  Future<QuotePaymentSummary> getQuotePaymentSummary({
    required String postId,
  }) async {
    final response = await _apiClient.get(
      '/sell-posts/$postId/quote-payment-summary',
    );

    return QuotePaymentSummary.fromPayload(response.data);
  }

  Future<DraftEntityResponse> requoteSellPost({
    required String postId,
    required RequoteSellPostPayload payload,
  }) async {
    final response = await _apiClient.post(
      '/sell-posts/$postId/requote',
      data: payload.toJson(),
    );

    return DraftEntityResponse.fromPayload(response.data);
  }

  Future<DraftEntityResponse> acceptQuotedPrice({
    required String postId,
    required String tranId,
  }) async {
    final response = await _apiClient.post(
      '/sell-posts/$postId/accept-quote',
      data: {'tranId': tranId},
    );
    return DraftEntityResponse.fromPayload(response.data);
  }

  Future<void> requestAppointment({
    required RequestSellPostAppointmentPayload payload,
  }) async {
    await _apiClient.post(
      '/sell-posts/appointments/request',
      data: payload.toJson(),
    );
  }
}
