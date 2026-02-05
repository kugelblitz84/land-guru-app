import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes/app_pages.dart';
import 'core/theme/app_colors.dart';
import 'core/InitialBindings/initial_bindings.dart';
import 'package:landguru/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(LandGuru(initialRoute: AppRoutes.BOOTSTRAP, prefs: prefs));
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
