import 'package:cloud_firestore/cloud_firestore.dart';

class DebtModel {
  final String id;
  final String userId;
  final String personName;
  final String notes;
  final String status; // pending, partial, recovered
  final double amount;
  final double amountRecovered;
  final double interestRate;
  final DateTime dateGiven;
  final DateTime expectedReturn;

  const DebtModel({
    required this.id,
    required this.userId,
    required this.personName,
    this.notes = '',
    this.status = 'pending',
    required this.amount,
    this.amountRecovered = 0.0,
    this.interestRate = 0.0,
    required this.dateGiven,
    required this.expectedReturn,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      personName: json['personName'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      amountRecovered: (json['amountRecovered'] as num?)?.toDouble() ?? 0.0,
      interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0.0,
      dateGiven: _parseDateTime(json['dateGiven']) ?? DateTime.now(),
      expectedReturn: _parseDateTime(json['expectedReturn']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'personName': personName,
      'notes': notes,
      'status': status,
      'amount': amount,
      'amountRecovered': amountRecovered,
      'interestRate': interestRate,
      'dateGiven': Timestamp.fromDate(dateGiven),
      'expectedReturn': Timestamp.fromDate(expectedReturn),
    };
  }

  DebtModel copyWith({
    String? id,
    String? userId,
    String? personName,
    String? notes,
    String? status,
    double? amount,
    double? amountRecovered,
    double? interestRate,
    DateTime? dateGiven,
    DateTime? expectedReturn,
  }) {
    return DebtModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      personName: personName ?? this.personName,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      amountRecovered: amountRecovered ?? this.amountRecovered,
      interestRate: interestRate ?? this.interestRate,
      dateGiven: dateGiven ?? this.dateGiven,
      expectedReturn: expectedReturn ?? this.expectedReturn,
    );
  }

  double get remainingAmount => amount - amountRecovered;

  double get recoveryPercentage =>
      amount > 0 ? (amountRecovered / amount) * 100 : 0.0;

  bool get isOverdue =>
      status != 'recovered' && expectedReturn.isBefore(DateTime.now());

  bool get isPending => status == 'pending';
  bool get isPartial => status == 'partial';
  bool get isRecovered => status == 'recovered';

  @override
  String toString() {
    return 'DebtModel(id: $id, personName: $personName, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DebtModel && other.id == id;
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
