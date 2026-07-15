import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../models/complaint.dart';
import '../../providers/complaint_provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../widgets/components/components.dart';
import 'edit_complaint_screen.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  final Complaint complaint;

  const ComplaintDetailsScreen({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    // Listen to changes for state synchronization
    final currentComplaint = Provider.of<ComplaintProvider>(context)
        .complaints
        .firstWhere(
          (c) => c.id == complaint.id,
      orElse: () => complaint,
    );

    // Safe ID handling
    final idStr = currentComplaint.id?.toString() ?? '';
    final shortId =
    idStr.length > 4 ? idStr.substring(0, 4) : idStr;

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Case #$shortId',
          style: AppTypography.heading(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (currentComplaint.status == ComplaintStatus.pending)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) =>
                      EditComplaintScreen(complaint: currentComplaint),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryText,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.eco_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CURRENT STATUS',
                          style: AppTypography.eyebrow(fontSize: 10),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentComplaint.statusString,
                          style: AppTypography.body(
                            fontSize: 18,
                            color: currentComplaint.getStatusColor(),
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(
                    label: currentComplaint.priority.toUpperCase(),
                    color: currentComplaint.getPriorityColor(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Complaint Content
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImagePreview(currentComplaint.imageUrl),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentComplaint.title,
                          style: AppTypography.heading(fontSize: 22),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          currentComplaint.description,
                          style: AppTypography.body(
                            color: AppColors.secondaryText,
                          ),
                        ),

                        const SizedBox(height: 24),

                        _DetailRow(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value:
                          '${currentComplaint.area}, ${currentComplaint.zone}',
                        ),

                        _DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Reported on',
                          value: DateFormat('MMM dd, yyyy')
                              .format(currentComplaint.createdAt),
                        ),

                        _DetailRow(
                          icon: Icons.admin_panel_settings_outlined,
                          label: 'Authority',
                          value: currentComplaint.assignedAuthority,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'ACTIVITY TIMELINE',
              style: AppTypography.eyebrow(),
            ),

            const SizedBox(height: 16),

            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _TimelineStep(
                    title: 'Report Submitted',
                    date: DateFormat('MMM dd')
                        .format(currentComplaint.createdAt),
                    isDone: true,
                    isLast: false,
                  ),
                  _TimelineStep(
                    title: 'AI Verified Type',
                    date: '-',
                    isDone:
                    currentComplaint.status != ComplaintStatus.pending,
                    isLast: false,
                  ),
                  _TimelineStep(
                    title: 'Worker Dispatched',
                    date: '-',
                    isDone:
                    currentComplaint.status ==
                        ComplaintStatus.assigned ||
                        currentComplaint.status ==
                            ComplaintStatus.inProgress,
                    isLast: false,
                  ),
                  _TimelineStep(
                    title: 'Issue Resolved',
                    date: '-',
                    isDone:
                    currentComplaint.status ==
                        ComplaintStatus.resolved,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            if (currentComplaint.status == ComplaintStatus.pending)
              GlassButton(
                text: 'CANCEL REPORT',
                gradient: const LinearGradient(
                  colors: [Colors.redAccent, Colors.red],
                ),
                onPressed: () {
                  if (currentComplaint.id != null) {
                    _showCancelDialog(
                      context,
                      currentComplaint.id!,
                    );
                  }
                },
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        color: AppColors.disabled.withValues(alpha: 0.1),
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 48,
            color: AppColors.mutedText,
          ),
        ),
      );
    }

    final isLocal = !url.startsWith('http');

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: isLocal
              ? FileImage(File(url))
              : NetworkImage(url) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Cancel Report?'),
        content: const Text(
          'Are you sure you want to cancel this report? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('NO, KEEP IT'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Provider.of<ComplaintProvider>(
                context,
                listen: false,
              ).cancelComplaint(id);

              Navigator.pop(c);
              Navigator.pop(context);
            },
            child: const Text(
              'YES, CANCEL',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.mutedText),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.eyebrow(fontSize: 9),
                ),
                Text(
                  value,
                  style: AppTypography.body(
                    fontSize: 14,
                    color: AppColors.primaryText,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String date;
  final bool isDone;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    required this.date,
    required this.isDone,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.citizenPrimary
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone
                      ? Colors.transparent
                      : AppColors.divider,
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(
                Icons.check,
                size: 12,
                color: Colors.white,
              )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isDone
                    ? AppColors.citizenPrimary
                    : AppColors.divider,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.body(
                  fontSize: 14,
                  color: isDone
                      ? AppColors.primaryText
                      : AppColors.mutedText,
                ).copyWith(
                  fontWeight: isDone
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        Text(
          date,
          style: AppTypography.body(
            fontSize: 12,
            color: AppColors.disabled,
          ),
        ),
      ],
    );
  }
}