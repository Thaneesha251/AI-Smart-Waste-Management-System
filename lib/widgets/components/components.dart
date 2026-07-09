import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../glass/glass_widgets.dart';

class LiveActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color statusColor;

  const LiveActivityCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.statusColor = AppColors.citizenPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryText,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: AppTypography.body(fontSize: 14, color: AppColors.primaryText).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(subtitle, style: AppTypography.body(fontSize: 12, color: AppColors.mutedText)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  final bool isHighlighted;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      borderRadius: 18,
      borderColor: isHighlighted ? AppColors.citizenPrimary.withValues(alpha: 0.3) : null,
      child: Column(
        children: [
          Text(
            value, 
            style: AppTypography.heading(fontSize: 22).copyWith(
              color: valueColor ?? AppColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            textAlign: TextAlign.center,
            style: AppTypography.body(fontSize: 10, color: AppColors.mutedText).copyWith(height: 1.1),
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(), 
            style: AppTypography.body(fontSize: 10, color: color).copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eyebrow.toUpperCase(), style: AppTypography.eyebrow(fontSize: 10)),
            const SizedBox(height: 2),
            Text(title, style: AppTypography.heading(fontSize: 20)),
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
