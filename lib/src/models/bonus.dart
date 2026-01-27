class BonusTransaction {
  const BonusTransaction({
    required this.id,
    required this.delta,
    required this.balanceAfter,
    required this.reason,
    required this.orderId,
    required this.createdAt,
  });

  final int id;
  final int delta;
  final int balanceAfter;
  final String reason;
  final int? orderId;
  final DateTime? createdAt;

  factory BonusTransaction.fromJson(Map<String, dynamic> json) {
    return BonusTransaction(
      id: _asInt(json['id']),
      delta: _asInt(json['delta']),
      balanceAfter: _asInt(json['balance_after']),
      reason: _asString(json['reason']),
      orderId: _asNullableInt(json['order_id']),
      createdAt: _asDate(json['created_at']),
    );
  }
}

class BonusBalance {
  const BonusBalance({
    required this.balance,
    required this.transactions,
  });

  final int balance;
  final List<BonusTransaction> transactions;

  factory BonusBalance.fromJson(Map<String, dynamic> json) {
    final list = json['transactions'];
    final items = list is List
        ? list
            .whereType<Map<String, dynamic>>()
            .map(BonusTransaction.fromJson)
            .toList(growable: false)
        : <BonusTransaction>[];
    return BonusBalance(
      balance: _asInt(json['balance']),
      transactions: items,
    );
  }
}

int _asInt(Object? value) => value is num ? value.toInt() : 0;

int? _asNullableInt(Object? value) => value is num ? value.toInt() : null;

String _asString(Object? value) => value?.toString() ?? '';

DateTime? _asDate(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
