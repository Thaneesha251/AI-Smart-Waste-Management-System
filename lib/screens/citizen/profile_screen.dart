import 'package:flutter/material.dart';
import 'profile_tab.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This is now just a wrapper for ProfileTab
    return const ProfileTab();
  }
}
