/// Enum representing different account types in the application.
/// Used for role-based UI and navigation.
enum AccountType {
  /// Regular user (buyer/seller)
  user,
  
  /// Agent (lawyer, surveyor, deed writer, field assistant)
  agent,
}

/// Extension methods for AccountType enum
extension AccountTypeExtension on AccountType {
  /// Get display name for the account type
  String get displayName {
    switch (this) {
      case AccountType.user:
        return 'User';
      case AccountType.agent:
        return 'Agent';
    }
  }

  /// Check if this is a user account
  bool get isUser => this == AccountType.user;

  /// Check if this is an agent account
  bool get isAgent => this == AccountType.agent;
}
