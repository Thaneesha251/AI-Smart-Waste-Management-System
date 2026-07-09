import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';

class NearbyBinsScreen extends StatefulWidget {
  const NearbyBinsScreen({super.key});

  @override
  State<NearbyBinsScreen> createState() => _NearbyBinsScreenState();
}

class _NearbyBinsScreenState extends State<NearbyBinsScreen> {
  final LatLng _initialPosition = const LatLng(13.0827, 80.2707);
  String? _selectedBin;

  final List<Map<String, dynamic>> _bins = [
    {'id': '1', 'type': 'Plastic Recycling', 'pos': const LatLng(13.0850, 80.2720), 'capacity': '75%', 'distance': '200m'},
    {'id': '2', 'type': 'Organic Waste', 'pos': const LatLng(13.0810, 80.2680), 'capacity': '40%', 'distance': '450m'},
    {'id': '3', 'type': 'General Waste', 'pos': const LatLng(13.0835, 80.2750), 'capacity': '90%', 'distance': '800m'},
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Nearby Bins', style: AppTypography.heading(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _initialPosition,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.swachhai',
              ),
              MarkerLayer(
                markers: _bins.map((b) => Marker(
                  point: b['pos'],
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedBin = b['id']),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppColors.citizenPrimary,
                      size: 30,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          if (_selectedBin != null)
            Positioned(
              bottom: 40, left: 24, right: 24,
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.citizenPrimary.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.delete_outline, color: AppColors.citizenPrimary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_bins.firstWhere((b) => b['id'] == _selectedBin)['type'], style: AppTypography.body(fontSize: 16, color: AppColors.primaryText).copyWith(fontWeight: FontWeight.bold)),
                              Text('Distance: ${_bins.firstWhere((b) => b['id'] == _selectedBin)['distance']}', style: AppTypography.body(fontSize: 12, color: AppColors.mutedText)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(_bins.firstWhere((b) => b['id'] == _selectedBin)['capacity'], style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GlassButton(
                      text: 'NAVIGATE',
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Starting navigation (Demo)...')));
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
