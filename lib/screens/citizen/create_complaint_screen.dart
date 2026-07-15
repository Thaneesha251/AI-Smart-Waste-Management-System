import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/complaint_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/complaint.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/gradients.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../widgets/components/components.dart';

class CreateComplaintScreen extends StatefulWidget {
  const CreateComplaintScreen({super.key});

  @override
  State<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends State<CreateComplaintScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  File? _image;
  String? _wasteType;
  String? _severity;
  String? _location;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _image = args['image'] as File?;
      _wasteType = args['wasteType'] as String?;
      _severity = args['severity'] as String?;
      _location = args['location'] as String?;
    }
  }

  void _handleSubmit() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final loc = Provider.of<LocationProvider>(context, listen: false);
    
    final newComplaint = Complaint(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      location: loc.city,
      area: loc.area,
      zone: loc.zone,
      status: ComplaintStatus.pending,
      priority: _severity ?? 'Medium',
      wasteType: _wasteType ?? 'Plastic',
      createdAt: DateTime.now(),
      assignedAuthority: 'City Municipality',
      expectedResolution: DateTime.now().add(const Duration(days: 3)),
      imageUrl: _image?.path,
    );

    try {
      await Provider.of<ComplaintProvider>(context, listen: false).addComplaint(newComplaint);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/confirmation');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('File Report', style: AppTypography.heading(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_image != null)
                Container(
                  height: 180,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(image: FileImage(_image!), fit: BoxFit.cover),
                    boxShadow: [BoxShadow(color: AppColors.shadow.withValues(alpha: 0.1), blurRadius: 20)],
                  ),
                ),
              
              const SectionHeader(eyebrow: 'Detection Results', title: 'AI Prediction'),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _InfoItem(label: 'Waste Category', value: _wasteType ?? 'Plastic', icon: Icons.category_outlined),
                    const Divider(height: 32),
                    _InfoItem(label: 'Severity Level', value: _severity ?? 'Medium', icon: Icons.warning_amber_outlined, color: AppColors.workerPrimary),
                    const Divider(height: 32),
                    _InfoItem(label: 'Detected Area', value: _location ?? 'Anna Nagar', icon: Icons.location_on_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const SectionHeader(eyebrow: 'Report details', title: 'Information'),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title', hintText: 'Short summary'),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Description', hintText: 'Provide details about the issue'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              GlassButton(
                text: 'SUBMIT COMPLAINT',
                gradient: AppGradients.citizen,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _InfoItem({required this.label, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.mutedText),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.eyebrow(fontSize: 9)),
              Text(value, style: AppTypography.body().copyWith(fontSize: 14, color: color ?? AppColors.primaryText, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
