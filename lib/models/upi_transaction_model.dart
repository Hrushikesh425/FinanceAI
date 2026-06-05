import 'package:cloud_firestore/cloud_firestore.dart';

class UpiTransactionModel {
  final String id;
  final String userId;
  final String app; // gpay, phonepe, paytm, other
  final String merchantName;
  final String upiId;
  final String transactionId;
  final String type; // sent, received
  final String category;
  final String status;
  final double amount;
  final DateTime date;

  const UpiTransactionModel({
    required this.id,
    required this.userId,
    required this.app,
    required this.merchantName,
    required this.upiId,
    required this.transactionId,
    required this.type,
    this.category = '',
    this.status = 'completed',
    required this.amount,
    required this.date,
  });

  factory UpiTransactionModel.fromJson(Map<String, dynamic> json) {
    return UpiTransactionModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      app: json['app'] as String? ?? 'other',
      merchantName: json['merchantName'] as String? ?? '',
      upiId: json['upiId'] as String? ?? '',
      transactionId: json['transactionId'] as String? ?? '',
      type: json['type'] as String? ?? 'sent',
      category: json['category'] as String? ?? '',
      status: json['status'] as String? ?? 'completed',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: _parseDateTime(json['date']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'app': app,
      'merchantName': merchantName,
      'upiId': upiId,
      'transactionId': transactionId,
      'type': type,
      'category': category,
      'status': status,
      'amount': amount,
      'date': Timestamp.fromDate(date),
    };
  }

  UpiTransactionModel copyWith({
    String? id,
    String? userId,
    String? app,
    String? merchantName,
    String? upiId,
    String? transactionId,
    String? type,
    String? category,
    String? status,
    double? amount,
    DateTime? date,
  }) {
    return UpiTransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      app: app ?? this.app,
      merchantName: merchantName ?? this.merchantName,
      upiId: upiId ?? this.upiId,
      transactionId: transactionId ?? this.transactionId,
      type: type ?? this.type,
      category: category ?? this.category,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }

  bool get isSent => type == 'sent';
  bool get isReceived => type == 'received';

  String get appDisplayName {
    switch (app) {
      case 'gpay':
        return 'Google Pay';
      case 'phonepe':
        return 'PhonePe';
      case 'paytm':
        return 'Paytm';
      default:
        return 'Other';
    }
  }

  @override
  String toString() {
    return 'UpiTransactionModel(id: $id, app: $app, amount: $amount, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpiTransactionModel && other.id == id;
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
