import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String type; // income, expense
  final String category;
  final String description;
  final String paymentMethod;
  final double amount;
  final DateTime date;
  final DateTime createdAt;
  final String? receiptUrl;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.category,
    required this.description,
    required this.paymentMethod,
    required this.amount,
    required this.date,
    required this.createdAt,
    this.receiptUrl,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      type: json['type'] as String? ?? 'expense',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: _parseDateTime(json['date']) ?? DateTime.now(),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      receiptUrl: json['receiptUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'category': category,
      'description': description,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'receiptUrl': receiptUrl,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? category,
    String? description,
    String? paymentMethod,
    double? amount,
    DateTime? date,
    DateTime? createdAt,
    String? receiptUrl,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      receiptUrl: receiptUrl ?? this.receiptUrl,
    );
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  @override
  String toString() {
    return 'TransactionModel(id: $id, type: $type, amount: $amount, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel && other.id == id;
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
