import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';

class AIWasteGuideScreen extends StatefulWidget {
  const AIWasteGuideScreen({super.key});

  @override
  State<AIWasteGuideScreen> createState() => _AIWasteGuideScreenState();
}

class _AIWasteGuideScreenState extends State<AIWasteGuideScreen> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = "";

  final List<Map<String, dynamic>> _wasteItems = [
    {
      'name': 'Plastic Bottle',
      'category': 'Plastic',
      'recyclable': true,
      'method': 'Rinse and place in yellow bin',
      'bin': 'Plastic Recycling Bin',
      'tip': 'Remove the cap to ensure better recycling.',
    },
    {
      'name': 'Food Waste',
      'category': 'Organic',
      'recyclable': false,
      'method': 'Compost at home or use green bin',
      'bin': 'Organic Waste Bin',
      'tip': 'Organic waste makes great fertilizer!',
    },
    {
      'name': 'Paper',
      'category': 'Paper',
      'recyclable': true,
      'method': 'Keep dry and place in blue bin',
      'bin': 'Paper Recycling Bin',
      'tip': 'Avoid recycling shredded paper if possible.',
    },
    {
      'name': 'Battery',
      'category': 'Hazardous',
      'recyclable': false,
      'method': 'Drop at specialized e-waste centers',
      'bin': 'Hazardous Waste Bin',
      'tip': 'Never throw batteries in general waste.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _wasteItems.where((i) => i['name'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return AppScaffold(
      appBar: AppBar(
        title: Text('AI Waste Guide', style: AppTypography.heading(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'Search waste item (e.g. Bottle)',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.citizenPrimary.withValues(alpha: 0.1),
                              child: Icon(item['recyclable'] ? Icons.recycling : Icons.delete_outline, color: AppColors.citizenPrimary),
                            ),
                            title: Text(item['name'], style: AppTypography.body(fontSize: 15, color: AppColors.primaryText).copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Text(item['category'], style: AppTypography.body(fontSize: 12, color: AppColors.mutedText)),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildGuideRow('Disposal', item['method']),
                                    const SizedBox(height: 12),
                                    _buildGuideRow('Suggested Bin', item['bin']),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 18),
                                          const SizedBox(width: 12),
                                          Expanded(child: Text(item['tip'], style: AppTypography.body(fontSize: 12).copyWith(fontStyle: FontStyle.italic))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTypography.eyebrow(fontSize: 9)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.body(fontSize: 14, color: AppColors.primaryText).copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
