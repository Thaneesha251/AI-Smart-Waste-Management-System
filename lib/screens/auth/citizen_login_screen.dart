import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/gradients.dart';
import '../../core/localization/app_localization.dart';

class CitizenLoginScreen extends StatefulWidget {
  const CitizenLoginScreen({super.key});

  @override
  State<CitizenLoginScreen> createState() => _CitizenLoginScreenState();
}

class _CitizenLoginScreenState extends State<CitizenLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _rememberMe = false;

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final error = await Provider.of<AuthProvider>(context, listen: false).login(email, password);
    
    if (mounted) {
      if (error == null) {
        // Fetch complaints after login
        await Provider.of<ComplaintProvider>(context, listen: false).fetchComplaints();
        Navigator.pushReplacementNamed(context, '/citizen-dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error), 
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 40),
              Text(
                context.tr('welcome_back'),
                style: AppTypography.heading(fontSize: 32),
              ),
              Text(
                context.tr('citizen_login'),
                style: AppTypography.body(fontSize: 16, color: AppColors.mutedText),
              ),
              const SizedBox(height: 50),
              GlassCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: context.tr('email'),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: context.tr('password'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.disabled),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleLogin(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.citizenPrimary,
                          onChanged: (v) => setState(() => _rememberMe = v!),
                        ),
                        const Text('Remember Me', style: TextStyle(fontSize: 12)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                          child: Text('Forgot Password?', style: AppTypography.body(fontSize: 12, color: AppColors.citizenPrimary).copyWith(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    GlassButton(
                      text: context.tr('login'),
                      gradient: AppGradients.citizen,
                      isLoading: Provider.of<AuthProvider>(context).isLoading,
                      onPressed: _handleLogin,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/citizen-register'),
                  child: RichText(
                    text: TextSpan(
                      style: AppTypography.body(fontSize: 14),
                      children: [
                        TextSpan(text: context.tr('no_account'), style: TextStyle(color: AppColors.primaryText)),
                        TextSpan(
                          text: context.tr('register'),
                          style: const TextStyle(color: AppColors.citizenPrimary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
