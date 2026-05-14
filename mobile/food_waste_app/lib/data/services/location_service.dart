import 'package:flutter/foundation.dart'; // debugPrint için
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:food_waste_app/core/app_state.dart';

class LocationService {
  static Future<void> fetchAndSaveLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("Konum servisi kapalı");
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint("Konum izni reddedildi");
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint("Konum izni kalıcı olarak reddedildi");
        return;
      }

      // YENİ: locationSettings kullanımı
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      debugPrint("Konum alındı: ${position.latitude}, ${position.longitude}");

      String addressLabel = "Konum alındı";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          addressLabel = "${place.subAdministrativeArea}, ${place.administrativeArea}";
          debugPrint("Adres: $addressLabel");
        }
      } catch (e) {
        debugPrint("Adres dönüştürme hatası: $e");
        // Adres dönüştürme başarısız olsa bile koordinatlar mevcut
      }

      await AppState.setLocation(
        position.latitude, 
        position.longitude, 
        address: addressLabel
      );
      
      debugPrint("AppState'e konum kaydedildi");
    } catch (e) {
      debugPrint("LocationService hatası: $e");
      rethrow; // Caller'ın da hata almasını sağla
    }
  }
}