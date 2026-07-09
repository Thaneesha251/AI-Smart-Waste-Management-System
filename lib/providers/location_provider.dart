import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class LocationProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  
  String _city = 'Chennai';
  String _area = 'Anna Nagar';
  String _zone = 'Zone 5';

  String get city => _city;
  String get area => _area;
  String get zone => _zone;

  Future<void> init() async {
    final loc = await _storage.getLocation();
    if (loc != null) {
      _city = loc['city'] ?? _city;
      _area = loc['area'] ?? _area;
      _zone = loc['zone'] ?? _zone;
      notifyListeners();
    }
  }

  Future<void> updateLocation(String city, String area, String zone) async {
    _city = city;
    _area = area;
    _zone = zone;
    await _storage.saveLocation({
      'city': city,
      'area': area,
      'zone': zone,
    });
    notifyListeners();
  }
}
