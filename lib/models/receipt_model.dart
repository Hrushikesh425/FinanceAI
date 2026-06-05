import 'package:cloud_firestore/cloud_firestore.dart';

class ReceiptModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String merchantName;
  final String category;
  final String paymentMethod;
  final String rawText;
  final double amount;
  final DateTime date;
  final DateTime scannedAt;
  final bool verified;

  const ReceiptModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.merchantName,
    this.category = '',
    this.paymentMethod = '',
    this.rawText = '',
    required this.amount,
    required this.date,
    required this.scannedAt,
    this.verified = false,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      merchantName: json['merchantName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      rawText: json['rawText'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: _parseDateTime(json['date']) ?? DateTime.now(),
      scannedAt: _parseDateTime(json['scannedAt']) ?? DateTime.now(),
      verified: json['verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'merchantName': merchantName,
      'category': category,
      'paymentMethod': paymentMethod,
      'rawText': rawText,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'scannedAt': Timestamp.fromDate(scannedAt),
      'verified': verified,
    };
  }

  ReceiptModel copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? merchantName,
    String? category,
    String? paymentMethod,
    String? rawText,
    double? amount,
    DateTime? date,
    DateTime? scannedAt,
    bool? verified,
  }) {
    return ReceiptModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      merchantName: merchantName ?? this.merchantName,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      rawText: rawText ?? this.rawText,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      scannedAt: scannedAt ?? this.scannedAt,
      verified: verified ?? this.verified,
    );
  }

  @override
  String toString() {
    return 'ReceiptModel(id: $id, merchantName: $merchantName, amount: $amount, verified: $verified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReceiptModel && other.id == id;
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
