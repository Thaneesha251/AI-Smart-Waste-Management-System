import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/location_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/worker_provider.dart';
import 'services/voice_assistant_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  final complaintProvider = ComplaintProvider();
  final locationProvider = LocationProvider();
  final themeProvider = ThemeProvider();
  final navProvider = NavigationProvider();
  final workerProvider = WorkerProvider();

  try {
    // Initialize Voice Assistant
    await VoiceAssistantService().init();

    // Initialize providers from local storage
    await authProvider.init();
    await complaintProvider.init();
    await locationProvider.init();
  } catch (e, st) {
    debugPrint('Initialization error: $e');
    debugPrintStack(stackTrace: st);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: complaintProvider),
        ChangeNotifierProvider.value(value: locationProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: navProvider),
        ChangeNotifierProvider.value(value: workerProvider),
      ],
      child: const SwachhAIApp(),
    ),
  );
}