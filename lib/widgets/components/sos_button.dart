import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/localization/app_localization.dart';

class SOSButton extends StatefulWidget {
  final VoidCallback onTriggered;
  const SOSButton({super.key, required this.onTriggered});

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHolding = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startHold() {
    setState(() => _isHolding = true);
    _controller.forward();
    HapticFeedback.mediumImpact();
    
    _timer = Timer(const Duration(seconds: 3), () {
      if (_isHolding) {
        _triggerSOS();
      }
    });
  }

  void _stopHold() {
    if (_controller.isAnimating || _controller.value > 0) {
      _controller.reverse();
    }
    _timer?.cancel();
    setState(() => _isHolding = false);
  }

  void _triggerSOS() {
    HapticFeedback.heavyImpact();
    widget.onTriggered();
    _stopHold();
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startHold(),
      onLongPressEnd: (_) => _stopHold(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow/Progress
          SizedBox(
            width: 120,
            height: 120,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CircularProgressIndicator(
                  value: _controller.value,
                  strokeWidth: 8,
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                );
              },
            ),
          ),
          
          // Main Button
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.4),
                  blurRadius: _isHolding ? 30 : 15,
                  spreadRadius: _isHolding ? 5 : 0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
                const SizedBox(height: 4),
                Text(
                  context.tr('sos').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          
          // Instruction Label
          if (_isHolding)
            Positioned(
              bottom: -40,
              child: Text(
                'HOLD FOR 3S',
                style: AppTypography.eyebrow(color: Colors.red, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
