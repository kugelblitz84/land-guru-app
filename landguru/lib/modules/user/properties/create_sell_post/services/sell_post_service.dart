import 'package:get/get.dart';

import 'package:landguru/core/models/models.dart';
import 'package:landguru/core/services/api_client.dart';
import '../models/create_sell_post_payload_model.dart';

class SellPostService extends GetxService {
  SellPostService(this._apiClient);

  final ApiClient _apiClient;

  Future<DraftEntityResponse> createDraftStep1({
    required CreateSellPostPayloadModel payload,
  }) async {
    final response = await _apiClient.post(
      '/sell-posts/draft',
      data: payload.toJson(),
    );
    return DraftEntityResponse.fromPayload(response.data);
  }

  Future<DraftEntityResponse> updateDraftStep1({
    required String postId,
    required CreateSellPostPayloadModel payload,
  }) async {
    final response = await _apiClient.patch(
      '/sell-posts/draft/$postId',
      data: payload.toJson(),
      queryParameters: {'step': 1},
    );
    return DraftEntityResponse.fromPayload(response.data);
  }

  Future<DraftEntityResponse> updateDraftStep({
    required String postId,
    required int step,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiClient.patch(
      '/sell-posts/draft/$postId',
      data: payload,
      queryParameters: {'step': step},
    );
    return DraftEntityResponse.fromPayload(response.data);
  }

  Future<void> submitSellPost({required String postId}) async {
    await _apiClient.post('/sell-posts/$postId/submit');
  }
}
