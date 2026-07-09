import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/location_provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/gradients.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../widgets/components/components.dart';
import '../../models/complaint.dart';
import '../../core/localization/app_localization.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ScrollController _scrollController = ScrollController();
  File? _selectedImage;
  bool _isAIProcessing = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isAIProcessing = true;
      });

      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() => _isAIProcessing = false);
        _showAIDetectionDialog();
      }
    }
  }

  void _showAIDetectionDialog() {
    final loc = Provider.of<LocationProvider>(context, listen: false);
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('AI Analysis Result', style: AppTypography.heading(fontSize: 20)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAIRow('Waste Type', 'Plastic'),
                  _buildAIRow('Severity', 'Medium'),
                  _buildAIRow('Location', loc.area),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() => _selectedImage = null);
                    Navigator.pop(context);
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.red[400])),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.citizenPrimary, foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/create-complaint', arguments: {
                      'image': _selectedImage,
                      'wasteType': 'Plastic',
                      'severity': 'Medium',
                      'location': loc.area,
                    });
                    setState(() => _selectedImage = null);
                  },
                  child: Text(context.tr('raise_complaint')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAIRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: RichText(
        text: TextSpan(
          style: AppTypography.body(fontSize: 14),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText)),
            TextSpan(text: value, style: const TextStyle(color: AppColors.citizenPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final loc = Provider.of<LocationProvider>(context);
    final complaintProvider = Provider.of<ComplaintProvider>(context);

    return SafeArea(
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 32),
              
              Text(
                '${context.tr('hello')}, ${user?.fullName.split(' ')[0] ?? 'Sreeja'} 👋',
                style: AppTypography.heading(fontSize: 32).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 28),

              _buildLocationCard(loc),
              const SizedBox(height: 24),

              // Raise Complaint Action
              SectionHeader(eyebrow: 'QUICK ACTION', title: context.tr('raise_complaint')),
              const SizedBox(height: 16),
              _buildReportCard(),
              const SizedBox(height: 32),

              // Statistics Section
              SectionHeader(eyebrow: 'YOUR ACTIVITY', title: context.tr('live_stats')),
              const SizedBox(height: 16),
              _buildStatsGrid(complaintProvider),
              const SizedBox(height: 32),

              // Recent Reports Section
              SectionHeader(
                eyebrow: 'RECENT REPORTS',
                title: context.tr('recent_reports'),
                trailing: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/complaint-history'), 
                  child: Text(context.tr('view_all'), style: const TextStyle(color: AppColors.citizenPrimary, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              _buildComplaintList(complaintProvider),
              const SizedBox(height: 120), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.recycling_rounded, size: 18, color: AppColors.citizenPrimary),
              const SizedBox(width: 8),
              Text(context.tr('app_name'), style: AppTypography.heading(fontSize: 14).copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        Row(
          children: [
             _buildCircularIcon(Icons.support_agent_outlined, AppColors.citizenPrimary, () => Navigator.pushNamed(context, '/help-center')),
             const SizedBox(width: 12),
             _buildCircularIcon(Icons.notifications_none_rounded, AppColors.primaryText, () => Navigator.pushNamed(context, '/notifications')),
          ],
        ),
      ],
    );
  }

  Widget _buildCircularIcon(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: IconButton(icon: Icon(icon, size: 22, color: color), onPressed: onTap),
    );
  }

  Widget _buildStatsGrid(ComplaintProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: StatCard(value: provider.totalComplaints.toString(), label: context.tr('total_reports'))),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                value: provider.pendingComplaints.toString(), 
                label: context.tr('pending_action'), 
                valueColor: AppColors.workerPrimary,
                isHighlighted: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: StatCard(value: provider.inProgressComplaints.toString(), label: context.tr('in_progress'), valueColor: Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: StatCard(value: provider.resolvedComplaints.toString(), label: context.tr('resolved'), valueColor: AppColors.citizenPrimary)),
          ],
        ),
      ],
    );
  }

  Widget _buildComplaintList(ComplaintProvider provider) {
    if (provider.complaints.isEmpty) {
       return GlassCard(
        padding: const EdgeInsets.all(40),
        child: Center(child: Text('No complaints yet.', style: AppTypography.body(color: AppColors.mutedText))),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.complaints.length.clamp(0, 3),
      itemBuilder: (context, index) {
        final complaint = provider.complaints[index];
        return _ComplaintListItem(complaint: complaint);
      },
    );
  }

  Widget _buildLocationCard(LocationProvider loc) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.push_pin_rounded, color: Colors.redAccent, size: 16),
              const SizedBox(width: 8),
              Text(context.tr('current_location'), style: AppTypography.eyebrow(color: AppColors.mutedText)),
            ],
          ),
          const SizedBox(height: 14),
          Text('${loc.city}, Tamil Nadu', style: AppTypography.body(fontSize: 18, color: AppColors.primaryText).copyWith(fontWeight: FontWeight.w700)),
          Text(loc.area, style: AppTypography.body(color: AppColors.mutedText, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 20),
          InkWell(
            onTap: () async {
              final result = await Navigator.pushNamed(context, '/map-selection');
              if (result != null && result is Map<String, dynamic>) {
                 Provider.of<LocationProvider>(context, listen: false).updateLocation("Chennai", result['address'] ?? "Area selected", "Zone Detected");
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: AppColors.citizenPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(context.tr('change_location'), style: const TextStyle(color: AppColors.citizenPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.add_a_photo_rounded, color: Colors.blueAccent, size: 24),
              const SizedBox(width: 10),
              Text('Capture Waste', style: AppTypography.heading(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Snap it, tag it, watch it disappear.', style: AppTypography.body(color: AppColors.mutedText)),
          const SizedBox(height: 24),
          GlassButton(
            text: _isAIProcessing ? 'Analyzing Detail...' : 'OPEN AI CAMERA',
            gradient: AppGradients.citizen,
            isLoading: _isAIProcessing,
            onPressed: () => _pickImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }
}

class _ComplaintListItem extends StatelessWidget {
  final Complaint complaint;
  const _ComplaintListItem({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        borderRadius: 22,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/complaint-details', arguments: complaint),
          child: Row(
            children: [
              _buildLeadingImage(complaint.imageUrl),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('#${complaint.id.substring(0, 4)}', style: AppTypography.eyebrow(fontSize: 10, color: AppColors.mutedText)),
                        StatusChip(label: complaint.statusString, color: complaint.getStatusColor()),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(complaint.title, style: AppTypography.body(fontSize: 16, color: AppColors.primaryText).copyWith(fontWeight: FontWeight.w700)),
                    Text(complaint.area, style: AppTypography.body(fontSize: 12, color: AppColors.mutedText), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingImage(String? url) {
    return Container(
      width: 54, height: 54,
      decoration: BoxDecoration(
        color: AppColors.primaryText, 
        borderRadius: BorderRadius.circular(14),
        image: url != null ? DecorationImage(
          image: url.startsWith('http') ? NetworkImage(url) : FileImage(File(url)) as ImageProvider,
          fit: BoxFit.cover,
        ) : null,
      ),
      child: url == null ? const Icon(Icons.assignment_rounded, color: Colors.white, size: 26) : null,
    );
  }
}
