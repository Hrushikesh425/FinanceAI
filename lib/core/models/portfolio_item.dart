import 'package:flutter/material.dart';

enum PortfolioItemType { investment, debt, asset, policy }

class PortfolioItem {
  final String id;
  final String userId;
  final PortfolioItemType type;
  final String subType; // 'Fixed Deposit', 'Life Insurance', etc.
  final String name;
  final double amount; // Principal / Value / Sum Assured
  final double secondaryAmount; // Expected Return %, Premium, or EMI Amount
  final DateTime? startDate;
  final DateTime? nextActionDate; // Maturity, Renewal, or Next EMI
  final String frequency; // 'One-time', 'Monthly', 'Yearly'
  
  // Reminders
  final int? reminderDate; // 1-31
  final int reminderDaysBefore; // 1, 3, 5, 7
  final bool isPushEnabled;
  final bool isSmsEnabled;

  PortfolioItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.subType,
    required this.name,
    required this.amount,
    this.secondaryAmount = 0.0,
    this.startDate,
    this.nextActionDate,
    this.frequency = 'One-time',
    this.reminderDate,
    this.reminderDaysBefore = 3,
    this.isPushEnabled = true,
    this.isSmsEnabled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'subType': subType,
      'name': name,
      'amount': amount,
      'secondaryAmount': secondaryAmount,
      'startDate': startDate?.toIso8601String(),
      'nextActionDate': nextActionDate?.toIso8601String(),
      'frequency': frequency,
      'reminderDate': reminderDate,
      'reminderDaysBefore': reminderDaysBefore,
      'isPushEnabled': isPushEnabled,
      'isSmsEnabled': isSmsEnabled,
    };
  }

  factory PortfolioItem.fromMap(Map<String, dynamic> map, String id) {
    return PortfolioItem(
      id: id,
      userId: map['userId'] ?? '',
      type: PortfolioItemType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PortfolioItemType.investment,
      ),
      subType: map['subType'] ?? '',
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      secondaryAmount: (map['secondaryAmount'] ?? 0.0).toDouble(),
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      nextActionDate: map['nextActionDate'] != null ? DateTime.parse(map['nextActionDate']) : null,
      frequency: map['frequency'] ?? 'One-time',
      reminderDate: map['reminderDate'],
      reminderDaysBefore: map['reminderDaysBefore'] ?? 3,
      isPushEnabled: map['isPushEnabled'] ?? true,
      isSmsEnabled: map['isSmsEnabled'] ?? false,
    );
  }
}
