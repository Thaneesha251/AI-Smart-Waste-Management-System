import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../core/localization/app_localization.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  Future<void> _makeCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email?subject=Support Request');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(context.tr('help'), style: AppTypography.heading(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('how_help'), style: AppTypography.heading(fontSize: 28)),
              const SizedBox(height: 8),
              Text(context.tr('find_answers'), style: AppTypography.body(color: AppColors.mutedText)),
              const SizedBox(height: 40),
              
              _buildHelpItem(context, Icons.question_answer_outlined, context.tr('faq'), 'Find quick answers', () {
                _showFAQs(context);
              }),
              _buildHelpItem(context, Icons.phone_outlined, context.tr('call_support'), 'Speak with our team', () {
                _makeCall('+911800123456');
              }),
              _buildHelpItem(context, Icons.email_outlined, context.tr('email_support'), 'Email us your queries', () {
                _sendEmail('support@swachhai.gov.in');
              }),
              _buildHelpItem(context, Icons.report_problem_outlined, context.tr('report_issue'), 'App bugs or glitches', () {
                 Navigator.pushNamed(context, '/feedback');
              }),
              _buildHelpItem(context, Icons.gavel_outlined, context.tr('terms'), 'Our service agreements', () {
                _showTC(context);
              }),
              
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Text('SwachhAI v1.0.0', style: AppTypography.body(fontSize: 11, color: AppColors.disabled)),
                    const SizedBox(height: 4),
                    Text('Made with ❤️ for a cleaner India', style: AppTypography.body(fontSize: 10, color: AppColors.disabled)),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.citizenPrimary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.citizenPrimary, size: 22),
          ),
          title: Text(title, style: AppTypography.body().copyWith(fontSize: 16, color: AppColors.primaryText, fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: AppTypography.body(fontSize: 12, color: AppColors.mutedText)),
          trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.disabled),
        ),
      ),
    );
  }

  void _showFAQs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => GlassCard(
        borderRadius: 30,
        padding: const EdgeInsets.all(24),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.disabled, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text('Frequently Asked Questions', style: AppTypography.heading(fontSize: 20)),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _faqItem('How to raise a complaint?', 'Go to Home tab and click on Raise Complaint. Take a photo and submit.'),
                    _faqItem('When will my trash be collected?', 'Once AI verifies the complaint, a worker is assigned immediately. ETA is usually under 24h.'),
                    _faqItem('Can I change my location?', 'Yes, use the Change Location button on the dashboard map card.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTC(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text('By using SwachhAI, you agree to provide accurate waste reports and use the platform for community improvement. Data is used for optimization only.'),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('I AGREE'))],
      ),
    );
  }

  Widget _faqItem(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q, style: AppTypography.body().copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(a, style: AppTypography.body(fontSize: 13, color: AppColors.secondaryText)),
        ],
      ),
    );
  }
}
