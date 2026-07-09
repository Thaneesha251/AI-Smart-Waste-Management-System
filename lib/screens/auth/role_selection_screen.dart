import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/gradients.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../widgets/components/components.dart';
import '../../core/localization/app_localization.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.recycling_rounded, size: 18, color: AppColors.citizenPrimary),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('app_name'),
                          style: AppTypography.heading(fontSize: 14).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  // Profile/Notification Button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: const Icon(Icons.notifications_none_rounded, size: 22, color: AppColors.primaryText),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // AI Tag
              Text(
                "INDIA'S FIRST PREDICTIVE WASTE-AI",
                style: AppTypography.eyebrow(fontSize: 10, color: AppColors.citizenPrimary).copyWith(letterSpacing: 2.0, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),

              // Large Hero Text
              RichText(
                text: TextSpan(
                  style: AppTypography.heading(fontSize: 54).copyWith(height: 1.0, color: AppColors.primaryText, fontWeight: FontWeight.w600),
                  children: [
                    const TextSpan(text: 'Spot it.\n'),
                    TextSpan(
                      text: 'Report it.\n',
                      style: TextStyle(color: AppColors.citizenPrimary),
                    ),
                    const TextSpan(text: 'Gone.'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Join thousands of citizens making cities smarter, cleaner, and better in real-time.',
                style: AppTypography.body(fontSize: 15, color: AppColors.secondaryText).copyWith(height: 1.5, letterSpacing: -0.2),
              ),
              const SizedBox(height: 40),

              // Statistics Section
              Row(
                children: [
                  Expanded(child: StatCard(value: '12K+', label: context.tr('total_reports'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      value: '94%', 
                      label: context.tr('resolved'), 
                      valueColor: AppColors.citizenPrimary,
                      isHighlighted: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: StatCard(value: '3.2K', label: 'Crew')),
                ],
              ),
              const SizedBox(height: 48),

              // Role Cards Section
              _RoleCard(
                title: "I'm a citizen",
                subtitle: "Snap it, tag it, watch it disappear",
                icon: Icons.person_outline_rounded,
                gradient: AppGradients.citizen,
                onTap: () => Navigator.pushNamed(context, '/citizen-login'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: "I'm on the crew",
                subtitle: "Pick up filed complaints, resolve on the go",
                icon: Icons.engineering_outlined,
                gradient: AppGradients.worker,
                onTap: () => Navigator.pushNamed(context, '/worker-login'),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 22,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: (gradient.colors.last).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: AppTypography.body(fontSize: 17, color: AppColors.primaryText).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle, 
                    style: AppTypography.body(fontSize: 12, color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.disabled, size: 18),
          ],
        ),
      ),
    );
  }
}
