import 'package:cloud_firestore/cloud_firestore.dart';

class PolicyModel {
  final String id;
  final String userId;
  final String policyName;
  final String company;
  final String type; // life, health, vehicle, property, other
  final String premiumFrequency;
  final String beneficiary;
  final String policyNumber;
  final String status;
  final double premium;
  final double coverage;
  final DateTime renewalDate;
  final List<String> documents;

  const PolicyModel({
    required this.id,
    required this.userId,
    required this.policyName,
    required this.company,
    required this.type,
    this.premiumFrequency = 'yearly',
    this.beneficiary = '',
    required this.policyNumber,
    this.status = 'active',
    required this.premium,
    required this.coverage,
    required this.renewalDate,
    this.documents = const [],
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      policyName: json['policyName'] as String? ?? '',
      company: json['company'] as String? ?? '',
      type: json['type'] as String? ?? 'other',
      premiumFrequency: json['premiumFrequency'] as String? ?? 'yearly',
      beneficiary: json['beneficiary'] as String? ?? '',
      policyNumber: json['policyNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      premium: (json['premium'] as num?)?.toDouble() ?? 0.0,
      coverage: (json['coverage'] as num?)?.toDouble() ?? 0.0,
      renewalDate: _parseDateTime(json['renewalDate']) ?? DateTime.now(),
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
      'policyName': policyName,
      'company': company,
      'type': type,
      'premiumFrequency': premiumFrequency,
      'beneficiary': beneficiary,
      'policyNumber': policyNumber,
      'status': status,
      'premium': premium,
      'coverage': coverage,
      'renewalDate': Timestamp.fromDate(renewalDate),
      'documents': documents,
    };
  }

  PolicyModel copyWith({
    String? id,
    String? userId,
    String? policyName,
    String? company,
    String? type,
    String? premiumFrequency,
    String? beneficiary,
    String? policyNumber,
    String? status,
    double? premium,
    double? coverage,
    DateTime? renewalDate,
    List<String>? documents,
  }) {
    return PolicyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      policyName: policyName ?? this.policyName,
      company: company ?? this.company,
      type: type ?? this.type,
      premiumFrequency: premiumFrequency ?? this.premiumFrequency,
      beneficiary: beneficiary ?? this.beneficiary,
      policyNumber: policyNumber ?? this.policyNumber,
      status: status ?? this.status,
      premium: premium ?? this.premium,
      coverage: coverage ?? this.coverage,
      renewalDate: renewalDate ?? this.renewalDate,
      documents: documents ?? this.documents,
    );
  }

  bool get isRenewalDue => renewalDate.isBefore(DateTime.now());

  int get daysUntilRenewal => renewalDate.difference(DateTime.now()).inDays;

  @override
  String toString() {
    return 'PolicyModel(id: $id, policyName: $policyName, type: $type, premium: $premium)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PolicyModel && other.id == id;
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
