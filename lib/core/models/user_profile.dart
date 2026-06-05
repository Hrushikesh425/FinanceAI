class UserProfile {
  final String id;
  final String phoneNumber;
  final String? displayName;
  final String? email;
  final DateTime createdAt;
  final bool isBiometricEnabled;
  final double monthlyBudget;

  UserProfile({
    required this.id,
    required this.phoneNumber,
    this.displayName,
    this.email,
    required this.createdAt,
    this.isBiometricEnabled = false,
    this.monthlyBudget = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'isBiometricEnabled': isBiometricEnabled,
      'monthlyBudget': monthlyBudget,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      phoneNumber: map['phoneNumber'] ?? '',
      displayName: map['displayName'],
      email: map['email'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      isBiometricEnabled: map['isBiometricEnabled'] ?? false,
      monthlyBudget: (map['monthlyBudget'] ?? 0.0).toDouble(),
    );
  }
}
