import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class AppTransaction {
  final String id;
  final String userId;
  final String title;
  final String? subtitle;
  final double amount;
  final TransactionType type;
  final String category; // e.g., 'Food', 'Shopping', 'Bills', 'Salary'
  final DateTime date;
  final String paymentMethod; // e.g., 'UPI', 'Credit Card', 'Cash'
  final String? receiptImageUrl;

  AppTransaction({
    required this.id,
    required this.userId,
    required this.title,
    this.subtitle,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.paymentMethod,
    this.receiptImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'type': type.name,
      'category': category,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'receiptImageUrl': receiptImageUrl,
    };
  }

  factory AppTransaction.fromMap(Map<String, dynamic> map, String id) {
    return AppTransaction(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'],
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      category: map['category'] ?? 'Other',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      paymentMethod: map['paymentMethod'] ?? 'UPI',
      receiptImageUrl: map['receiptImageUrl'],
    );
  }

  // UI Helpers
  IconData get icon {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant_rounded;
      case 'shopping': return Icons.shopping_bag_rounded;
      case 'bills':
      case 'housing': return Icons.home_rounded;
      case 'salary': return Icons.account_balance_wallet_rounded;
      case 'transport': return Icons.directions_car_rounded;
      case 'health': return Icons.medical_services_rounded;
      case 'entertainment': return Icons.movie_rounded;
      default: return Icons.receipt_rounded;
    }
  }
}
