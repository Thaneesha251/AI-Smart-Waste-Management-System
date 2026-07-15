import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/gradients.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureText = true;

  void _handleChange() async {
    final currentPass = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (currentPass.isEmpty || newPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check current password (this usually needs a backend call, for demo we compare locally if password is in model)
    if (authProvider.user?.password != currentPass) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current password is incorrect')),
      );
      return;
    }

    // In a real app, you'd have a POST /auth/change-password endpoint
    // For this demo, we'll trigger the Reset flow or similar update
    // But since the prompt specifically asked for Forgot Password integration, 
    // I'll assume users can use the reset flow even from profile.
    
    // Redirect to Forgot Password if they want to reset via email, 
    // OR just update user profile if we want to support direct change.
    // Let's do a direct update for demo simplicity.
    
    final updatedUser = authProvider.user!.copyWith(password: newPass);
    await authProvider.updateProfile(updatedUser);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully!'), backgroundColor: AppColors.citizenPrimary),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return AppScaffold(
      appBar: AppBar(
        title: Text('Change Password', style: AppTypography.heading(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update Security', style: AppTypography.heading(fontSize: 24)),
              Text('Keep your account safe with a strong password', style: AppTypography.body(color: AppColors.mutedText)),
              const SizedBox(height: 40),
              GlassCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.disabled),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: _obscureText,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: Icon(Icons.lock_reset_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureText,
                      decoration: const InputDecoration(
                        labelText: 'Confirm New Password',
                        prefixIcon: Icon(Icons.check_circle_outline),
                      ),
                    ),
                    const SizedBox(height: 32),
                    GlassButton(
                      text: 'SAVE NEW PASSWORD',
                      gradient: AppGradients.citizen,
                      isLoading: isLoading,
                      onPressed: _handleChange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                  child: const Text('Forgot Current Password?'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
