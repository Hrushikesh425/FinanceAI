import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  final String id;
  final String userId;
  final String name;
  final String billingCycle; // monthly, quarterly, yearly
  final String category;
  final String status; // active, paused, cancelled
  final double amount;
  final DateTime renewalDate;
  final DateTime startDate;
  final bool autoRenewal;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.name,
    this.billingCycle = 'monthly',
    required this.category,
    this.status = 'active',
    required this.amount,
    required this.renewalDate,
    required this.startDate,
    this.autoRenewal = true,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      billingCycle: json['billingCycle'] as String? ?? 'monthly',
      category: json['category'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      renewalDate: _parseDateTime(json['renewalDate']) ?? DateTime.now(),
      startDate: _parseDateTime(json['startDate']) ?? DateTime.now(),
      autoRenewal: json['autoRenewal'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'billingCycle': billingCycle,
      'category': category,
      'status': status,
      'amount': amount,
      'renewalDate': Timestamp.fromDate(renewalDate),
      'startDate': Timestamp.fromDate(startDate),
      'autoRenewal': autoRenewal,
    };
  }

  SubscriptionModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? billingCycle,
    String? category,
    String? status,
    double? amount,
    DateTime? renewalDate,
    DateTime? startDate,
    bool? autoRenewal,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      billingCycle: billingCycle ?? this.billingCycle,
      category: category ?? this.category,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      renewalDate: renewalDate ?? this.renewalDate,
      startDate: startDate ?? this.startDate,
      autoRenewal: autoRenewal ?? this.autoRenewal,
    );
  }

  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';
  bool get isCancelled => status == 'cancelled';

  bool get isRenewalDue => renewalDate.isBefore(DateTime.now());

  int get daysUntilRenewal => renewalDate.difference(DateTime.now()).inDays;

  double get monthlyEquivalent {
    switch (billingCycle) {
      case 'yearly':
        return amount / 12;
      case 'quarterly':
        return amount / 3;
      case 'monthly':
      default:
        return amount;
    }
  }

  double get yearlyEquivalent {
    switch (billingCycle) {
      case 'monthly':
        return amount * 12;
      case 'quarterly':
        return amount * 4;
      case 'yearly':
      default:
        return amount;
    }
  }

  @override
  String toString() {
    return 'SubscriptionModel(id: $id, name: $name, amount: $amount, billingCycle: $billingCycle)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
