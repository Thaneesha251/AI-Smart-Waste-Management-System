import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'app_strings.dart';

extension LocalizationExtension on BuildContext {
  String tr(String key) {
    final locale = Provider.of<ThemeProvider>(this).locale.languageCode;
    return AppStrings.get(key, locale);
  }
}
