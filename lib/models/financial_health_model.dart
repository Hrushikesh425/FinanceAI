import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialHealthModel {
  final double overallScore; // 0-100
  final String grade; // A+, A, B, C, D
  final double savingsRate;
  final double debtToIncomeRatio;
  final double emergencyFundMonths;
  final double creditUtilization;
  final double investmentDiversity;
  final List<String> tips;
  final DateTime calculatedAt;

  const FinancialHealthModel({
    required this.overallScore,
    required this.grade,
    this.savingsRate = 0.0,
    this.debtToIncomeRatio = 0.0,
    this.emergencyFundMonths = 0.0,
    this.creditUtilization = 0.0,
    this.investmentDiversity = 0.0,
    this.tips = const [],
    required this.calculatedAt,
  });

  factory FinancialHealthModel.fromJson(Map<String, dynamic> json) {
    return FinancialHealthModel(
      overallScore: (json['overallScore'] as num?)?.toDouble() ?? 0.0,
      grade: json['grade'] as String? ?? 'D',
      savingsRate: (json['savingsRate'] as num?)?.toDouble() ?? 0.0,
      debtToIncomeRatio:
          (json['debtToIncomeRatio'] as num?)?.toDouble() ?? 0.0,
      emergencyFundMonths:
          (json['emergencyFundMonths'] as num?)?.toDouble() ?? 0.0,
      creditUtilization:
          (json['creditUtilization'] as num?)?.toDouble() ?? 0.0,
      investmentDiversity:
          (json['investmentDiversity'] as num?)?.toDouble() ?? 0.0,
      tips: (json['tips'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      calculatedAt: _parseDateTime(json['calculatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallScore': overallScore,
      'grade': grade,
      'savingsRate': savingsRate,
      'debtToIncomeRatio': debtToIncomeRatio,
      'emergencyFundMonths': emergencyFundMonths,
      'creditUtilization': creditUtilization,
      'investmentDiversity': investmentDiversity,
      'tips': tips,
      'calculatedAt': Timestamp.fromDate(calculatedAt),
    };
  }

  FinancialHealthModel copyWith({
    double? overallScore,
    String? grade,
    double? savingsRate,
    double? debtToIncomeRatio,
    double? emergencyFundMonths,
    double? creditUtilization,
    double? investmentDiversity,
    List<String>? tips,
    DateTime? calculatedAt,
  }) {
    return FinancialHealthModel(
      overallScore: overallScore ?? this.overallScore,
      grade: grade ?? this.grade,
      savingsRate: savingsRate ?? this.savingsRate,
      debtToIncomeRatio: debtToIncomeRatio ?? this.debtToIncomeRatio,
      emergencyFundMonths: emergencyFundMonths ?? this.emergencyFundMonths,
      creditUtilization: creditUtilization ?? this.creditUtilization,
      investmentDiversity: investmentDiversity ?? this.investmentDiversity,
      tips: tips ?? this.tips,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  bool get isExcellent => overallScore >= 90;
  bool get isGood => overallScore >= 70 && overallScore < 90;
  bool get isAverage => overallScore >= 50 && overallScore < 70;
  bool get isPoor => overallScore < 50;

  static String calculateGrade(double score) {
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 65) return 'B';
    if (score >= 50) return 'C';
    return 'D';
  }

  @override
  String toString() {
    return 'FinancialHealthModel(score: $overallScore, grade: $grade)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinancialHealthModel &&
        other.overallScore == overallScore &&
        other.calculatedAt == calculatedAt;
  }

  @override
  int get hashCode => overallScore.hashCode ^ calculatedAt.hashCode;

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
