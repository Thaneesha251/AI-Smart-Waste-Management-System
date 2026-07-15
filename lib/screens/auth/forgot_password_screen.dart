import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/gradients.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  void _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.forgotPassword(email);

    if (mounted) {
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reset token sent to your email!'), 
            backgroundColor: AppColors.citizenPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (c) => ResetPasswordScreen(email: email))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 40),
              Text('Reset Password', style: AppTypography.heading(fontSize: 28)),
              Text('Enter your email to receive a reset token', style: AppTypography.body(color: AppColors.mutedText)),
              const SizedBox(height: 60),
              GlassCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address', 
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 32),
                    GlassButton(
                      text: 'SEND RESET TOKEN',
                      gradient: AppGradients.citizen,
                      isLoading: isLoading,
                      onPressed: _handleReset,
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
}
