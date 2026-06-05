import 'package:cloud_firestore/cloud_firestore.dart';

class InvestmentModel {
  final String id;
  final String userId;
  final String type; // FD, RD, MF, PPF, NPS, Stocks, Gold, RealEstate
  final String name;
  final String institution;
  final String status;
  final double amount;
  final double currentValue;
  final double returns;
  final DateTime? startDate;
  final DateTime? maturityDate;
  final List<String> documents;

  const InvestmentModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    required this.institution,
    required this.status,
    required this.amount,
    required this.currentValue,
    required this.returns,
    this.startDate,
    this.maturityDate,
    this.documents = const [],
  });

  factory InvestmentModel.fromJson(Map<String, dynamic> json) {
    return InvestmentModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      name: json['name'] as String? ?? '',
      institution: json['institution'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      returns: (json['returns'] as num?)?.toDouble() ?? 0.0,
      startDate: _parseDateTime(json['startDate']),
      maturityDate: _parseDateTime(json['maturityDate']),
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'name': name,
      'institution': institution,
      'status': status,
      'amount': amount,
      'currentValue': currentValue,
      'returns': returns,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'maturityDate':
          maturityDate != null ? Timestamp.fromDate(maturityDate!) : null,
      'documents': documents,
    };
  }

  InvestmentModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? name,
    String? institution,
    String? status,
    double? amount,
    double? currentValue,
    double? returns,
    DateTime? startDate,
    DateTime? maturityDate,
    List<String>? documents,
  }) {
    return InvestmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      name: name ?? this.name,
      institution: institution ?? this.institution,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currentValue: currentValue ?? this.currentValue,
      returns: returns ?? this.returns,
      startDate: startDate ?? this.startDate,
      maturityDate: maturityDate ?? this.maturityDate,
      documents: documents ?? this.documents,
    );
  }

  double get returnPercentage =>
      amount > 0 ? ((currentValue - amount) / amount) * 100 : 0.0;

  bool get isMatured =>
      maturityDate != null && maturityDate!.isBefore(DateTime.now());

  @override
  String toString() {
    return 'InvestmentModel(id: $id, type: $type, name: $name, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvestmentModel && other.id == id;
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
