import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import '../../models/complaint.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/gradients.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../core/localization/app_localization.dart';
import '../../providers/theme_provider.dart';
import '../../services/voice_assistant_service.dart';

class WorkerMapScreen extends StatefulWidget {
  final Complaint? task;
  const WorkerMapScreen({super.key, this.task});

  @override
  State<WorkerMapScreen> createState() => _WorkerMapScreenState();
}

class _WorkerMapScreenState extends State<WorkerMapScreen> {
  final MapController _mapController = MapController();
  final VoiceAssistantService _voiceService = VoiceAssistantService();
  LatLng _workerPos = const LatLng(13.0827, 80.2707);
  LatLng? _taskPos;
  bool _isNavigating = false;
  String _mode = 'two_wheeler';

  @override
  void initState() {
    super.initState();
    _setPositions();
    _trackLocation();
  }

  void _setPositions() {
    if (widget.task != null) {
      _taskPos = const LatLng(13.0850, 80.2750); 
    }
  }

  Future<void> _trackLocation() async {
    final location = loc.Location();
    location.onLocationChanged.listen((l) {
      if (mounted) {
        final newPos = LatLng(l.latitude!, l.longitude!);
        if (_isNavigating && _calculateDistance(_workerPos, newPos) > 0.05) {
          // Voice strictly in Tamil
          _voiceService.speak("பாதை மாற்றியமைக்கப்பட்டது.");
        }
        setState(() => _workerPos = newPos);
      }
    });
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    return (p1.latitude - p2.latitude).abs() + (p1.longitude - p2.longitude).abs();
  }

  void _startNavigation() {
    setState(() => _isNavigating = true);
    // Voice strictly in Tamil
    _voiceService.speak("வழிகாட்டல் தொடங்கியது. வடக்கு நோக்கி செல்லுங்கள்.");
    
    Future.delayed(const Duration(seconds: 5), () {
       if (_isNavigating && mounted) {
         _voiceService.speak("400 மீட்டருக்கு நேராக செல்லவும்");
       }
    });
    
    Future.delayed(const Duration(seconds: 15), () {
       if (_isNavigating && mounted) {
         _voiceService.speak("உங்கள் இலக்கை வந்தடைந்துவிட்டீர்கள்");
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(_isNavigating ? context.tr('navigating') : context.tr('map_preview'), style: AppTypography.heading(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _taskPos ?? _workerPos, initialZoom: 15.0),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.swachhai',
              ),
              if (_taskPos != null)
                PolylineLayer(
                  polylines: [
                    Polyline(points: [_workerPos, _taskPos!], color: AppColors.workerPrimary, strokeWidth: 5.0),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(point: _workerPos, width: 40, height: 40, child: const Icon(Icons.my_location, color: Colors.blue, size: 30)),
                  if (_taskPos != null)
                    Marker(point: _taskPos!, width: 40, height: 40, child: const Icon(Icons.location_on, color: Colors.red, size: 30)),
                ],
              ),
            ],
          ),
          
          if (!_isNavigating)
            Positioned(
              top: 20, left: 20, right: 20,
              child: GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                borderRadius: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _modeIcon(Icons.directions_walk, 'walking'),
                    _modeIcon(Icons.moped, 'two_wheeler'),
                    _modeIcon(Icons.directions_car, 'four_wheeler'),
                  ],
                ),
              ),
            ),

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
                        decoration: BoxDecoration(color: AppColors.workerPrimary.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(_isNavigating ? Icons.navigation : Icons.directions, color: AppColors.workerPrimary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // UI text still localized, but voice (triggered by buttons) is Tamil
                            Text(_isNavigating ? context.tr('nav_straight') : widget.task?.title ?? 'No target', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${context.tr('distance')}: 1.2 km • ${context.tr('eta')}: 4 mins', style: AppTypography.body(fontSize: 12, color: AppColors.mutedText)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GlassButton(
                    text: _isNavigating ? context.tr('exit') : context.tr('start'),
                    gradient: _isNavigating ? const LinearGradient(colors: [Colors.redAccent, Colors.red]) : AppGradients.worker,
                    onPressed: () => _isNavigating ? setState(() => _isNavigating = false) : _startNavigation(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeIcon(IconData icon, String mode) {
    final active = _mode == mode;
    return IconButton(
      icon: Icon(icon, color: active ? AppColors.workerPrimary : AppColors.disabled),
      onPressed: () => setState(() => _mode = mode),
    );
  }
}
