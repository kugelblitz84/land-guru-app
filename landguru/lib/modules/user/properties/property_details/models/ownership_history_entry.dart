/// Model for ownership history entry
class OwnershipHistoryEntry {
  final String name;
  final String period;
  final String role;
  final bool isCurrent;

  const OwnershipHistoryEntry({
    required this.name,
    required this.period,
    required this.role,
    this.isCurrent = false,
  });
}
