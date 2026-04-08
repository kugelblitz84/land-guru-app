import 'dart:convert';

import 'package:get/get.dart';

import '../../../../core/services/api_client.dart';
import '../models/notification_model.dart';

class NotificationsService extends GetxService {
  NotificationsService(this._apiClient);

  final ApiClient _apiClient;

  Future<NotificationHistoryModel> fetchNotificationHistory({
    NotificationHistoryQuery query = const NotificationHistoryQuery(),
  }) async {
    final response = await _apiClient.get(
      '/notifications',
      queryParameters: query.toQueryParameters(),
    );

    final root = _extractResponseMap(response.data);
    final payload = root['data'] is List
        ? root['data'] as List
        : const <dynamic>[];
    final metaMap = root['meta'] is Map
        ? Map<String, dynamic>.from(root['meta'] as Map)
        : const <String, dynamic>{};

    final notifications = payload
        .whereType<Map>()
        .map(
          (item) => NotificationItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);

    return NotificationHistoryModel(
      notifications: notifications,
      meta: NotificationMeta.fromJson(metaMap),
    );
  }

  Future<int> fetchUnreadNotificationCount() async {
    final history = await fetchNotificationHistory(
      query: const NotificationHistoryQuery(page: 1, limit: 1),
    );
    return history.meta.unreadCount;
  }

  Future<NotificationItem?> fetchNotificationById({
    required String notificationId,
  }) async {
    final response = await _apiClient.get('/notifications/$notificationId');
    final root = _extractResponseMap(response.data);
    final data = root['data'];
    if (data is! Map) {
      return null;
    }

    return NotificationItem.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> markAllAsRead() async {
    await _apiClient.patch('/notifications/read-all');
  }

  Future<void> markAsRead({required String notificationId}) async {
    await _apiClient.patch('/notifications/$notificationId/read');
  }

  Future<void> registerDeviceToken({
    required RegisterFcmTokenPayload payload,
  }) async {
    await _apiClient.post(
      '/notifications/device/fcm-token',
      data: payload.toJson(),
    );
  }

  Future<void> unregisterDeviceToken({required String fcmToken}) async {
    await _apiClient.delete('/notifications/device/fcm/$fcmToken');
  }

  Map<String, dynamic> _extractResponseMap(dynamic payload) {
    final decoded = _decodeIfString(payload);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    return <String, dynamic>{};
  }

  dynamic _decodeIfString(dynamic payload) {
    if (payload is String && payload.trim().isNotEmpty) {
      return jsonDecode(payload);
    }
    return payload;
  }
}
