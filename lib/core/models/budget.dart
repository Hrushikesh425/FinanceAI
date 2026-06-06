class Budget {
  final String category;
  final double monthlyLimit;
  final double spent;
  final DateTime updatedAt;

  Budget({
    required this.category,
    required this.monthlyLimit,
    this.spent = 0.0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  double get remaining => monthlyLimit - spent;
  double get percentUsed => monthlyLimit > 0 ? (spent / monthlyLimit).clamp(0.0, 1.0) : 0.0;
  bool get isNearLimit => percentUsed >= 0.8;
  bool get isOverLimit => percentUsed >= 1.0;

  Map<String, dynamic> toMap() => {
    'category': category,
    'monthlyLimit': monthlyLimit,
    'spent': spent,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Budget.fromMap(Map<String, dynamic> map) => Budget(
    category: map['category'] ?? '',
    monthlyLimit: (map['monthlyLimit'] ?? 0.0).toDouble(),
    spent: (map['spent'] ?? 0.0).toDouble(),
    updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
  );

  Budget copyWith({String? category, double? monthlyLimit, double? spent}) => Budget(
    category: category ?? this.category,
    monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    spent: spent ?? this.spent,
    updatedAt: DateTime.now(),
  );
}
