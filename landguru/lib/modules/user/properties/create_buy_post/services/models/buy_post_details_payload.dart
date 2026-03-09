class BuyPostDetailsPayload {
  BuyPostDetailsPayload({required this.raw});

  final Map<String, dynamic> raw;

  factory BuyPostDetailsPayload.fromJson(Map<String, dynamic> json) {
    return BuyPostDetailsPayload(raw: json);
  }

  String get id => raw['id']?.toString() ?? '';

  int? get lastCompletedStep {
    final value = raw['lastCompletedStep'];
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
