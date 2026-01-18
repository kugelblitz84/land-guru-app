import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_routes.dart';

// Auth Pages
import '../modules/auth/login/login_view.dart';
import '../modules/auth/login/login_controller.dart';
import '../modules/auth/signup/signup_controller.dart';
import '../modules/auth/signup/views/signup_phone_view.dart';
import '../modules/auth/signup/views/signup_otp_view.dart';
import '../modules/auth/signup/views/signup_password_view.dart';
import '../modules/auth/signup/views/signup_personal_info_view.dart';
import '../modules/auth/signup/views/signup_identity_view.dart';
import '../modules/auth/forgot_password/forgot_password_controller.dart';
import '../modules/auth/forgot_password/views/forgot_password_phone_view.dart';
import '../modules/auth/forgot_password/views/forgot_password_otp_view.dart';
import '../modules/auth/forgot_password/views/forgot_password_new_password_view.dart';
import '../modules/auth/forgot_password/views/forgot_password_success_view.dart';

// User Main Pages
import '../modules/shared/bottom_nav/user_bottom_nav_view.dart';
import '../modules/shared/bottom_nav/user_bottom_nav_controller.dart';
import '../modules/user/home/home_view.dart';
import '../modules/user/home/home_controller.dart';

// Shared Notifications (used by both User and Agent)
import '../modules/shared/notifications/notifications_view.dart';
import '../modules/shared/notifications/notifications_controller.dart';

// Create Buy Post
import '../modules/user/properties/create_buy_post/create_buy_post_view.dart';
import '../modules/user/properties/create_buy_post/create_buy_post_controller.dart';

// Create Sell Post
import '../modules/user/properties/create_sell_post/create_sell_post_view.dart';
import '../modules/user/properties/create_sell_post/create_sell_post_controller.dart';

// Create Offer
import '../modules/user/properties/create_offer/create_offer_view.dart';
import '../modules/user/properties/create_offer/create_offer_controller.dart';

// Property Details
import '../modules/user/properties/property_details/property_details_controller.dart';
import '../modules/user/properties/property_details/property_details_locked_view.dart';
import '../modules/user/properties/property_details/property_details_unlocked_view.dart';

/// Contains all GetPage configurations for the application.
/// Each page includes its route, page widget, and binding for dependency injection.
class AppPages {
  AppPages._();

  /// Initial route when app starts
  static const INITIAL = AppRoutes.LOGIN;

  /// All available routes/pages in the app
  static final routes = <GetPage>[
    // AUTH - LOGIN (Common for both User and Agent)
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController());
      }),
    ),

    // AUTH - SIGNUP FLOW (4 Steps)
    GetPage(
      name: AppRoutes.SIGNUP_PHONE,
      page: () => const SignupPhoneView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SignupController>(() => SignupController());
      }),
    ),
    GetPage(
      name: AppRoutes.SIGNUP_VERIFY_OTP,
      page: () => const SignupOtpView(),
      binding: BindingsBuilder(() {
        // SignupController persists from previous step
      }),
    ),
    GetPage(
      name: AppRoutes.SIGNUP_SET_PASSWORD,
      page: () => const SignupPasswordView(),
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.SIGNUP_PERSONAL_INFO,
      page: () => const SignupPersonalInfoView(),
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.SIGNUP_IDENTITY_VERIFICATION,
      page: () => const SignupIdentityView(),
      binding: BindingsBuilder(() {}),
    ),

    // AUTH - FORGOT PASSWORD FLOW (4 Steps)
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD_PHONE,
      page: () => const ForgotPasswordPhoneView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
      }),
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD_VERIFY_OTP,
      page: () => const ForgotPasswordOtpView(),
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD_SET_PASSWORD,
      page: () => const ForgotPasswordNewPasswordView(),
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD_SUCCESS,
      page: () => const ForgotPasswordSuccessView(),
      binding: BindingsBuilder(() {}),
    ),

    // MAIN - BOTTOM NAVIGATION SHELL
    GetPage(
      name: AppRoutes.MAIN,
      page: () => const UserBottomNavView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<UserBottomNavController>(() => UserBottomNavController());
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),

    // HOME / DASHBOARD
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),

    // NOTIFICATIONS
    GetPage(
      name: AppRoutes.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NotificationsController>(() => NotificationsController());
      }),
    ),

    // PROPERTIES - LISTING & BROWSING
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
      page: () => const PropertyDetailsLockedView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PropertyDetailsController>(() => PropertyDetailsController());
      }),
    ),
    GetPage(
      name: AppRoutes.PROPERTY_DETAILS_UNLOCKED,
      page: () => const PropertyDetailsUnlockedView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PropertyDetailsController>(() => PropertyDetailsController());
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

    // PROPERTIES - MY POSTS
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

    // CREATE SELL POST FLOW (4 Steps) - Single route with step-based view
    GetPage(
      name: AppRoutes.CREATE_SELL_POST_INFO,
      page: () => const CreateSellPostView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CreateSellPostController>(() => CreateSellPostController());
      }),
    ),
    // These routes redirect to the main view (controller persists)
    GetPage(
      name: AppRoutes.CREATE_SELL_POST_MEDIA,
      page: () => const CreateSellPostView(),
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.CREATE_SELL_POST_SERVICES,
      page: () => const CreateSellPostView(),
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.CREATE_SELL_POST_REVIEW,
      page: () => const CreateSellPostView(),
      binding: BindingsBuilder(() {}),
    ),

    // CREATE BUY POST FLOW (2 Steps) - Single route with step-based view
    GetPage(
      name: AppRoutes.CREATE_BUY_POST_INFO,
      page: () => const CreateBuyPostView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CreateBuyPostController>(() => CreateBuyPostController());
      }),
    ),
    GetPage(
      name: AppRoutes.CREATE_BUY_POST_REVIEW,
      page: () => const CreateBuyPostView(),
      binding: BindingsBuilder(() {}),
    ),

    // CREATE OFFER FLOW (3 Steps) - Single route with step-based view
    GetPage(
      name: AppRoutes.CREATE_OFFER_INFO,
      page: () => const CreateOfferView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CreateOfferController>(() => CreateOfferController());
      }),
    ),
    GetPage(
      name: AppRoutes.CREATE_OFFER_MEDIA,
      page: () => const CreateOfferView(),
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.CREATE_OFFER_REVIEW,
      page: () => const CreateOfferView(),
      binding: BindingsBuilder(() {}),
    ),

    // OFFER FROM EXISTING
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

    // APPOINTMENTS
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

    // MY DEALS
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

    // PROFILE
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

    // AGENT - MAIN NAVIGATION SHELL
    GetPage(
      name: AppRoutes.AGENT_MAIN,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentMainPage() containing BottomNavigationBar
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentMainController>(() => AgentMainController());
      }),
    ),

    // AGENT - DASHBOARD / HOME
    GetPage(
      name: AppRoutes.AGENT_DASHBOARD,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentDashboardPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentDashboardController>(() => AgentDashboardController());
      }),
    ),

    // AGENT - NOTIFICATIONS (uses shared NotificationsView)
    GetPage(
      name: AppRoutes.AGENT_NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NotificationsController>(() => NotificationsController());
      }),
    ),

    // AGENT - MY TASKS
    GetPage(
      name: AppRoutes.AGENT_MY_TASKS,
      page: () => const Placeholder(), // TODO: Replace with AgentMyTasksPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentMyTasksController>(() => AgentMyTasksController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_TASK_DETAILS_NEW,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentTaskDetailsNewPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentTaskDetailsController>(() => AgentTaskDetailsController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_TASK_DETAILS_ACTIVE,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentTaskDetailsActivePage()
      binding: BindingsBuilder(() {
        // AgentTaskDetailsController should persist or be reused
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_TASK_DETAILS_IN_REVIEW,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentTaskDetailsInReviewPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.AGENT_TASK_DETAILS_DONE,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentTaskDetailsDonePage()
      binding: BindingsBuilder(() {}),
    ),

    // AGENT - APPOINTMENTS
    GetPage(
      name: AppRoutes.AGENT_APPOINTMENTS,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentAppointmentsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentAppointmentsController>(() => AgentAppointmentsController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_APPOINTMENTS_UPCOMING,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentAppointmentsUpcomingPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.AGENT_APPOINTMENTS_PAST,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentAppointmentsPastPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.AGENT_APPOINTMENT_DETAILS,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentAppointmentDetailsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentAppointmentDetailsController>(() => AgentAppointmentDetailsController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_SCHEDULE_APPOINTMENT,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentScheduleAppointmentPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentScheduleAppointmentController>(() => AgentScheduleAppointmentController());
      }),
    ),

    // AGENT - PROPERTIES & POSTS (if needed for future features)
    GetPage(
      name: AppRoutes.AGENT_PROPERTIES,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentPropertiesPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentPropertiesController>(() => AgentPropertiesController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_PROPERTY_DETAILS,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentPropertyDetailsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentPropertyDetailsController>(() => AgentPropertyDetailsController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_ASSIGNED_POSTS,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentAssignedPostsPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.AGENT_POST_DETAILS,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentPostDetailsPage()
      binding: BindingsBuilder(() {}),
    ),

    // AGENT - SERVICES & VERIFICATION
    GetPage(
      name: AppRoutes.AGENT_SERVICES,
      page: () => const Placeholder(), // TODO: Replace with AgentServicesPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentServicesController>(() => AgentServicesController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_SERVICE_DETAILS,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentServiceDetailsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentServiceDetailsController>(() => AgentServiceDetailsController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_SERVICE_ASSIGNMENT,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentServiceAssignmentPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.AGENT_SERVICE_SUBMIT,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentServiceSubmitPage()
      binding: BindingsBuilder(() {}),
    ),

    // AGENT - CLIENTS & DEALS
    GetPage(
      name: AppRoutes.AGENT_CLIENTS,
      page: () => const Placeholder(), // TODO: Replace with AgentClientsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentClientsController>(() => AgentClientsController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_CLIENT_DETAILS,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentClientDetailsPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.AGENT_DEALS,
      page: () => const Placeholder(), // TODO: Replace with AgentDealsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentDealsController>(() => AgentDealsController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_DEAL_DETAILS,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentDealDetailsPage()
      binding: BindingsBuilder(() {}),
    ),

    // AGENT - REPORTS & DOCUMENTS
    GetPage(
      name: AppRoutes.AGENT_REPORTS,
      page: () => const Placeholder(), // TODO: Replace with AgentReportsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentReportsController>(() => AgentReportsController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_REPORTS_GENERATE,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentReportsGeneratePage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.AGENT_DOCUMENTS,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentDocumentsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentDocumentsController>(() => AgentDocumentsController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_DOCUMENTS_UPLOAD,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentDocumentsUploadPage()
      binding: BindingsBuilder(() {}),
    ),

    // AGENT - PROFILE & SETTINGS
    GetPage(
      name: AppRoutes.AGENT_PROFILE,
      page: () => const Placeholder(), // TODO: Replace with AgentProfilePage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentProfileController>(() => AgentProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_PROFILE_EDIT,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentProfileEditPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentProfileEditController>(() => AgentProfileEditController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_PROFILE_CHANGE_PASSWORD,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentProfileChangePasswordPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentChangePasswordController>(() => AgentChangePasswordController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_SETTINGS,
      page: () => const Placeholder(), // TODO: Replace with AgentSettingsPage()
      binding: BindingsBuilder(() {
        // Get.lazyPut<AgentSettingsController>(() => AgentSettingsController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_SETTINGS_AVAILABILITY,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentSettingsAvailabilityPage()
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.AGENT_SETTINGS_SERVICES,
      page: () =>
          const Placeholder(), // TODO: Replace with AgentSettingsServicesPage()
      binding: BindingsBuilder(() {}),
    ),
  ];
}
