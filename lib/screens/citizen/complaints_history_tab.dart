import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../widgets/components/components.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/localization/app_localization.dart';
import 'complaint_details_screen.dart';

class ComplaintsHistoryTab extends StatelessWidget {
  const ComplaintsHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    final complaints = complaintProvider.complaints;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: SectionHeader(eyebrow: 'YOUR REPORTS', title: context.tr('reports')),
          ),
          Expanded(
            child: complaints.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_late_outlined, size: 64, color: AppColors.disabled.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text('No history found.', style: AppTypography.body(color: AppColors.mutedText)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComplaintDetailsScreen(complaint: complaint),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 54, height: 54,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryText,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.assignment_rounded, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('#${complaint.id.substring(0, 4)}', style: AppTypography.eyebrow(fontSize: 9)),
                                        StatusChip(label: complaint.statusString, color: complaint.getStatusColor()),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(complaint.title, style: AppTypography.body().copyWith(fontSize: 15, color: AppColors.primaryText, fontWeight: FontWeight.w600)),
                                    Text(complaint.area, style: AppTypography.body(fontSize: 12, color: AppColors.mutedText)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.disabled, size: 14),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
