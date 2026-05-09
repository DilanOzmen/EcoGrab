import 'package:flutter/foundation.dart'; // debugPrint için
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:food_waste_app/core/app_state.dart';

class LocationService {
  static Future<void> fetchAndSaveLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    // YENİ: locationSettings kullanımı
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    String addressLabel = "Konum alındı";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        addressLabel = "${place.subAdministrativeArea}, ${place.administrativeArea}";
      }
    } catch (e) {
      debugPrint("Adres dönüştürme hatası: $e");
    }

    AppState.setLocation(
      position.latitude, 
      position.longitude, 
      address: addressLabel
    );
  }
}