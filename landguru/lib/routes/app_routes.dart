class AppRoutes {
  AppRoutes._();

  // AUTH - LOGIN (Common for both User and Agent)
  static const LOGIN = '/login';

  // AUTH - SIGNUP FLOW (5 Steps)
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

  // AUTH - FORGOT PASSWORD FLOW (4 Steps)
  /// Step 1: Enter phone number to receive OTP
  static const FORGOT_PASSWORD_PHONE = '/forgot-password/phone';

  /// Step 2: Verify OTP sent to phone
  static const FORGOT_PASSWORD_VERIFY_OTP = '/forgot-password/verify-otp';

  /// Step 3: Set new password
  static const FORGOT_PASSWORD_SET_PASSWORD = '/forgot-password/set-password';

  /// Step 4: Password change success confirmation
  static const FORGOT_PASSWORD_SUCCESS = '/forgot-password/success';

  // MAIN - BOTTOM NAVIGATION SHELL
  /// Main shell containing bottom navigation (Home, Properties, Appointments, My Deals, Profile)
  static const MAIN = '/main';

  // HOME / DASHBOARD
  static const HOME = '/home';

  // NOTIFICATIONS
  static const NOTIFICATIONS = '/notifications';

  // PROPERTIES - LISTING & BROWSING
  /// Properties listing main page (contains tabs: For Sale, Wanted/Needs, My Posts)
  static const PROPERTIES = '/properties';

  /// For Sale tab - Browse properties listed for sale
  static const PROPERTIES_FOR_SALE = '/properties/for-sale';

  /// Land Wanted/Needs tab - Browse buy requests from buyers
  static const PROPERTIES_WANTED = '/properties/wanted';

  /// Property details - Unified view (handles both locked and unlocked states)
  /// Pass property data as argument with 'isLocked' flag
  static const PROPERTY_DETAILS = '/properties/details';

  /// Property details - Locked view (legacy route, redirects to unified view)
  /// Pass property ID as argument
  static const PROPERTY_DETAILS_LOCKED = '/properties/details/locked';

  /// Property details - Unlocked view (legacy route, redirects to unified view)
  /// Pass property ID as argument
  static const PROPERTY_DETAILS_UNLOCKED = '/properties/details/unlocked';

  /// Buy post details - View details of a land wanted/buy request
  /// Pass buy post ID as argument
  static const BUY_POST_DETAILS = '/properties/buy-post/details';

  // PROPERTIES - MY POSTS
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

  /// Shorthand alias for buy post offer details
  static const BUY_POST_OFFER_DETAILS = MY_BUY_POST_OFFER_DETAILS;

  /// My Offered Posts listing (properties offered in response to buy requests)
  static const MY_OFFERED_POSTS = '/properties/my-posts/offered';

  /// My Offered Post details (view offer made by user)
  /// Pass offered post data as argument
  static const MY_OFFERED_POST_DETAILS = '/properties/my-posts/offered/details';

  // CREATE SELL POST FLOW (4 Steps)
  /// Step 1: Basic property info (title, description, type, location, pricing)
  static const CREATE_SELL_POST_INFO = '/create-sell-post/info';

  /// Step 2: Property visuals & documents (photos, video, deeds, khatians)
  static const CREATE_SELL_POST_MEDIA = '/create-sell-post/media';

  /// Step 3: Verification services selection (mandatory & optional)
  static const CREATE_SELL_POST_SERVICES = '/create-sell-post/services';

  /// Step 4: Review & submit for verification
  static const CREATE_SELL_POST_REVIEW = '/create-sell-post/review';

  // CREATE BUY POST FLOW (2 Steps)
  /// Step 1: Requirements (property type, size, budget, preferred location)
  static const CREATE_BUY_POST_INFO = '/create-buy-post/info';

  /// Step 2: Review requirements & submit
  static const CREATE_BUY_POST_REVIEW = '/create-buy-post/review';

  // CREATE OFFER FLOW (3 Steps) - Offer property in response to buy requests
  /// Step 1: Property details (title, description, type, location, pricing)
  static const CREATE_OFFER_INFO = '/create-offer/info';

  /// Step 2: Property photos
  static const CREATE_OFFER_MEDIA = '/create-offer/media';

  /// Step 3: Review offer & submit
  static const CREATE_OFFER_REVIEW = '/create-offer/review';

  // OFFER FROM EXISTING - Select from user's active listings to offer
  /// Select from existing active listings to offer to a buy post
  static const OFFER_FROM_EXISTING_LIST = '/offer/from-existing';

  /// View property details before confirming offer
  /// Pass property ID as argument
  static const OFFER_FROM_EXISTING_DETAILS = '/offer/from-existing/details';

  // APPOINTMENTS
  /// Appointments main page (tabs: Upcoming/Past, My Visit/Agent Visit/My Requests)
  static const APPOINTMENTS = '/appointments';

  /// My appointment requests (pending approval)
  static const APPOINTMENTS_MY_REQUESTS = '/appointments/my-requests';

  /// Upcoming visits
  static const APPOINTMENTS_UPCOMING = '/appointments/upcoming';

  /// Past visits
  static const APPOINTMENTS_PAST = '/appointments/past';

  // MY DEALS
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

  // PROFILE
  /// Profile main page (view profile info, navigation to edit/settings)
  static const PROFILE = '/profile';

  /// Edit profile information
  static const PROFILE_EDIT = '/profile/edit';

  /// Change password
  static const PROFILE_CHANGE_PASSWORD = '/profile/change-password';

  // AGENT - DASHBOARD & MAIN NAVIGATION
  /// Agent main shell with bottom navigation (Home, My Tasks, Appointments, Profile)
  static const AGENT_MAIN = '/agent/main';

  /// Agent dashboard/home (stats, requires scheduling, today's schedule)
  static const AGENT_DASHBOARD = '/agent/dashboard';

  /// Agent notifications (tabs: All, Action Required, Appointments)
  static const AGENT_NOTIFICATIONS = '/agent/notifications';

  // AGENT - MY TASKS (Service Tasks)
  /// Agent My Tasks main page (tabs: New, Active, In Review, Done)
  static const AGENT_MY_TASKS = '/agent/my-tasks';

  /// Agent task details - New task (pending acceptance)
  static const AGENT_TASK_DETAILS_NEW = '/agent/my-tasks/details/new';

  /// Agent task details - Active task (in progress)
  static const AGENT_TASK_DETAILS_ACTIVE = '/agent/my-tasks/details/active';

  /// Agent task details - In Review task (submitted for review)
  static const AGENT_TASK_DETAILS_IN_REVIEW =
      '/agent/my-tasks/details/in-review';

  /// Agent task details - Completed task
  static const AGENT_TASK_DETAILS_DONE = '/agent/my-tasks/details/done';

  // AGENT - APPOINTMENTS & VISITS
  /// Agent appointments main page
  static const AGENT_APPOINTMENTS = '/agent/appointments';

  /// Agent upcoming appointments/visits
  static const AGENT_APPOINTMENTS_UPCOMING = '/agent/appointments/upcoming';

  /// Agent past appointments/visits
  static const AGENT_APPOINTMENTS_PAST = '/agent/appointments/past';

  /// Agent appointment details
  /// Pass appointment ID as argument
  static const AGENT_APPOINTMENT_DETAILS = '/agent/appointments/details';

  /// Agent schedule new appointment
  static const AGENT_SCHEDULE_APPOINTMENT = '/agent/appointments/schedule';

  // AGENT - PROPERTIES & POSTS MANAGEMENT
  /// Agent properties listing (assigned properties)
  static const AGENT_PROPERTIES = '/agent/properties';

  /// Agent property details (assigned property)
  /// Pass property ID as argument
  static const AGENT_PROPERTY_DETAILS = '/agent/properties/details';

  /// Agent assigned posts listing
  static const AGENT_ASSIGNED_POSTS = '/agent/posts/assigned';

  /// Agent post details (assigned post)
  /// Pass post ID as argument
  static const AGENT_POST_DETAILS = '/agent/posts/details';

  // AGENT - SERVICES & VERIFICATION
  /// Agent services dashboard (pending, in-progress, completed)
  static const AGENT_SERVICES = '/agent/services';

  /// Agent service details (verification task)
  /// Pass service ID as argument
  static const AGENT_SERVICE_DETAILS = '/agent/services/details';

  /// Agent service assignment (accept/reject service)
  /// Pass service ID as argument
  static const AGENT_SERVICE_ASSIGNMENT = '/agent/services/assignment';

  /// Agent submit service report/verification
  /// Pass service ID as argument
  static const AGENT_SERVICE_SUBMIT = '/agent/services/submit';

  // AGENT - CLIENTS & DEALS
  /// Agent clients listing
  static const AGENT_CLIENTS = '/agent/clients';

  /// Agent client details
  /// Pass client ID as argument
  static const AGENT_CLIENT_DETAILS = '/agent/clients/details';

  /// Agent deals listing (properties agent is handling)
  static const AGENT_DEALS = '/agent/deals';

  /// Agent deal details
  /// Pass deal ID as argument
  static const AGENT_DEAL_DETAILS = '/agent/deals/details';

  // AGENT - REPORTS & DOCUMENTS
  /// Agent reports dashboard
  static const AGENT_REPORTS = '/agent/reports';

  /// Agent generate report
  static const AGENT_REPORTS_GENERATE = '/agent/reports/generate';

  /// Agent documents library
  static const AGENT_DOCUMENTS = '/agent/documents';

  /// Agent upload document
  static const AGENT_DOCUMENTS_UPLOAD = '/agent/documents/upload';

  // AGENT - PROFILE & SETTINGS
  /// Agent profile main page
  static const AGENT_PROFILE = '/agent/profile';

  /// Agent edit profile
  static const AGENT_PROFILE_EDIT = '/agent/profile/edit';

  /// Agent change password
  static const AGENT_PROFILE_CHANGE_PASSWORD = '/agent/profile/change-password';

  /// Agent settings
  static const AGENT_SETTINGS = '/agent/settings';

  /// Agent availability/schedule settings
  static const AGENT_SETTINGS_AVAILABILITY = '/agent/settings/availability';

  /// Agent service preferences
  static const AGENT_SETTINGS_SERVICES = '/agent/settings/services';
}
