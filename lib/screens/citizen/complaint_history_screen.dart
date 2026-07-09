import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../widgets/components/components.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import 'complaint_details_screen.dart';

class ComplaintHistoryScreen extends StatelessWidget {
  const ComplaintHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    final complaints = complaintProvider.complaints;

    return AppScaffold(
      appBar: AppBar(
        title: Text('Complaint History', style: AppTypography.heading(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
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
              padding: const EdgeInsets.all(24),
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
                            child: Icon(Icons.assignment_rounded, color: Colors.white.withValues(alpha: 0.9), size: 24),
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
                                Text(complaint.title, style: AppTypography.body(fontSize: 15, color: AppColors.primaryText).copyWith(fontWeight: FontWeight.w600)),
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
    );
  }
}
