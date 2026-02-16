import 'package:get/get.dart';

import 'package:landguru/core/services/api_client.dart';

class BuyPostService extends GetxService {
  BuyPostService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> createDraftStep1({
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiClient.post('/buy-posts/draft', data: payload);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map && data['data'] is Map<String, dynamic>) {
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception('Invalid response');
  }

  Future<Map<String, dynamic>> updateBuyPost({
    required String postId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiClient.patch(
      '/buy-posts/$postId',
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

class BuyPostDetailsPayload {
  BuyPostDetailsPayload({required this.raw});

  final Map<String, dynamic> raw;

  factory BuyPostDetailsPayload.fromJson(Map<String, dynamic> json) {
    return BuyPostDetailsPayload(raw: json);
  }

  String get id => raw['id']?.toString() ?? '';

  int? get lastCompletedStep {
    final value = raw['lastCompletedStep'];
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
