import 'package:flutter/material.dart';
import 'colors.dart';

class AppGradients {
  // Main background gradient
  static const Gradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8F5EA),
      Color(0xFFF2EFE2),
      Color(0xFFFBEFDC),
    ],
  );

  // Role-specific gradients
  static const Gradient citizen = LinearGradient(
    colors: [AppColors.citizenPrimary, Color(0xFF1B432C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient worker = LinearGradient(
    colors: [AppColors.workerPrimary, Color(0xFF9E6410)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient glass = LinearGradient(
    colors: [Colors.white54, Colors.white12],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
