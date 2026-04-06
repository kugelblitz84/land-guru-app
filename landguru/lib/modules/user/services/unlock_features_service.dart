import 'package:get/get.dart';

import '../../../core/services/api_client.dart';
import '../model/payment_models.dart';
import '../model/unlock_features_models.dart';

class UnlockFeaturesService extends GetxService {
  UnlockFeaturesService(this._apiClient);

  final ApiClient _apiClient;

  Future<UnlockFeaturesSummary> getUnlockFeaturesSummary() async {
    final response = await _apiClient.get('/users/me/unlock-features-summary');
    return UnlockFeaturesSummary.fromPayload(response.data);
  }

  Future<SslCommerzSession> createUnlockFeaturesSession() async {
    final response = await _apiClient.post('/users/me/unlock-features/session');
    return SslCommerzSession.fromPayload(response.data);
  }

  Future<PaymentSessionValidation> getPaymentStatus({
    required String tranId,
  }) async {
    final response = await _apiClient.get('/payments/$tranId/status');
    return PaymentSessionValidation.fromPayload(response.data);
  }

  Future<UnlockFeaturesAccess> confirmUnlockFeatures({
    required String tranId,
  }) async {
    final response = await _apiClient.post(
      '/users/me/unlock-features/confirm',
      data: {'tranId': tranId},
    );
    return UnlockFeaturesAccess.fromPayload(response.data);
  }
}
