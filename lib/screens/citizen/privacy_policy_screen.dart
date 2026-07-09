import 'package:flutter/material.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Privacy Policy', style: AppTypography.heading(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Privacy Policy', style: AppTypography.heading(fontSize: 20)),
                const SizedBox(height: 16),
                Text(
                  'At SwachhAI, we take your privacy seriously. This policy explains how we collect and use your data to improve city cleanliness.',
                  style: AppTypography.body(),
                ),
                const SizedBox(height: 24),
                _buildPoint('Data Collection', 'We collect your location data only when you report an issue to ensure workers can find the waste site.'),
                _buildPoint('Image Privacy', 'Photos uploaded are used for AI detection and verification. They are stored securely and never shared with 3rd parties.'),
                _buildPoint('Account Data', 'Your name and phone number are used to keep track of your reports and provide status updates.'),
                const SizedBox(height: 24),
                Text('Last Updated: July 2026', style: AppTypography.body(fontSize: 11, color: AppColors.mutedText)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPoint(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.body().copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryText)),
          const SizedBox(height: 4),
          Text(desc, style: AppTypography.body(fontSize: 12)),
        ],
      ),
    );
  }
}
