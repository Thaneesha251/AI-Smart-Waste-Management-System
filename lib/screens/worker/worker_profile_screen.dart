import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worker_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../core/localization/app_localization.dart';

class WorkerProfileScreen extends StatelessWidget {
  const WorkerProfileScreen({super.key});

  void _showLanguageDialog(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(context.tr('language'), style: AppTypography.heading(fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: theme.locale.languageCode == 'en' ? const Icon(Icons.check, color: AppColors.citizenPrimary) : null,
              onTap: () { theme.setLanguage('en'); Navigator.pop(c); },
            ),
            ListTile(
              title: const Text('தமிழ் (Tamil)'),
              trailing: theme.locale.languageCode == 'ta' ? const Icon(Icons.check, color: AppColors.citizenPrimary) : null,
              onTap: () { theme.setLanguage('ta'); Navigator.pop(c); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final worker = Provider.of<WorkerProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AppScaffold(
      appBar: AppBar(
        title: Text(context.tr('profile'), style: AppTypography.heading(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Profile Header
              GlassCard(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 54,
                      backgroundColor: AppColors.primaryText,
                      child: Icon(Icons.engineering, size: 54, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(user?.fullName ?? 'Worker Name', style: AppTypography.heading(fontSize: 22)),
                    Text('Employee ID: SW-1024', style: AppTypography.body(color: AppColors.mutedText)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: worker.isOnDuty ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        worker.isOnDuty ? context.tr('on_duty') : context.tr('off_duty'), 
                        style: AppTypography.eyebrow(fontSize: 10).copyWith(
                          color: worker.isOnDuty ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Info Section
              _buildInfoSection([
                _InfoRow(icon: Icons.phone_outlined, label: context.tr('phone'), value: user?.phone ?? '+91 98765 43210'),
                _InfoRow(icon: Icons.location_on_outlined, label: 'Assigned Ward', value: 'Ward 12 - Anna Nagar'),
                _InfoRow(icon: Icons.check_circle_outline, label: context.tr('resolved'), value: '${worker.completedCount} Total'),
              ]),
              const SizedBox(height: 24),

              // Settings
              _buildInfoSection([
                ListTile(
                  leading: const Icon(Icons.language, color: AppColors.mutedText),
                  title: Text(context.tr('language'), style: AppTypography.body().copyWith(fontWeight: FontWeight.w500)),
                  trailing: Text(themeProvider.locale.languageCode == 'en' ? 'English' : 'தமிழ்', style: const TextStyle(color: AppColors.disabled)),
                  onTap: () => _showLanguageDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: AppColors.mutedText),
                  title: Text(context.tr('help'), style: AppTypography.body().copyWith(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => Navigator.pushNamed(context, '/help-center'),
                ),
              ]),
              
              const SizedBox(height: 32),
              GlassButton(
                text: context.tr('logout'),
                gradient: const LinearGradient(colors: [Colors.redAccent, Colors.red]),
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/role-selection', (r) => false);
                },
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(List<Widget> children) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.mutedText),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.eyebrow(fontSize: 8)),
              Text(value, style: AppTypography.body().copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
