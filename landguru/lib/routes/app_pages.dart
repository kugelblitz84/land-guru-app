import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_routes.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// TODO: Import your page widgets here once created
// ═══════════════════════════════════════════════════════════════════════════════
// Auth Pages
// import '../features/auth/presentation/pages/login_page.dart';
// import '../features/auth/presentation/pages/signup/...';
// import '../features/auth/presentation/pages/forgot_password/...';
//
// Main Pages
// import '../features/main/presentation/pages/main_page.dart';
// import '../features/home/presentation/pages/home_page.dart';
// import '../features/notifications/presentation/pages/notifications_page.dart';
//
// Properties Pages
// import '../features/properties/presentation/pages/...';
//
// Appointments Pages
// import '../features/appointments/presentation/pages/...';
//
// My Deals Pages
// import '../features/my_deals/presentation/pages/...';
//
// Profile Pages
// import '../features/profile/presentation/pages/...';

/// Contains all GetPage configurations for the application.
/// Each page includes its route, page widget, and binding for dependency injection.
class AppPages {
  AppPages._();

  /// Initial route when app starts
  static const INITIAL = AppRoutes.LOGIN;

  /// All available routes/pages in the app
  static final routes = <GetPage>[
    // ═══════════════════════════════════════════════════════════════════════════
    // AUTH - LOGIN
    // ═══════════════════════════════════════════════════════════════════════════
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const Placeholder(), // TODO: Replace with LoginPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<LoginController>(() => LoginController());
      }),
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // AUTH - SIGNUP FLOW (5 Steps)
    // ═══════════════════════════════════════════════════════════════════════════
    GetPage(
      name: AppRoutes.SIGNUP_PHONE,
      page: () => const Placeholder(), // TODO: Replace with SignupPhonePage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<SignupController>(() => SignupController());
      }),
    ),
    GetPage(
      name: AppRoutes.SIGNUP_VERIFY_OTP,
      page: () =>
          const Placeholder(), // TODO: Replace with SignupVerifyOtpPage()
      binding: BindingsBuilder(() {
        // SignupController should persist from previous step
      }),
    ),
    GetPage(
      name: AppRoutes.SIGNUP_SET_PASSWORD,
      page: () =>
          const Placeholder(), // TODO: Replace with SignupSetPasswordPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.SIGNUP_PERSONAL_INFO,
      page: () =>
          const Placeholder(), // TODO: Replace with SignupPersonalInfoPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.SIGNUP_IDENTITY_VERIFICATION,
      page: () =>
          const Placeholder(), // TODO: Replace with SignupIdentityVerificationPage()
      binding: BindingsBuilder(() {}),
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // AUTH - FORGOT PASSWORD FLOW (4 Steps)
    // ═══════════════════════════════════════════════════════════════════════════
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD_PHONE,
      page: () =>
          const Placeholder(), // TODO: Replace with ForgotPasswordPhonePage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
      }),
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD_VERIFY_OTP,
      page: () =>
          const Placeholder(), // TODO: Replace with ForgotPasswordVerifyOtpPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD_SET_PASSWORD,
      page: () =>
          const Placeholder(), // TODO: Replace with ForgotPasswordSetPasswordPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD_SUCCESS,
      page: () =>
          const Placeholder(), // TODO: Replace with ForgotPasswordSuccessPage()
      binding: BindingsBuilder(() {}),
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // MAIN - BOTTOM NAVIGATION SHELL
    // ═══════════════════════════════════════════════════════════════════════════
    GetPage(
      name: AppRoutes.MAIN,
      page: () =>
          const Placeholder(), // TODO: Replace with MainPage() containing BottomNavigationBar
      binding: BindingsBuilder(() {
        // Get.lazyPut<MainController>(() => MainController());
        // Initialize all tab controllers here or lazily in each tab
      }),
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // HOME / DASHBOARD
    // ═══════════════════════════════════════════════════════════════════════════
    GetPage(
      name: AppRoutes.HOME,
      page: () => const Placeholder(), // TODO: Replace with HomePage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // NOTIFICATIONS
    // ═══════════════════════════════════════════════════════════════════════════
    GetPage(
      name: AppRoutes.NOTIFICATIONS,
      page: () => const Placeholder(), // TODO: Replace with NotificationsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<NotificationsController>(() => NotificationsController());
      }),
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // PROPERTIES - LISTING & BROWSING
    // ═══════════════════════════════════════════════════════════════════════════
    GetPage(
      name: AppRoutes.PROPERTIES,
      page: () => const Placeholder(), // TODO: Replace with PropertiesPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<PropertiesController>(() => PropertiesController());
      }),
    ),
    GetPage(
      name: AppRoutes.PROPERTIES_FOR_SALE,
      page: () =>
          const Placeholder(), // TODO: Replace with PropertiesForSalePage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.PROPERTIES_WANTED,
      page: () =>
          const Placeholder(), // TODO: Replace with PropertiesWantedPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.PROPERTY_DETAILS_LOCKED,
      page: () =>
          const Placeholder(), // TODO: Replace with PropertyDetailsLockedPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<PropertyDetailsController>(() => PropertyDetailsController());
      }),
    ),
    GetPage(
      name: AppRoutes.PROPERTY_DETAILS_UNLOCKED,
      page: () =>
          const Placeholder(), // TODO: Replace with PropertyDetailsUnlockedPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<PropertyDetailsController>(() => PropertyDetailsController());
      }),
    ),
    GetPage(
      name: AppRoutes.BUY_POST_DETAILS,
      page: () =>
          const Placeholder(), // TODO: Replace with BuyPostDetailsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<BuyPostDetailsController>(() => BuyPostDetailsController());
      }),
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // PROPERTIES - MY POSTS
    // ═══════════════════════════════════════════════════════════════════════════
    GetPage(
      name: AppRoutes.MY_POSTS,
      page: () => const Placeholder(), // TODO: Replace with MyPostsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<MyPostsController>(() => MyPostsController());
      }),
    ),
    GetPage(
      name: AppRoutes.MY_SELL_POSTS,
      page: () => const Placeholder(), // TODO: Replace with MySellPostsPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.MY_SELL_POST_DETAILS,
      page: () =>
          const Placeholder(), // TODO: Replace with MySellPostDetailsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<MySellPostDetailsController>(() => MySellPostDetailsController());
      }),
    ),
    GetPage(
      name: AppRoutes.MY_SELL_POST_QUOTED_DETAILS,
      page: () =>
          const Placeholder(), // TODO: Replace with MySellPostQuotedDetailsPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.MY_BUY_POSTS,
      page: () => const Placeholder(), // TODO: Replace with MyBuyPostsPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.MY_BUY_POST_DETAILS,
      page: () =>
          const Placeholder(), // TODO: Replace with MyBuyPostDetailsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<MyBuyPostDetailsController>(() => MyBuyPostDetailsController());
      }),
    ),
    GetPage(
      name: AppRoutes.MY_BUY_POST_OFFER_DETAILS,
      page: () =>
          const Placeholder(), // TODO: Replace with MyBuyPostOfferDetailsPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.MY_OFFERED_POSTS,
      page: () =>
          const Placeholder(), // TODO: Replace with MyOfferedPostsPage()
      binding: BindingsBuilder(() {}),
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // CREATE SELL POST FLOW (4 Steps)
    // ═══════════════════════════════════════════════════════════════════════════
    GetPage(
      name: AppRoutes.CREATE_SELL_POST_INFO,
      page: () =>
          const Placeholder(), // TODO: Replace with CreateSellPostInfoPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<CreateSellPostController>(() => CreateSellPostController());
      }),
    ),
    GetPage(
      name: AppRoutes.CREATE_SELL_POST_MEDIA,
      page: () =>
          const Placeholder(), // TODO: Replace with CreateSellPostMediaPage()
      binding: BindingsBuilder(() {
        // CreateSellPostController persists from previous step
      }),
    ),
    GetPage(
      name: AppRoutes.CREATE_SELL_POST_SERVICES,
      page: () =>
          const Placeholder(), // TODO: Replace with CreateSellPostServicesPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.CREATE_SELL_POST_REVIEW,
      page: () =>
          const Placeholder(), // TODO: Replace with CreateSellPostReviewPage()
      binding: BindingsBuilder(() {}),
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // CREATE BUY POST FLOW (2 Steps)
    // ═══════════════════════════════════════════════════════════════════════════
    GetPage(
      name: AppRoutes.CREATE_BUY_POST_INFO,
      page: () =>
          const Placeholder(), // TODO: Replace with CreateBuyPostInfoPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<CreateBuyPostController>(() => CreateBuyPostController());
      }),
    ),
    GetPage(
      name: AppRoutes.CREATE_BUY_POST_REVIEW,
      page: () =>
          const Placeholder(), // TODO: Replace with CreateBuyPostReviewPage()
      binding: BindingsBuilder(() {}),
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // CREATE OFFER FLOW (3 Steps)
    // ═══════════════════════════════════════════════════════════════════════════
    GetPage(
      name: AppRoutes.CREATE_OFFER_INFO,
      page: () =>
          const Placeholder(), // TODO: Replace with CreateOfferInfoPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<CreateOfferController>(() => CreateOfferController());
      }),
    ),
    GetPage(
      name: AppRoutes.CREATE_OFFER_MEDIA,
      page: () =>
          const Placeholder(), // TODO: Replace with CreateOfferMediaPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.CREATE_OFFER_REVIEW,
      page: () =>
          const Placeholder(), // TODO: Replace with CreateOfferReviewPage()
      binding: BindingsBuilder(() {}),
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // OFFER FROM EXISTING
    // ═══════════════════════════════════════════════════════════════════════════
    GetPage(
      name: AppRoutes.OFFER_FROM_EXISTING_LIST,
      page: () =>
          const Placeholder(), // TODO: Replace with OfferFromExistingListPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<OfferFromExistingController>(() => OfferFromExistingController());
      }),
    ),
    GetPage(
      name: AppRoutes.OFFER_FROM_EXISTING_DETAILS,
      page: () =>
          const Placeholder(), // TODO: Replace with OfferFromExistingDetailsPage()
      binding: BindingsBuilder(() {}),
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // APPOINTMENTS
    // ═══════════════════════════════════════════════════════════════════════════
    GetPage(
      name: AppRoutes.APPOINTMENTS,
      page: () => const Placeholder(), // TODO: Replace with AppointmentsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AppointmentsController>(() => AppointmentsController());
      }),
    ),
    GetPage(
      name: AppRoutes.APPOINTMENTS_MY_REQUESTS,
      page: () =>
          const Placeholder(), // TODO: Replace with AppointmentsMyRequestsPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.APPOINTMENTS_UPCOMING,
      page: () =>
          const Placeholder(), // TODO: Replace with AppointmentsUpcomingPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.APPOINTMENTS_PAST,
      page: () =>
          const Placeholder(), // TODO: Replace with AppointmentsPastPage()
      binding: BindingsBuilder(() {}),
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // MY DEALS
    // ═══════════════════════════════════════════════════════════════════════════
    GetPage(
      name: AppRoutes.MY_DEALS,
      page: () => const Placeholder(), // TODO: Replace with MyDealsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<MyDealsController>(() => MyDealsController());
      }),
    ),
    GetPage(
      name: AppRoutes.MY_DEALS_SOLD,
      page: () => const Placeholder(), // TODO: Replace with MyDealsSoldPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.MY_DEALS_SOLD_DETAILS,
      page: () =>
          const Placeholder(), // TODO: Replace with MyDealsSoldDetailsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<DealDetailsController>(() => DealDetailsController());
      }),
    ),
    GetPage(
      name: AppRoutes.MY_DEALS_BOUGHT,
      page: () => const Placeholder(), // TODO: Replace with MyDealsBoughtPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.MY_DEALS_BOUGHT_DETAILS,
      page: () =>
          const Placeholder(), // TODO: Replace with MyDealsBoughtDetailsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<DealDetailsController>(() => DealDetailsController());
      }),
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // PROFILE
    // ═══════════════════════════════════════════════════════════════════════════
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const Placeholder(), // TODO: Replace with ProfilePage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.PROFILE_EDIT,
      page: () => const Placeholder(), // TODO: Replace with ProfileEditPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<ProfileEditController>(() => ProfileEditController());
      }),
    ),
    GetPage(
      name: AppRoutes.PROFILE_CHANGE_PASSWORD,
      page: () =>
          const Placeholder(), // TODO: Replace with ProfileChangePasswordPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<ChangePasswordController>(() => ChangePasswordController());
      }),
    ),
  ];
}
