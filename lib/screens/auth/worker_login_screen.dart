import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/gradients.dart';
import '../../models/user_model.dart';

class WorkerLoginScreen extends StatefulWidget {
  const WorkerLoginScreen({super.key});

  @override
  State<WorkerLoginScreen> createState() => _WorkerLoginScreenState();
}

class _WorkerLoginScreenState extends State<WorkerLoginScreen> {
  final _workerIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  void _handleLogin() async {
    final id = _workerIdController.text.trim();
    final password = _passwordController.text.trim();

    if (id.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Worker ID and Password')));
      return;
    }

    // In a real app, we'd use the ID. For this demo, we simulate worker login.
    final error = await Provider.of<AuthProvider>(context, listen: false).login('worker@swachhai.gov.in', password);
    
    if (mounted) {
      if (error == null) {
        Navigator.pushReplacementNamed(context, '/worker-dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.redAccent));
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
              Text('Crew Portal', style: AppTypography.heading(fontSize: 32)),
              Text('Authorized Access Only', style: AppTypography.body(color: AppColors.mutedText)),
              const SizedBox(height: 50),
              GlassCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _workerIdController,
                      decoration: const InputDecoration(
                        labelText: 'Worker ID',
                        prefixIcon: Icon(Icons.badge_outlined),
                        hintText: 'e.g. W1024',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.disabled),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    GlassButton(
                      text: 'ACCESS DASHBOARD',
                      gradient: AppGradients.worker,
                      isLoading: Provider.of<AuthProvider>(context).isLoading,
                      onPressed: _handleLogin,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'Contact your supervisor if you lost your ID', 
                  textAlign: TextAlign.center,
                  style: AppTypography.body(fontSize: 12, color: AppColors.mutedText),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
