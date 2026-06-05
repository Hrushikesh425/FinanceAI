import 'package:cloud_firestore/cloud_firestore.dart';

class ChequeModel {
  final String id;
  final String userId;
  final String chequeNumber;
  final String recipient;
  final String bankName;
  final String status; // issued, cleared, bounced, cancelled
  final String bouncedReason;
  final double amount;
  final DateTime? date;
  final DateTime? clearingDate;

  const ChequeModel({
    required this.id,
    required this.userId,
    required this.chequeNumber,
    required this.recipient,
    required this.bankName,
    this.status = 'issued',
    this.bouncedReason = '',
    required this.amount,
    this.date,
    this.clearingDate,
  });

  factory ChequeModel.fromJson(Map<String, dynamic> json) {
    return ChequeModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      chequeNumber: json['chequeNumber'] as String? ?? '',
      recipient: json['recipient'] as String? ?? '',
      bankName: json['bankName'] as String? ?? '',
      status: json['status'] as String? ?? 'issued',
      bouncedReason: json['bouncedReason'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: _parseDateTime(json['date']),
      clearingDate: _parseDateTime(json['clearingDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'chequeNumber': chequeNumber,
      'recipient': recipient,
      'bankName': bankName,
      'status': status,
      'bouncedReason': bouncedReason,
      'amount': amount,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'clearingDate':
          clearingDate != null ? Timestamp.fromDate(clearingDate!) : null,
    };
  }

  ChequeModel copyWith({
    String? id,
    String? userId,
    String? chequeNumber,
    String? recipient,
    String? bankName,
    String? status,
    String? bouncedReason,
    double? amount,
    DateTime? date,
    DateTime? clearingDate,
  }) {
    return ChequeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      chequeNumber: chequeNumber ?? this.chequeNumber,
      recipient: recipient ?? this.recipient,
      bankName: bankName ?? this.bankName,
      status: status ?? this.status,
      bouncedReason: bouncedReason ?? this.bouncedReason,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      clearingDate: clearingDate ?? this.clearingDate,
    );
  }

  bool get isIssued => status == 'issued';
  bool get isCleared => status == 'cleared';
  bool get isBounced => status == 'bounced';
  bool get isCancelled => status == 'cancelled';

  @override
  String toString() {
    return 'ChequeModel(id: $id, chequeNumber: $chequeNumber, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChequeModel && other.id == id;
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
