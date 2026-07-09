import 'package:flutter/material.dart';
import '../../screens/splash_screen.dart';
import '../../screens/auth/role_selection_screen.dart';
import '../../screens/auth/citizen_login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/worker_login_screen.dart';
import '../../screens/citizen/main_navigation_screen.dart';
import '../../screens/citizen/map_selection_screen.dart';
import '../../screens/citizen/create_complaint_screen.dart';
import '../../screens/citizen/edit_profile_screen.dart';
import '../../screens/citizen/privacy_policy_screen.dart';
import '../../screens/citizen/about_screen.dart';
import '../../screens/citizen/contact_us_screen.dart';
import '../../screens/citizen/notifications_screen.dart';
import '../../screens/citizen/ai_waste_guide_screen.dart';
import '../../screens/citizen/nearby_bins_screen.dart';
import '../../screens/citizen/help_center_screen.dart';
import '../../screens/citizen/feedback_screen.dart';
import '../../screens/citizen/confirmation_screen.dart';
import '../../screens/citizen/complaint_history_screen.dart';
import '../../screens/worker/worker_dashboard.dart';
import '../../screens/worker/worker_profile_screen.dart';
import '../../screens/worker/assigned_tasks_screen.dart';
import '../../screens/worker/task_details_screen.dart';
import '../../screens/worker/worker_map_screen.dart';
import '../../screens/worker/complete_task_screen.dart';
import '../../screens/worker/sos_screen.dart';
import '../../models/complaint.dart';

import '../../screens/worker/sos_emergency_screen.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
    '/splash': (context) => const SplashScreen(),
    '/role-selection': (context) => const RoleSelectionScreen(),
    '/citizen-login': (context) => const CitizenLoginScreen(),
    '/citizen-register': (context) => const RegisterScreen(),
    '/forgot-password': (context) => const ForgotPasswordScreen(),
    '/worker-login': (context) => const WorkerLoginScreen(),
    '/citizen-dashboard': (context) => const MainNavigationScreen(),
    '/map-selection': (context) => const MapSelectionScreen(),
    '/create-complaint': (context) => const CreateComplaintScreen(),
    '/edit-profile': (context) => const EditProfileScreen(),
    '/privacy-policy': (context) => const PrivacyPolicyScreen(),
    '/about': (context) => const AboutScreen(),
    '/contact-us': (context) => const ContactUsScreen(),
    '/notifications': (context) => const NotificationsScreen(),
    '/ai-waste-guide': (context) => const AIWasteGuideScreen(),
    '/nearby-bins': (context) => const NearbyBinsScreen(),
    '/help-center': (context) => const HelpCenterScreen(),
    '/feedback': (context) => const FeedbackScreen(),
    '/confirmation': (context) => const ConfirmationScreen(),
    '/complaint-history': (context) => const ComplaintHistoryScreen(),
    '/worker-dashboard': (context) => const WorkerDashboard(),
    '/worker-profile': (context) => const WorkerProfileScreen(),
    '/assigned-tasks': (context) => const AssignedTasksScreen(),
    '/task-details': (context) => TaskDetailsScreen(
          task: ModalRoute.of(context)!.settings.arguments as Complaint,
        ),
    '/worker-map': (context) => WorkerMapScreen(
          task: ModalRoute.of(context)!.settings.arguments as Complaint?,
        ),
    '/complete-task': (context) => CompleteTaskScreen(
          task: ModalRoute.of(context)!.settings.arguments as Complaint,
        ),
    '/sos': (context) => const SOSScreen(),
    '/sos-emergency': (context) => const SOSEmergencyScreen(),
  };
}
