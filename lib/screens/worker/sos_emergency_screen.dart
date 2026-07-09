import 'package:flutter/material.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/components/sos_button.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/localization/app_localization.dart';
import '../../services/voice_assistant_service.dart';

class SOSEmergencyScreen extends StatefulWidget {
  const SOSEmergencyScreen({super.key});

  @override
  State<SOSEmergencyScreen> createState() => _SOSEmergencyScreenState();
}

class _SOSEmergencyScreenState extends State<SOSEmergencyScreen> {
  final VoiceAssistantService _voiceService = VoiceAssistantService();

  @override
  void initState() {
    super.initState();
    _announceInstruction();
  }

  void _announceInstruction() {
    // Tamil: "தயவுசெய்து அவசர பொத்தானை 3 வினாடிகள் அழுத்தவும்" 
    // (Please hold the emergency button for 3 seconds)
    _voiceService.speak("தயவுசெய்து அவசர பொத்தானை 3 வினாடிகள் அழுத்தவும்");
  }

  void _handleTriggered() async {
    await _voiceService.announceSOS();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('sos_alert_sent')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Wait for voice to finish before auto-closing
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.05),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      'EMERGENCY MODE',
                      style: AppTypography.eyebrow(color: Colors.red),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.security_rounded, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              Text(
                'Emergency Alert',
                style: AppTypography.heading(fontSize: 32),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Hold the button below to send your live location to all nearby crew members and administration.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(color: AppColors.mutedText),
                ),
              ),
              const Spacer(),
              SOSButton(onTriggered: _handleTriggered),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
