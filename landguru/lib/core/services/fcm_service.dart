import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../modules/shared/notifications/models/notification_model.dart';
import '../../modules/shared/notifications/notifications_controller.dart';
import '../../modules/shared/notifications/services/notifications_service.dart';
import '../../modules/shared/controllers/user_profile_store.dart';
import '../../modules/shared/controllers/agent_profile_store.dart';
import '../../routes/app_routes.dart';
import 'api_error_handler.dart';
import 'auth_service.dart';
import 'user_type_service.dart';

class FcmService extends GetxService {
  FcmService(
    this._authService,
    this._userTypeService,
    this._notificationsService,
  );

  final AuthService _authService;
  final UserTypeService _userTypeService;
  final NotificationsService _notificationsService;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSubscription;
  StreamSubscription<String>? _onTokenRefreshSubscription;

  bool _isInitialized = false;
  String? _lastSyncedToken;

  Future<void> initialize() async {
    if (_isInitialized || !_isMessagingSupportedPlatform()) {
      return;
    }

    _isInitialized = true;

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    if (!kIsWeb) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _onMessageSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
    _onMessageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleNotificationTap,
    );
    _onTokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) {
      unawaited(syncTokenWithBackend(tokenOverride: token, force: true));
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  Future<void> syncTokenWithBackend({
    String? tokenOverride,
    bool force = false,
  }) async {
    if (!_isMessagingSupportedPlatform()) {
      return;
    }

    if (!_authService.isLoggedIn) {
      return;
    }

    final token = tokenOverride ?? await _messaging.getToken();
    if (token == null || token.trim().isEmpty) {
      return;
    }

    if (!force && _lastSyncedToken == token) {
      return;
    }

    await _notificationsService.registerDeviceToken(
      payload: RegisterFcmTokenPayload(
        fcmToken: token,
        deviceType: _resolveDeviceType(),
      ),
    );

    _lastSyncedToken = token;
  }

  Future<void> unregisterCurrentToken() async {
    if (!_isMessagingSupportedPlatform()) {
      _lastSyncedToken = null;
      return;
    }

    if (!_authService.isLoggedIn) {
      _lastSyncedToken = null;
      return;
    }

    final token = _lastSyncedToken ?? await _messaging.getToken();
    if (token == null || token.trim().isEmpty) {
      _lastSyncedToken = null;
      return;
    }

    await _notificationsService.unregisterDeviceToken(fcmToken: token);
    _lastSyncedToken = null;
  }

  @override
  void onClose() {
    _onMessageSubscription?.cancel();
    _onMessageOpenedSubscription?.cancel();
    _onTokenRefreshSubscription?.cancel();
    super.onClose();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (Get.isRegistered<NotificationsController>()) {
      unawaited(Get.find<NotificationsController>().refresh());
    }
    unawaited(_syncUnreadCountFromBackend());

    final title =
        message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();

    if (title == null || title.trim().isEmpty) {
      return;
    }

    Get.snackbar(
      title,
      body ?? 'You have a new notification',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _syncUnreadCountFromBackend() async {
    if (!_authService.isLoggedIn) {
      return;
    }

    final unreadResult = await ApiErrorHandler.call<int>(
      () => _notificationsService.fetchUnreadNotificationCount(),
      showError: false,
    );

    if (!unreadResult.isSuccess || unreadResult.data == null) {
      return;
    }

    final count = unreadResult.data!;
    if (_userTypeService.isAgent) {
      if (Get.isRegistered<AgentProfileStore>()) {
        Get.find<AgentProfileStore>().updateUnreadCount(count);
      }
      return;
    }

    if (_userTypeService.isUser) {
      if (Get.isRegistered<UserProfileStore>()) {
        Get.find<UserProfileStore>().updateUnreadCount(count);
      }
      return;
    }

    if (Get.isRegistered<UserProfileStore>()) {
      Get.find<UserProfileStore>().updateUnreadCount(count);
    }
    if (Get.isRegistered<AgentProfileStore>()) {
      Get.find<AgentProfileStore>().updateUnreadCount(count);
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (!_authService.isLoggedIn) {
      return;
    }

    final targetRoute = _userTypeService.isAgent
        ? AppRoutes.AGENT_NOTIFICATIONS
        : AppRoutes.NOTIFICATIONS;

    if (Get.currentRoute != targetRoute) {
      Get.toNamed(targetRoute, arguments: message.data);
    }
  }

  String _resolveDeviceType() {
    if (kIsWeb) {
      return 'web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  bool _isMessagingSupportedPlatform() {
    if (kIsWeb) {
      return true;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }
}
