import 'package:get/get.dart';

import 'package:landguru/core/services/api_client.dart';

class SellPostService extends GetxService {
  SellPostService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> createDraftStep1({
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiClient.post('/sell-posts/draft', data: payload);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map && data['data'] is Map<String, dynamic>) {
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception('Invalid response');
  }

  Future<Map<String, dynamic>> updateDraftStep({
    required String postId,
    required int step,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiClient.patch(
      '/sell-posts/draft/$postId',
      data: payload,
      queryParameters: {'step': step},
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

  Future<void> submitSellPost({required String postId}) async {
    await _apiClient.post('/sell-posts/$postId/submit');
  }
}
