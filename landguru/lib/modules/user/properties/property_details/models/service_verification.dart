/// Model for service verification item
class ServiceVerification {
  final String serviceName;
  final String assignedAgent;
  final String agentRole;
  final bool isVerified;

  const ServiceVerification({
    required this.serviceName,
    required this.assignedAgent,
    required this.agentRole,
    this.isVerified = false,
  });
}
