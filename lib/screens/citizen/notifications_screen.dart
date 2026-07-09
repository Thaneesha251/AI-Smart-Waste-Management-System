import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Report AI Verified',
      'message': 'Your report #1024 has been verified. Worker is assigned.',
      'time': '2 mins ago',
      'group': 'Today',
      'isRead': false,
      'icon': Icons.check_circle_outline,
      'color': AppColors.citizenPrimary,
    },
    {
      'id': '2',
      'title': 'Collection Started',
      'message': 'Worker is 0.4km away from your location.',
      'time': '1 hour ago',
      'group': 'Today',
      'isRead': false,
      'icon': Icons.navigation_outlined,
      'color': AppColors.workerPrimary,
    },
    {
      'id': '3',
      'title': 'System Update',
      'message': 'Maintenance scheduled for 12:00 AM tonight.',
      'time': '3 hours ago',
      'group': 'Yesterday',
      'isRead': true,
      'icon': Icons.info_outline,
      'color': Colors.blueAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Notifications', style: AppTypography.heading(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, size: 20, color: AppColors.citizenPrimary),
            onPressed: () => setState(() {
              for (var n in _notifications) {
                n['isRead'] = true;
              }
            }),
          ),
        ],
      ),
      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final n = _notifications[index];
              final showHeader = index == 0 || _notifications[index-1]['group'] != n['group'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHeader)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16, top: 8),
                      child: Text(n['group'].toUpperCase(), style: AppTypography.eyebrow(fontSize: 10)),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: n['color'].withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                            child: Icon(n['icon'], color: n['color'], size: 22),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(n['title'], style: AppTypography.body(fontSize: 14, color: AppColors.primaryText).copyWith(fontWeight: FontWeight.w600)),
                                    if (!n['isRead']) Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(n['message'], style: AppTypography.body(fontSize: 12, color: AppColors.secondaryText)),
                                const SizedBox(height: 8),
                                Text(n['time'], style: AppTypography.body(fontSize: 10, color: AppColors.mutedText)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
