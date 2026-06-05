import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseModel {
  final String id;
  final String userId;
  final String itemName;
  final String category;
  final String paymentPlan; // full, emi
  final String loanProvider;
  final double amount;
  final double emiAmount;
  final int emiMonths;
  final int emiPaid;
  final List<String> documents;
  final DateTime purchaseDate;

  const PurchaseModel({
    required this.id,
    required this.userId,
    required this.itemName,
    required this.category,
    this.paymentPlan = 'full',
    this.loanProvider = '',
    required this.amount,
    this.emiAmount = 0.0,
    this.emiMonths = 0,
    this.emiPaid = 0,
    this.documents = const [],
    required this.purchaseDate,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      itemName: json['itemName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      paymentPlan: json['paymentPlan'] as String? ?? 'full',
      loanProvider: json['loanProvider'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      emiAmount: (json['emiAmount'] as num?)?.toDouble() ?? 0.0,
      emiMonths: (json['emiMonths'] as num?)?.toInt() ?? 0,
      emiPaid: (json['emiPaid'] as num?)?.toInt() ?? 0,
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      purchaseDate: _parseDateTime(json['purchaseDate']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'itemName': itemName,
      'category': category,
      'paymentPlan': paymentPlan,
      'loanProvider': loanProvider,
      'amount': amount,
      'emiAmount': emiAmount,
      'emiMonths': emiMonths,
      'emiPaid': emiPaid,
      'documents': documents,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
    };
  }

  PurchaseModel copyWith({
    String? id,
    String? userId,
    String? itemName,
    String? category,
    String? paymentPlan,
    String? loanProvider,
    double? amount,
    double? emiAmount,
    int? emiMonths,
    int? emiPaid,
    List<String>? documents,
    DateTime? purchaseDate,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      paymentPlan: paymentPlan ?? this.paymentPlan,
      loanProvider: loanProvider ?? this.loanProvider,
      amount: amount ?? this.amount,
      emiAmount: emiAmount ?? this.emiAmount,
      emiMonths: emiMonths ?? this.emiMonths,
      emiPaid: emiPaid ?? this.emiPaid,
      documents: documents ?? this.documents,
      purchaseDate: purchaseDate ?? this.purchaseDate,
    );
  }

  bool get isEmi => paymentPlan == 'emi';
  int get emiRemaining => emiMonths - emiPaid;
  double get totalEmiPaid => emiAmount * emiPaid;
  double get totalEmiRemaining => emiAmount * emiRemaining;

  double get emiProgressPercentage =>
      emiMonths > 0 ? (emiPaid / emiMonths) * 100 : 100.0;

  @override
  String toString() {
    return 'PurchaseModel(id: $id, itemName: $itemName, amount: $amount, paymentPlan: $paymentPlan)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchaseModel && other.id == id;
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
