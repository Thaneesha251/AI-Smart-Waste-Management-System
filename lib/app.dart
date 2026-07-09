import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'providers/theme_provider.dart';

class SwachhAIApp extends StatelessWidget {
  const SwachhAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'SwachhAI',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light, // Standardize on light mode as requested
      locale: themeProvider.locale,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: AppRouter.routes,
    );
  }
}
