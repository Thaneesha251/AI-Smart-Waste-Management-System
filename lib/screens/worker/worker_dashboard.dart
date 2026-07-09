import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worker_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../widgets/components/components.dart';
import '../../core/localization/app_localization.dart';
import '../../models/complaint.dart';
import '../../services/voice_assistant_service.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  final MapController _mapController = MapController();
  final VoiceAssistantService _voiceService = VoiceAssistantService();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
    _voiceService.speakingStream.listen((speaking) {
      if (mounted) setState(() => _isSpeaking = speaking);
    });
  }

  Future<void> _initData() async {
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    _voiceService.updateLocale(theme.locale.languageCode);
    await Provider.of<WorkerProvider>(context, listen: false).fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final worker = Provider.of<WorkerProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    _voiceService.updateLocale(theme.locale.languageCode);

    final activeTask = worker.tasks.isNotEmpty 
        ? worker.tasks.firstWhere((t) => t.status != ComplaintStatus.resolved, orElse: () => worker.tasks.first) 
        : null;

    return AppScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${context.tr('hello')}, ${user?.fullName.split(' ')[0] ?? 'Worker'}', style: AppTypography.heading(fontSize: 20)),
            Text('ID: SW-${user?.fullName.hashCode.toString().substring(0,4) ?? "1024"}', style: AppTypography.body(fontSize: 12, color: AppColors.mutedText)),
          ],
        ),
        actions: [
          _buildDutyToggle(worker),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => worker.fetchTasks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Grid
              Row(
                children: [
                  Expanded(child: StatCard(value: worker.tasks.length.toString(), label: context.tr('assigned'))),
                  const SizedBox(width: 12),
                  Expanded(child: StatCard(value: worker.pendingCount.toString(), label: context.tr('pending_action'), valueColor: AppColors.workerPrimary, isHighlighted: true)),
                  const SizedBox(width: 12),
                  Expanded(child: StatCard(value: worker.completedCount.toString(), label: context.tr('resolved'), valueColor: Colors.green)),
                ],
              ),
              const SizedBox(height: 32),

              // Voice Alert Card
              _buildVoiceAlertCard(),
              const SizedBox(height: 32),

              SectionHeader(eyebrow: context.tr('map_preview'), title: 'Route Overview'),
              const SizedBox(height: 16),
              _buildMapPreview(activeTask),
              const SizedBox(height: 32),

              SectionHeader(eyebrow: 'ACTION', title: context.tr('quick_access')),
              const SizedBox(height: 16),
              _buildQuickActions(activeTask),
              const SizedBox(height: 32),

              SectionHeader(eyebrow: 'CURRENT', title: context.tr('queue')),
              const SizedBox(height: 16),
              if (worker.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (worker.tasks.isEmpty)
                _buildEmptyState()
              else
                _buildActiveTaskCard(activeTask!),
              
              const SizedBox(height: 32),

              // SOS Trigger Section
              _buildSOSTrigger(),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceAlertCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: AppColors.workerPrimary.withValues(alpha: 0.3),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.workerPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isSpeaking ? Icons.volume_up_rounded : Icons.volume_down_rounded, 
              color: AppColors.workerPrimary, 
              size: 28
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Voice Alert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                Text(
                  _isSpeaking ? 'Announcing now...' : 'Tap to hear assigned work details', 
                  style: const TextStyle(fontSize: 12, color: AppColors.mutedText)
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _isSpeaking ? null : () => _voiceService.playWorkDetailsTamil(),
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isSpeaking ? AppColors.disabled.withValues(alpha: 0.1) : AppColors.workerPrimary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _isSpeaking ? Icons.graphic_eq : Icons.play_arrow_rounded, 
                color: Colors.white, 
                size: 24
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSTrigger() {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/sos-emergency'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.security_rounded, color: Colors.red, size: 32),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SOS EMERGENCY',
                    style: AppTypography.heading(fontSize: 18).copyWith(color: Colors.red),
                  ),
                  Text(
                    'Click for immediate assistance',
                    style: AppTypography.body(fontSize: 12, color: Colors.red.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.red, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview(dynamic task) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(13.0827, 80.2707),
            initialZoom: 13.0,
            interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.swachhai',
            ),
            MarkerLayer(
              markers: [
                const Marker(
                  point: LatLng(13.0827, 80.2707),
                  child: Icon(Icons.my_location, color: Colors.blue, size: 24),
                ),
                if (task != null)
                  const Marker(
                    point: LatLng(13.0850, 80.2750),
                    child: Icon(Icons.location_on, color: Colors.red, size: 24),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(dynamic task) {
    return Row(
      children: [
        _QuickActionBtn(
          icon: Icons.navigation_outlined, 
          label: context.tr('start'), 
          color: AppColors.workerPrimary,
          onTap: () => Navigator.pushNamed(context, '/worker-map', arguments: task),
        ),
        const SizedBox(width: 12),
        _QuickActionBtn(
          icon: Icons.assignment_outlined, 
          label: context.tr('assigned'), 
          color: Colors.blue,
          onTap: () => Navigator.pushNamed(context, '/assigned-tasks'),
        ),
        const SizedBox(width: 12),
        _QuickActionBtn(
          icon: Icons.person_outline, 
          label: context.tr('profile'), 
          color: AppColors.citizenPrimary,
          onTap: () => Navigator.pushNamed(context, '/worker-profile'),
        ),
      ],
    );
  }

  Widget _buildActiveTaskCard(dynamic task) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 12),
          Text(task.title, style: AppTypography.heading(fontSize: 18)),
          Text(task.area, style: AppTypography.body(fontSize: 14, color: AppColors.mutedText)),
          const SizedBox(height: 20),
          GlassButton(
            text: context.tr('view_all'), 
            onPressed: () => Navigator.pushNamed(context, '/task-details', arguments: task),
          ),
        ],
      ),
    );
  }

  Widget _buildDutyToggle(WorkerProvider worker) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: worker.isOnDuty ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: worker.isOnDuty ? Colors.green : Colors.red, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            worker.isOnDuty ? context.tr('on_duty') : context.tr('off_duty'), 
            style: TextStyle(
              fontSize: 10, 
              fontWeight: FontWeight.bold, 
              color: worker.isOnDuty ? Colors.green : Colors.red
            )
          ),
          const SizedBox(width: 8),
          SizedBox(height: 20, width: 34, child: Switch.adaptive(value: worker.isOnDuty, onChanged: (v) => worker.toggleDuty(), activeColor: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Text('No tasks assigned yet.', style: AppTypography.body(color: AppColors.mutedText)));
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 16),
          borderColor: color.withValues(alpha: 0.2),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
