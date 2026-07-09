import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/complaint.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class EditComplaintScreen extends StatefulWidget {
  final Complaint complaint;
  const EditComplaintScreen({super.key, required this.complaint});

  @override
  State<EditComplaintScreen> createState() => _EditComplaintScreenState();
}

class _EditComplaintScreenState extends State<EditComplaintScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.complaint.title);
    _descController = TextEditingController(text: widget.complaint.description);
  }

  void _handleUpdate() async {
    if (_titleController.text.trim().isEmpty || _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isUpdating = true);
    
    final updated = widget.complaint.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
    );

    await Provider.of<ComplaintProvider>(context, listen: false).updateComplaint(updated);
    
    if (mounted) {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report updated successfully'), behavior: SnackBarBehavior.floating),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Edit Report', style: AppTypography.heading(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              GlassCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _descController,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 32),
                    GlassButton(
                      text: 'UPDATE REPORT',
                      isLoading: _isUpdating,
                      onPressed: _handleUpdate,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
