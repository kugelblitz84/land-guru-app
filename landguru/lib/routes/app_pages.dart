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
import '../modules/auth/forgot_password/views/forgot_password_agent_request_sent_view.dart';

// Bootstrap
import '../core/Bootstrap/bootstrap_view.dart';
import '../core/Bootstrap/bootstrap_controller.dart';

// User Main Pages
import '../modules/shared/bottom_nav/user_bottom_nav_view.dart';
import '../modules/shared/bottom_nav/user_bottom_nav_controller.dart';

// Agent Main Pages
import '../modules/shared/bottom_nav/agent_bottom_nav_view.dart';
import '../modules/shared/bottom_nav/agent_bottom_nav_controller.dart';
import '../modules/shared/shell/agent_shell_controller.dart';
import '../modules/shared/shell/main_shell_controller.dart';
import '../modules/agent/dashboard/agent_dashboard_controller.dart';
import '../modules/agent/dashboard/agent_dashboard_view.dart';
import '../modules/agent/appointments/agent_appointments_controller.dart';
import '../modules/agent/appointments/agent_appointments_view.dart';
import '../modules/agent/my_tasks/my_tasks_controller.dart';
import '../modules/agent/my_tasks/task_details_controller.dart';
import '../modules/agent/my_tasks/task_details_view.dart';
import '../modules/agent/profile/agent_profile_controller.dart';
import '../modules/agent/profile/agent_edit_profile_controller.dart';
import '../modules/agent/profile/agent_edit_profile_view.dart';
import '../modules/user/home/home_view.dart';
import '../modules/user/home/home_controller.dart';
import '../modules/user/profile/profile_controller.dart';
import '../modules/user/properties/properties_controller.dart';

// User Appointments
import '../modules/user/appointments/appointments_view.dart';
import '../modules/user/appointments/appointments_controller.dart';

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
import '../modules/user/properties/wanted_and_needs/create_offer/create_offer_view.dart';
import '../modules/user/properties/wanted_and_needs/create_offer/create_offer_controller.dart';

// Offer from Existing
import '../modules/user/properties/wanted_and_needs/offer_from_existing/offer_from_existing_view.dart';
import '../modules/user/properties/wanted_and_needs/offer_from_existing/offer_from_existing_controller.dart';

// Property Details
import '../modules/user/properties/property_details/property_details_controller.dart';
import '../modules/user/properties/property_details/property_details_view.dart';

// Sell Post Details (My Posts)
import '../modules/user/properties/my_posts/sell_posts/sell_post_details_view.dart';
import '../modules/user/properties/my_posts/sell_posts/sell_post_details_controller.dart';

// Buy Post Offer Details (My Posts)
import '../modules/user/properties/my_posts/buy_posts/buy_post_offer_details_view.dart';

// Offered Post Details (My Posts)
import '../modules/user/properties/my_posts/offered_posts/offered_post_details_view.dart';

// My Deals
import '../modules/user/my_deals/my_deals_view.dart';
import '../modules/user/my_deals/my_deals_controller.dart';
import '../modules/user/my_deals/deal_details_view.dart';

// User Profile
import '../modules/user/profile/profile_view.dart';
import '../modules/user/profile/edit_profile_view.dart';
import '../modules/user/profile/edit_profile_controller.dart';
import '../modules/user/profile/change_password_view.dart';
import '../modules/user/profile/change_password_controller.dart';

/// Contains all GetPage configurations for the application.
/// Each page includes its route, page widget, and binding for dependency injection.
class AppPages {
  AppPages._();

  /// Initial route when app starts
  static const INITIAL = AppRoutes.BOOTSTRAP;

  /// All available routes/pages in the app
  static final routes = <GetPage>[
    // BOOTSTRAP
    GetPage(
      name: AppRoutes.BOOTSTRAP,
      page: () => const BootstrapView(),
      binding: BootstrapBinding(),
    ),
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

    // AUTH - FORGOT PASSWORD FLOW
    // User: 4 Steps (Phone → OTP → New Password → Success)
    // Agent: 2 Steps (Phone → Request Sent)
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
    // Agent-specific: Password reset request sent
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD_AGENT_REQUEST_SENT,
      page: () => const ForgotPasswordAgentRequestSentView(),
      binding: BindingsBuilder(() {}),
    ),

    // MAIN - BOTTOM NAVIGATION SHELL
    GetPage(
      name: AppRoutes.MAIN,
      page: () => const UserBottomNavView(),
      binding: BindingsBuilder(() {
        // Initialize shared shell controller
        Get.put<MainShellController>(MainShellController(), permanent: true);

        // Ensure tab-specific controllers are available
        Get.lazyPut<UserBottomNavController>(() => UserBottomNavController());
        Get.lazyPut<HomeController>(() => HomeController());
        Get.lazyPut<ProfileController>(() => ProfileController());
        Get.lazyPut<PropertiesController>(() => PropertiesController());
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

    // PROPERTY DETAILS - Unified view (handles both locked and unlocked states)
    GetPage(
      name: AppRoutes.PROPERTY_DETAILS,
      page: () => const PropertyDetailsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PropertyDetailsController>(
          () => PropertyDetailsController(),
        );
      }),
    ),
    // Legacy routes - redirect to unified view
    GetPage(
      name: AppRoutes.PROPERTY_DETAILS_LOCKED,
      page: () => const PropertyDetailsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PropertyDetailsController>(
          () => PropertyDetailsController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.PROPERTY_DETAILS_UNLOCKED,
      page: () => const PropertyDetailsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PropertyDetailsController>(
          () => PropertyDetailsController(),
        );
      }),
    ),

    // MY POSTS - SELL POST DETAILS
    GetPage(
      name: AppRoutes.MY_SELL_POST_DETAILS,
      page: () => const SellPostDetailsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SellPostDetailsController>(
          () => SellPostDetailsController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.MY_SELL_POST_QUOTED_DETAILS,
      page: () => const SellPostDetailsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SellPostDetailsController>(
          () => SellPostDetailsController(),
        );
      }),
    ),

    // MY POSTS - BUY POST OFFER DETAILS
    GetPage(
      name: AppRoutes.MY_BUY_POST_OFFER_DETAILS,
      page: () => const BuyPostOfferDetailsView(),
      binding: BindingsBuilder(() {}),
    ),

    // MY POSTS - OFFERED POST DETAILS
    GetPage(
      name: AppRoutes.MY_OFFERED_POST_DETAILS,
      page: () => const OfferedPostDetailsView(),
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
        final args = Get.arguments as Map<String, dynamic>?;
        final controller = CreateOfferController();
        if (args != null) {
          controller.initWithBuyPost(
            args['postId'] ?? '',
            args['postTitle'] ?? '',
          );
        }
        Get.put<CreateOfferController>(controller);
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
      page: () => const OfferFromExistingView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OfferFromExistingController>(
          () => OfferFromExistingController(),
        );
      }),
    ),

    // APPOINTMENTS
    GetPage(
      name: AppRoutes.APPOINTMENTS,
      page: () => const AppointmentsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AppointmentsController>(() => AppointmentsController());
      }),
    ),

    // MY DEALS
    GetPage(
      name: AppRoutes.MY_DEALS,
      page: () => const MyDealsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MyDealsController>(() => MyDealsController());
      }),
    ),
    GetPage(
      name: AppRoutes.MY_DEALS_SOLD,
      page: () => const MyDealsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MyDealsController>(() => MyDealsController());
      }),
    ),
    GetPage(
      name: AppRoutes.MY_DEALS_SOLD_DETAILS,
      page: () => const DealDetailsView(),
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: AppRoutes.MY_DEALS_BOUGHT,
      page: () => const MyDealsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MyDealsController>(() => MyDealsController());
      }),
    ),
    GetPage(
      name: AppRoutes.MY_DEALS_BOUGHT_DETAILS,
      page: () => const DealDetailsView(),
      binding: BindingsBuilder(() {}),
    ),

    // USER PROFILE
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.PROFILE_EDIT,
      page: () => const EditProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EditProfileController>(() => EditProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.PROFILE_CHANGE_PASSWORD,
      page: () => const ChangePasswordView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ChangePasswordController>(() => ChangePasswordController());
      }),
    ),

    // ==========================================
    // AGENT ROUTES
    // ==========================================

    // AGENT - MAIN NAVIGATION SHELL
    GetPage(
      name: AppRoutes.AGENT_MAIN,
      page: () => const AgentBottomNavView(),
      binding: BindingsBuilder(() {
        // Initialize agent shell controller (shared across tabs)
        Get.put<AgentShellController>(AgentShellController(), permanent: true);
        Get.lazyPut<AgentBottomNavController>(() => AgentBottomNavController());
        // Initialize dashboard controller for Home tab
        Get.lazyPut<AgentDashboardController>(() => AgentDashboardController());
        // Initialize my tasks controller for My Tasks tab
        Get.lazyPut<AgentMyTasksController>(() => AgentMyTasksController());
        // Initialize appointments controller for Appointments tab
        Get.lazyPut<AgentAppointmentsController>(
          () => AgentAppointmentsController(),
        );
        // Initialize profile controller for Profile tab
        Get.lazyPut<AgentProfileController>(() => AgentProfileController());
      }),
    ),

    // AGENT - DASHBOARD / HOME
    GetPage(
      name: AppRoutes.AGENT_DASHBOARD,
      page: () => const AgentDashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AgentDashboardController>(() => AgentDashboardController());
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

    // AGENT - TASK DETAILS (for all task states)
    GetPage(
      name: AppRoutes.AGENT_TASK_DETAILS_NEW,
      page: () => const AgentTaskDetailsView(),
      binding: BindingsBuilder(() {
        Get.delete<AgentTaskDetailsController>(force: true);
        Get.put<AgentTaskDetailsController>(AgentTaskDetailsController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_TASK_DETAILS_ACTIVE,
      page: () => const AgentTaskDetailsView(),
      binding: BindingsBuilder(() {
        Get.delete<AgentTaskDetailsController>(force: true);
        Get.put<AgentTaskDetailsController>(AgentTaskDetailsController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_TASK_DETAILS_IN_REVIEW,
      page: () => const AgentTaskDetailsView(),
      binding: BindingsBuilder(() {
        Get.delete<AgentTaskDetailsController>(force: true);
        Get.put<AgentTaskDetailsController>(AgentTaskDetailsController());
      }),
    ),
    GetPage(
      name: AppRoutes.AGENT_TASK_DETAILS_DONE,
      page: () => const AgentTaskDetailsView(),
      binding: BindingsBuilder(() {
        Get.delete<AgentTaskDetailsController>(force: true);
        Get.put<AgentTaskDetailsController>(AgentTaskDetailsController());
      }),
    ),

    // AGENT - APPOINTMENTS
    GetPage(
      name: AppRoutes.AGENT_APPOINTMENTS,
      page: () => const AgentAppointmentsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AgentAppointmentsController>(
          () => AgentAppointmentsController(),
        );
      }),
    ),

    // AGENT - PROFILE EDIT
    GetPage(
      name: AppRoutes.AGENT_PROFILE_EDIT,
      page: () => const AgentEditProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AgentEditProfileController>(
          () => AgentEditProfileController(),
        );
      }),
    ),
  ];
}
