import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../providers/navigation_provider.dart';
import '../../core/localization/app_localization.dart';
import 'home_tab.dart';
import 'complaints_history_tab.dart';
import 'profile_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const ComplaintsHistoryTab(),
    const ProfileTab(),
  ];

  Future<bool> _onWillPop() async {
    final nav = Provider.of<NavigationProvider>(context, listen: false);
    if (nav.currentIndex != 0) {
      nav.setIndex(0);
      return false;
    }
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Exit Application?'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Exit', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
           Navigator.pop(context);
        }
      },
      child: AppScaffold(
        body: IndexedStack(
          index: navProvider.currentIndex,
          children: _tabs,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 30, left: 24, right: 24),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 12),
            borderRadius: 30,
            hasShadow: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: context.tr('home'),
                  isSelected: navProvider.currentIndex == 0,
                  onTap: () => navProvider.setIndex(0),
                ),
                _NavBarItem(
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment_rounded,
                  label: context.tr('reports'),
                  isSelected: navProvider.currentIndex == 1,
                  onTap: () => navProvider.setIndex(1),
                ),
                _NavBarItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person_rounded,
                  label: context.tr('profile'),
                  isSelected: navProvider.currentIndex == 2,
                  onTap: () => navProvider.setIndex(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.citizenPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.citizenPrimary.withValues(alpha: 0.3), 
              blurRadius: 15, 
              offset: const Offset(0, 4)
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.mutedText),
              size: 24,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
