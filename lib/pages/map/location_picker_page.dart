import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? _pickedLocation;

  void _onTap(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Joylashuvni tanlang')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(41.311081, 69.240562), // Toshkent
          zoom: 10,
        ),
        onTap: _onTap,
        markers: _pickedLocation != null
            ? {
          Marker(
            markerId: MarkerId("picked"),
            position: _pickedLocation!,
          ),
        }
            : {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_pickedLocation != null) {
            Navigator.pop(context, _pickedLocation);
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
