import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../widgets/components/components.dart';
import '../../core/localization/app_localization.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final ScrollController _scrollController = ScrollController();
  bool _notifications = true;
  File? _profileImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated Locally')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
    }
  }

  void _showLanguageDialog() {
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
    final auth = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = auth.user;

    return SafeArea(
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SectionHeader(eyebrow: 'My Account', title: context.tr('profile')),
              const SizedBox(height: 32),
              
              // Profile Header
              GlassCard(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: AppColors.primaryText,
                          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                          child: _profileImage == null ? const Icon(Icons.person, size: 54, color: Colors.white) : null,
                        ),
                        InkWell(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: AppColors.citizenPrimary, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(user?.fullName ?? 'Sreeja', style: AppTypography.heading(fontSize: 22)),
                    Text(user?.email ?? 'sreeja@example.com', style: AppTypography.body(color: AppColors.mutedText)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.citizenPrimary.withValues(alpha: 0.1), 
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text(
                        user?.role.name.toUpperCase() ?? 'CITIZEN', 
                        style: AppTypography.eyebrow(fontSize: 10).copyWith(
                          color: AppColors.citizenPrimary, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Settings Sections
              _buildSection('PREFERENCES', [
                _ProfileItem(icon: Icons.person_outline, title: context.tr('edit_profile'), onTap: () => Navigator.pushNamed(context, '/edit-profile')),
                _ProfileItem(icon: Icons.lock_outline, title: 'Change Password', onTap: () => Navigator.pushNamed(context, '/forgot-password')),
                _ProfileToggle(icon: Icons.notifications_none, title: 'Notifications', value: _notifications, onChanged: (v) => setState(() => _notifications = v)),
                _ProfileItem(
                  icon: Icons.language_outlined, 
                  title: context.tr('language'), 
                  trailing: themeProvider.locale.languageCode == 'en' ? 'English' : 'தமிழ்', 
                  onTap: _showLanguageDialog,
                ),
              ]),
              const SizedBox(height: 24),

              _buildSection('SUPPORT', [
                _ProfileItem(icon: Icons.info_outline, title: context.tr('about'), onTap: () => Navigator.pushNamed(context, '/about')),
                _ProfileItem(icon: Icons.privacy_tip_outlined, title: context.tr('privacy'), onTap: () => Navigator.pushNamed(context, '/privacy-policy')),
                _ProfileItem(icon: Icons.support_agent_outlined, title: context.tr('help'), onTap: () => Navigator.pushNamed(context, '/help-center')),
                _ProfileItem(icon: Icons.feedback_outlined, title: context.tr('feedback'), onTap: () => Navigator.pushNamed(context, '/feedback')),
                _ProfileItem(icon: Icons.contact_support_outlined, title: context.tr('contact'), onTap: () => Navigator.pushNamed(context, '/contact-us')),
              ]),
              const SizedBox(height: 32),
              
              TextButton(
                onPressed: () {
                  auth.logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/role-selection', (route) => false);
                },
                child: Text(context.tr('logout'), style: AppTypography.body().copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Text(title, style: AppTypography.eyebrow(fontSize: 10)),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _ProfileItem({required this.icon, required this.title, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.mutedText, size: 20),
      title: Text(title, style: AppTypography.body().copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) Text(trailing!, style: AppTypography.body(fontSize: 13, color: AppColors.disabled)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.disabled),
        ],
      ),
    );
  }
}

class _ProfileToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final Function(bool) onChanged;

  const _ProfileToggle({required this.icon, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.mutedText, size: 20),
      title: Text(title, style: AppTypography.body().copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.citizenPrimary,
      ),
    );
  }
}
