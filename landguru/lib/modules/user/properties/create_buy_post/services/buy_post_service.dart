import 'package:get/get.dart';

import 'package:landguru/core/models/models.dart';
import 'package:landguru/core/services/api_client.dart';
import '../models/create_buy_post_payload_model.dart';
import '../models/buy_post_details_payload.dart';

class BuyPostService extends GetxService {
  BuyPostService(this._apiClient);

  final ApiClient _apiClient;

  Future<DraftEntityResponse> createDraftStep1({
    required CreateBuyPostPayloadModel payload,
  }) async {
    final response = await _apiClient.post(
      '/buy-posts/draft',
      data: payload.toJson(),
    );
    return DraftEntityResponse.fromPayload(response.data);
  }

  Future<DraftEntityResponse> updateBuyPost({
    required String postId,
    required CreateBuyPostPayloadModel payload,
  }) async {
    final response = await _apiClient.patch(
      '/buy-posts/$postId',
      data: payload.toJson(),
    );
    return DraftEntityResponse.fromPayload(response.data);
  }

  Future<void> submitBuyPost({required String postId}) async {
    await _apiClient.post('/buy-posts/$postId/submit');
  }

  Future<BuyPostDetailsPayload> getBuyPostById(String postId) async {
    final response = await _apiClient.get('/buy-posts/$postId');

    final payload = response.data;
    if (payload is! Map) {
      throw Exception('Invalid response');
    }

    return BuyPostDetailsPayload.fromJson(Map<String, dynamic>.from(payload));
  }
}
