import 'package:flutter/material.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('About SwachhAI', style: AppTypography.heading(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              GlassCard(
                child: Column(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(color: AppColors.primaryText, borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.recycling, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 20),
                    Text('SwachhAI', style: AppTypography.heading(fontSize: 24)),
                    Text('v1.0.0 (Demo)', style: AppTypography.body(fontSize: 12, color: AppColors.mutedText)),
                    const SizedBox(height: 32),
                    Text(
                      'SwachhAI is an AI-powered smart waste management platform designed to bridge the gap between citizens and sanitation workers. Our goal is to use technology to build cleaner, smarter, and more sustainable cities.',
                      textAlign: TextAlign.center,
                      style: AppTypography.body(),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    Text('Mission', style: AppTypography.body().copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('To eliminate manual reporting errors and optimize waste collection cycles using predictive AI.', textAlign: TextAlign.center, style: AppTypography.body(fontSize: 12)),
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
