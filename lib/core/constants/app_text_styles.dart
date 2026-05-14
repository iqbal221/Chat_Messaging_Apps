import 'package:flutter/material.dart';

class AppTextStyles {
  /// Display Text (Calculator Screen)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle displayLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  /// Button Text
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  /// Operator Button Text
  static const TextStyle operatorText = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  /// History Text
  static const TextStyle historyExpression = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle historyResult = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
}
