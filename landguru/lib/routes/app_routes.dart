/// Contains all route names used in the application.
/// Use these constants with Get.toNamed() for navigation.
///
/// Route naming conventions:
/// - Use kebab-case for URL paths
/// - Group related routes under common prefixes
/// - Use :id for dynamic route parameters
abstract class AppRoutes {
  AppRoutes._();

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH - LOGIN
  // ═══════════════════════════════════════════════════════════════════════════
  static const LOGIN = '/login';

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH - SIGNUP FLOW (5 Steps)
  // ═══════════════════════════════════════════════════════════════════════════
  /// Step 1: Enter phone number to receive OTP
  static const SIGNUP_PHONE = '/signup/phone';

  /// Step 2: Verify OTP sent to phone
  static const SIGNUP_VERIFY_OTP = '/signup/verify-otp';

  /// Step 3: Set account password
  static const SIGNUP_SET_PASSWORD = '/signup/set-password';

  /// Step 4: Enter personal information (name, email, address, photo)
  static const SIGNUP_PERSONAL_INFO = '/signup/personal-info';

  /// Step 5: Upload identity documents (NID, TIN Certificate)
  static const SIGNUP_IDENTITY_VERIFICATION = '/signup/identity-verification';

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH - FORGOT PASSWORD FLOW (4 Steps)
  // ═══════════════════════════════════════════════════════════════════════════
  /// Step 1: Enter phone number to receive OTP
  static const FORGOT_PASSWORD_PHONE = '/forgot-password/phone';

  /// Step 2: Verify OTP sent to phone
  static const FORGOT_PASSWORD_VERIFY_OTP = '/forgot-password/verify-otp';

  /// Step 3: Set new password
  static const FORGOT_PASSWORD_SET_PASSWORD = '/forgot-password/set-password';

  /// Step 4: Password change success confirmation
  static const FORGOT_PASSWORD_SUCCESS = '/forgot-password/success';

  // ═══════════════════════════════════════════════════════════════════════════
  // MAIN - BOTTOM NAVIGATION SHELL
  // ═══════════════════════════════════════════════════════════════════════════
  /// Main shell containing bottom navigation (Home, Properties, Appointments, My Deals, Profile)
  static const MAIN = '/main';

  // ═══════════════════════════════════════════════════════════════════════════
  // HOME / DASHBOARD
  // ═══════════════════════════════════════════════════════════════════════════
  static const HOME = '/home';

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const NOTIFICATIONS = '/notifications';

  // ═══════════════════════════════════════════════════════════════════════════
  // PROPERTIES - LISTING & BROWSING
  // ═══════════════════════════════════════════════════════════════════════════
  /// Properties listing main page (contains tabs: For Sale, Wanted/Needs, My Posts)
  static const PROPERTIES = '/properties';

  /// For Sale tab - Browse properties listed for sale
  static const PROPERTIES_FOR_SALE = '/properties/for-sale';

  /// Land Wanted/Needs tab - Browse buy requests from buyers
  static const PROPERTIES_WANTED = '/properties/wanted';

  /// Property details - Locked view (before unlocking features)
  /// Pass property ID as argument
  static const PROPERTY_DETAILS_LOCKED = '/properties/details/locked';

  /// Property details - Unlocked view (after paying to unlock features)
  /// Pass property ID as argument
  static const PROPERTY_DETAILS_UNLOCKED = '/properties/details/unlocked';

  /// Buy post details - View details of a land wanted/buy request
  /// Pass buy post ID as argument
  static const BUY_POST_DETAILS = '/properties/buy-post/details';

  // ═══════════════════════════════════════════════════════════════════════════
  // PROPERTIES - MY POSTS
  // ═══════════════════════════════════════════════════════════════════════════
  /// My Posts main page (contains tabs: Sell Posts, Buy Posts, Offered Posts)
  static const MY_POSTS = '/properties/my-posts';

  /// My Sell Posts listing (All, Pending, Quoted, Active, Draft statuses)
  static const MY_SELL_POSTS = '/properties/my-posts/sell';

  /// My Sell Post details (own property)
  /// Pass post ID as argument
  static const MY_SELL_POST_DETAILS = '/properties/my-posts/sell/details';

  /// My Sell Post details - Quoted status (with bill breakdown, pay/requote options)
  /// Pass post ID as argument
  static const MY_SELL_POST_QUOTED_DETAILS =
      '/properties/my-posts/sell/quoted/details';

  /// My Buy Posts listing (with offers received)
  static const MY_BUY_POSTS = '/properties/my-posts/buy';

  /// My Buy Post details (view offers received)
  /// Pass post ID as argument
  static const MY_BUY_POST_DETAILS = '/properties/my-posts/buy/details';

  /// Offer details from a buy post (view property offered by seller)
  /// Pass offer ID as argument
  static const MY_BUY_POST_OFFER_DETAILS =
      '/properties/my-posts/buy/offer/details';

  /// My Offered Posts listing (properties offered in response to buy requests)
  static const MY_OFFERED_POSTS = '/properties/my-posts/offered';

  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE SELL POST FLOW (4 Steps)
  // ═══════════════════════════════════════════════════════════════════════════
  /// Step 1: Basic property info (title, description, type, location, pricing)
  static const CREATE_SELL_POST_INFO = '/create-sell-post/info';

  /// Step 2: Property visuals & documents (photos, video, deeds, khatians)
  static const CREATE_SELL_POST_MEDIA = '/create-sell-post/media';

  /// Step 3: Verification services selection (mandatory & optional)
  static const CREATE_SELL_POST_SERVICES = '/create-sell-post/services';

  /// Step 4: Review & submit for verification
  static const CREATE_SELL_POST_REVIEW = '/create-sell-post/review';

  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE BUY POST FLOW (2 Steps)
  // ═══════════════════════════════════════════════════════════════════════════
  /// Step 1: Requirements (property type, size, budget, preferred location)
  static const CREATE_BUY_POST_INFO = '/create-buy-post/info';

  /// Step 2: Review requirements & submit
  static const CREATE_BUY_POST_REVIEW = '/create-buy-post/review';

  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE OFFER FLOW (3 Steps) - Offer property in response to buy requests
  // ═══════════════════════════════════════════════════════════════════════════
  /// Step 1: Property details (title, description, type, location, pricing)
  static const CREATE_OFFER_INFO = '/create-offer/info';

  /// Step 2: Property photos
  static const CREATE_OFFER_MEDIA = '/create-offer/media';

  /// Step 3: Review offer & submit
  static const CREATE_OFFER_REVIEW = '/create-offer/review';

  // ═══════════════════════════════════════════════════════════════════════════
  // OFFER FROM EXISTING - Select from user's active listings to offer
  // ═══════════════════════════════════════════════════════════════════════════
  /// Select from existing active listings to offer to a buy post
  static const OFFER_FROM_EXISTING_LIST = '/offer/from-existing';

  /// View property details before confirming offer
  /// Pass property ID as argument
  static const OFFER_FROM_EXISTING_DETAILS = '/offer/from-existing/details';

  // ═══════════════════════════════════════════════════════════════════════════
  // APPOINTMENTS
  // ═══════════════════════════════════════════════════════════════════════════
  /// Appointments main page (tabs: Upcoming/Past, My Visit/Agent Visit/My Requests)
  static const APPOINTMENTS = '/appointments';

  /// My appointment requests (pending approval)
  static const APPOINTMENTS_MY_REQUESTS = '/appointments/my-requests';

  /// Upcoming visits
  static const APPOINTMENTS_UPCOMING = '/appointments/upcoming';

  /// Past visits
  static const APPOINTMENTS_PAST = '/appointments/past';

  // ═══════════════════════════════════════════════════════════════════════════
  // MY DEALS
  // ═══════════════════════════════════════════════════════════════════════════
  /// My Deals main page (tabs: Sold, Bought)
  static const MY_DEALS = '/my-deals';

  /// Sold properties listing
  static const MY_DEALS_SOLD = '/my-deals/sold';

  /// Sold property details
  /// Pass deal ID as argument
  static const MY_DEALS_SOLD_DETAILS = '/my-deals/sold/details';

  /// Bought properties listing
  static const MY_DEALS_BOUGHT = '/my-deals/bought';

  /// Bought property details
  /// Pass deal ID as argument
  static const MY_DEALS_BOUGHT_DETAILS = '/my-deals/bought/details';

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════════════════════
  /// Profile main page (view profile info, navigation to edit/settings)
  static const PROFILE = '/profile';

  /// Edit profile information
  static const PROFILE_EDIT = '/profile/edit';

  /// Change password
  static const PROFILE_CHANGE_PASSWORD = '/profile/change-password';

  // ═══════════════════════════════════════════════════════════════════════════
  // AGENT SPECIFIC ROUTES (Future expansion)
  // ═══════════════════════════════════════════════════════════════════════════
  // TODO: Add agent-specific routes when agent UI designs are available
  // static const AGENT_DASHBOARD = '/agent/dashboard';
  // static const AGENT_APPOINTMENTS = '/agent/appointments';
  // static const AGENT_CLIENTS = '/agent/clients';
}
