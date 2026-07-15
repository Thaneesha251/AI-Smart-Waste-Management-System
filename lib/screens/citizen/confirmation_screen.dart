import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/gradients.dart';
import '../../providers/navigation_provider.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.citizenPrimary, size: 80),
                const SizedBox(height: 24),
                Text('Complaint Filed!', style: AppTypography.heading(fontSize: 24)),
                const SizedBox(height: 12),
                Text(
                  'Your report has been received. Our team will verify and assign a worker shortly.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(),
                ),
                const SizedBox(height: 40),
                GlassButton(
                  text: 'TRACK STATUS',
                  gradient: AppGradients.citizen,
                  onPressed: () {
                    // Update navigation provider to point to History Tab
                    Provider.of<NavigationProvider>(context, listen: false).setIndex(1);
                    Navigator.pushReplacementNamed(context, '/citizen-dashboard');
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Provider.of<NavigationProvider>(context, listen: false).setIndex(0);
                    Navigator.pushReplacementNamed(context, '/citizen-dashboard');
                  },
                  child: Text('BACK TO HOME', style: AppTypography.body(color: AppColors.mutedText)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
