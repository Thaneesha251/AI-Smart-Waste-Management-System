import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/complaint.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/gradients.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';

class CompleteTaskScreen extends StatefulWidget {
  final Complaint task;
  const CompleteTaskScreen({super.key, required this.task});

  @override
  State<CompleteTaskScreen> createState() => _CompleteTaskScreenState();
}

class _CompleteTaskScreenState extends State<CompleteTaskScreen> {
  File? _beforeImage;
  File? _afterImage;
  bool _isSubmitting = false;

  Future<void> _pickImage(bool isBefore) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        if (isBefore) _beforeImage = File(pickedFile.path);
        else _afterImage = File(pickedFile.path);
      });
    }
  }

  void _handleSubmit() async {
    if (_beforeImage == null || _afterImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload both Before and After photos.')));
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Work Marked as Completed!'), backgroundColor: Colors.green));
      Navigator.popUntil(context, ModalRoute.withName('/worker-dashboard'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Finish Cleanup', style: AppTypography.heading(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildPhotoCard('BEFORE CLEANUP', _beforeImage, () => _pickImage(true)),
            const SizedBox(height: 24),
            _buildPhotoCard('AFTER CLEANUP', _afterImage, () => _pickImage(false)),
            const SizedBox(height: 40),
            GlassButton(
              text: 'MARK AS COMPLETED',
              gradient: AppGradients.worker,
              isLoading: _isSubmitting,
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(String label, File? image, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.eyebrow()),
        const SizedBox(height: 12),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 200, width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              image: image != null ? DecorationImage(image: FileImage(image), fit: BoxFit.cover) : null,
            ),
            child: image == null ? const Center(child: Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.disabled)) : null,
          ),
        ),
      ],
    );
  }
}
