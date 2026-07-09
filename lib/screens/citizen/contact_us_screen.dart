import 'package:flutter/material.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/gradients.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Contact Us', style: AppTypography.heading(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Get in Touch', style: AppTypography.heading(fontSize: 24)),
              Text('We are here to help you with any issues.', style: AppTypography.body(color: AppColors.mutedText)),
              const SizedBox(height: 40),
              
              _buildContactCard(Icons.email_outlined, 'Email', 'support@swachhai.gov.in'),
              const SizedBox(height: 16),
              _buildContactCard(Icons.phone_outlined, 'Helpline', '+91 1800-CLEAN-CITY'),
              const SizedBox(height: 16),
              _buildContactCard(Icons.location_on_outlined, 'Office', 'Anna Nagar, Chennai, Tamil Nadu'),
              
              const SizedBox(height: 40),
              GlassCard(
                child: Column(
                  children: [
                    const TextField(decoration: InputDecoration(labelText: 'Subject')),
                    const SizedBox(height: 16),
                    const TextField(maxLines: 4, decoration: InputDecoration(labelText: 'Message')),
                    const SizedBox(height: 24),
                    GlassButton(
                      text: 'SEND MESSAGE',
                      gradient: AppGradients.citizen,
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message Sent (Demo)')));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String value) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.citizenPrimary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.citizenPrimary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.body(fontSize: 11, color: AppColors.mutedText)),
              Text(value, style: AppTypography.body(fontSize: 14, color: AppColors.primaryText).copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
