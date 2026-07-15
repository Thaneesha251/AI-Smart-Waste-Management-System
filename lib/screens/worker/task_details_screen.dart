import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../models/complaint.dart';
import '../../providers/worker_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/gradients.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../widgets/components/components.dart';
import '../../core/localization/app_localization.dart';
import '../../services/voice_assistant_service.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Complaint task;
  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  File? _afterImage;
  bool _isUploading = false;
  final VoiceAssistantService _voiceService = VoiceAssistantService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickAfterImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _afterImage = File(pickedFile.path));
    }
  }

  void _handleComplete() async {
    if (_afterImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('upload_after'))),
      );
      return;
    }

    setState(() => _isUploading = true);
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      if (widget.task.id != null) {
        await Provider.of<WorkerProvider>(context, listen: false).completeTask(widget.task.id!, _afterImage!.path);
      }
      setState(() => _isUploading = false);
      // Voice strictly in Tamil
      await _voiceService.announceCompletion();
      
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 20),
              Text(context.tr('resolved'), style: AppTypography.heading(fontSize: 20)),
              const SizedBox(height: 8),
              Text(context.tr('task_completed_msg'), textAlign: TextAlign.center, style: AppTypography.body()),
              const SizedBox(height: 24),
              GlassButton(text: 'OK', onPressed: () {
                Navigator.pop(c);
                Navigator.pop(context);
              }),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Task #${widget.task.id?.toString().substring(0, 4) ?? "----"}', style: AppTypography.heading(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskHeader(),
              const SizedBox(height: 24),
              
              const SectionHeader(eyebrow: 'EVIDENCE', title: 'Before Cleaning'),
              const SizedBox(height: 12),
              _buildImagePlaceholder(widget.task.imageUrl, "Reported Image"),
              
              const SizedBox(height: 24),
              SectionHeader(eyebrow: 'ACTION', title: context.tr('upload_after')),
              const SizedBox(height: 12),
              _buildAfterImageUpload(),
              
              const SizedBox(height: 40),
              if (widget.task.status != ComplaintStatus.resolved)
                GlassButton(
                  text: context.tr('complete_task'),
                  gradient: AppGradients.citizen,
                  isLoading: _isUploading,
                  onPressed: _handleComplete,
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(context.tr('resolved').toUpperCase(), style: AppTypography.heading(fontSize: 16).copyWith(color: Colors.green)),
                    ],
                  ),
                ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskHeader() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusChip(label: widget.task.wasteType.toUpperCase(), color: AppColors.primaryText),
              StatusChip(label: widget.task.priority.toUpperCase(), color: widget.task.getPriorityColor()),
            ],
          ),
          const SizedBox(height: 16),
          Text(widget.task.title, style: AppTypography.heading(fontSize: 22)),
          const SizedBox(height: 4),
          Text(widget.task.description, style: AppTypography.body(color: AppColors.secondaryText)),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          _buildHeaderInfo(Icons.location_on_outlined, 'Location', widget.task.area),
          const SizedBox(height: 20),
          GlassButton(
            text: context.tr('start_nav'),
            gradient: AppGradients.worker,
            onPressed: () => Navigator.pushNamed(context, '/worker-map', arguments: widget.task),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.mutedText),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.eyebrow(fontSize: 8)),
            Text(value, style: AppTypography.body().copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(String? url, String label) {
    if (url == null) {
      return Container(
        height: 200, width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.disabled.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: Text(label, style: AppTypography.body(color: AppColors.disabled))),
      );
    }

    final isLocal = !url.startsWith('http');
    return Container(
      height: 200, width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: isLocal ? FileImage(File(url)) : NetworkImage(url) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAfterImageUpload() {
    return InkWell(
      onTap: widget.task.status == ComplaintStatus.resolved ? null : _pickAfterImage,
      child: Container(
        height: 200, width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.disabled.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.disabled.withValues(alpha: 0.3)),
          image: _afterImage != null ? DecorationImage(image: FileImage(_afterImage!), fit: BoxFit.cover) : null,
        ),
        child: _afterImage == null ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.mutedText),
            const SizedBox(height: 12),
            Text(context.tr('upload_after'), style: AppTypography.body(color: AppColors.mutedText)),
            Text('Required to mark as complete', style: AppTypography.body(fontSize: 10, color: AppColors.disabled)),
          ],
        ) : null,
      ),
    );
  }
}
