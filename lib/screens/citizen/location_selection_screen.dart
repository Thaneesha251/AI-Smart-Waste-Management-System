import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import '../../providers/location_provider.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/gradients.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final MapController _mapController = MapController();
  LatLng _selectedPosition = const LatLng(13.0827, 80.2707); // Chennai default
  String _address = "Fetching address...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final location = loc.Location();
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) return;
    }

    final data = await location.getLocation();
    if (data.latitude != null && data.longitude != null) {
      setState(() {
        _selectedPosition = LatLng(data.latitude!, data.longitude!);
        _address = "Address at ${_selectedPosition.latitude.toStringAsFixed(4)}, ${_selectedPosition.longitude.toStringAsFixed(4)}";
        _isLoading = false;
      });
      _mapController.move(_selectedPosition, 15.0);
    }
  }

  void _handleConfirm() {
    final locProvider = Provider.of<LocationProvider>(context, listen: false);
    locProvider.updateLocation("Chennai", _address, "Zone Detected"); 
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location Updated'), backgroundColor: AppColors.citizenPrimary),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPosition,
              initialZoom: 15.0,
              onTap: (tapTap, latLng) {
                setState(() {
                  _selectedPosition = latLng;
                  _address = "Tapped at ${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}";
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.swachhai',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPosition,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.redAccent,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.redAccent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _address,
                            style: AppTypography.body(fontSize: 14, color: AppColors.primaryText).copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GlassButton(
                      text: 'CONFIRM LOCATION',
                      gradient: AppGradients.citizen,
                      onPressed: _handleConfirm,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 180),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: _getUserLocation,
          child: const Icon(Icons.my_location, color: AppColors.citizenPrimary),
        ),
      ),
    );
  }
}
