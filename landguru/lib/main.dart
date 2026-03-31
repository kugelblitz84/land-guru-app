import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes/app_pages.dart';
import 'core/theme/app_colors.dart';
import 'core/InitialBindings/initial_bindings.dart';
import 'package:landguru/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_isFirebaseConfiguredPlatform()) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
        final String title =
            remoteMessage.data['title'] ??
            remoteMessage.notification?.title ??
            'New Notification';
        final String body =
            remoteMessage.data['body'] ??
            remoteMessage.notification?.body ??
            'You have a new notification.';
        // Handle foreground messages
        Get.snackbar(title, body);
      });
    }
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(LandGuru(initialRoute: AppRoutes.BOOTSTRAP, prefs: prefs));
}

bool _isFirebaseConfiguredPlatform() {
  if (kIsWeb) {
    return true;
  }

  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows;
}

class LandGuru extends StatelessWidget {
  const LandGuru({super.key, required this.initialRoute, required this.prefs});

  final String initialRoute;
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 854),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          initialBinding: InitialBindings(prefs),
          title: 'LandGuru',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.white,
            fontFamily: 'Roboto',
          ),
          initialRoute: initialRoute,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
