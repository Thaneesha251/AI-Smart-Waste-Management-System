import 'package:flutter/material.dart';
import '../../models/complaint.dart';
import '../../services/complaint_service.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../widgets/components/components.dart';

class AssignedTasksScreen extends StatefulWidget {
  const AssignedTasksScreen({super.key});

  @override
  State<AssignedTasksScreen> createState() => _AssignedTasksScreenState();
}

class _AssignedTasksScreenState extends State<AssignedTasksScreen> {
  final ComplaintService _complaintService = ComplaintService();
  List<Complaint> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _complaintService.getWorkerTasks();
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Assigned Tasks', style: AppTypography.heading(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(child: Text('No tasks assigned yet.', style: AppTypography.body(color: AppColors.mutedText)))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(context, '/task-details', arguments: task),
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
                                        Text('#${task.id}', style: AppTypography.eyebrow(fontSize: 10)),
                                        StatusChip(label: task.priority.toUpperCase(), color: task.getPriorityColor()),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(task.title, style: AppTypography.body(fontSize: 15, color: AppColors.primaryText).copyWith(fontWeight: FontWeight.w600)),
                                    Text(task.area, style: AppTypography.body(fontSize: 12, color: AppColors.mutedText)),
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
