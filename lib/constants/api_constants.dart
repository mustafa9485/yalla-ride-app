/// ثوابت API المستخدمة في التطبيق
class ApiConstants {
  // Supabase Collections
  static const String usersTable = 'users';
  static const String driversProfileTable = 'drivers_profile';
  static const String ridesTable = 'rides';
  static const String ratingsTable = 'ratings';
  static const String regionsTable = 'regions';
  static const String pricingRulesTable = 'pricing_rules';
  static const String driverSubscriptionsTable = 'driver_subscriptions';
  static const String commissionPaymentsTable = 'commission_payments';
  
  // User Roles
  static const String passengerRole = 'passenger';
  static const String driverRole = 'driver';
  static const String adminRole = 'admin';
  
  // Driver Status
  static const String pendingApprovalStatus = 'pending_approval';
  static const String activeStatus = 'active';
  static const String suspendedStatus = 'suspended';
  
  // Ride Types
  static const String sharedRideType = 'shared';
  static const String familyRideType = 'family';
  static const String vipRideType = 'vip';
  static const String internalVipRideType = 'internal_vip';
  static const String internalLargeRideType = 'internal_large';
  
  // Ride Status
  static const String requestedStatus = 'requested';
  static const String acceptedStatus = 'accepted';
  static const String arrivedStatus = 'arrived';
  static const String startedStatus = 'started';
  static const String completedStatus = 'completed';
  static const String canceledStatus = 'canceled';
  
  // Payment Methods
  static const String cashPayment = 'cash';
  static const String zainCashPayment = 'zain_cash';
  static const String cardPayment = 'card';
  
  // Payment Status
  static const String pendingPayment = 'pending';
  static const String completedPayment = 'completed';
  static const String failedPayment = 'failed';
  
  // Region Types
  static const String cityRegion = 'city';
  static const String suburbRegion = 'suburb';
  static const String desertRegion = 'desert';
  static const String borderRegion = 'border';
  
  // Subscription Status
  static const String activeSubscription = 'active';
  static const String expiredSubscription = 'expired';
  static const String canceledSubscription = 'canceled';
}
