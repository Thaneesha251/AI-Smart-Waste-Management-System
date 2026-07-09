import 'package:intl/intl.dart';

class AppHelpers {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  static String getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'Urgent';
      case 'medium':
        return 'Medium';
      case 'low':
      default:
        return 'Normal';
    }
  }
}
