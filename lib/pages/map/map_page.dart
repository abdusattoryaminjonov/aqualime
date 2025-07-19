import 'dart:ui' as ui;
import 'package:aqualime/services/log_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grouped_action_buttons/action_button.dart';
import 'package:grouped_action_buttons/expandable_fab.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aqualime/services/http_service.dart';

import '../../models/orders_model.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LocationData? _currentLocation;
  final Location _location = Location();
  final HttpService httpService = HttpService();

  int asistent = 0;
  int asistentT = 0;

  final Set<Marker> _markers = {};
  Order? selectedZakaz;
  double? selectedLat;
  double? selectedLng;
  LatLng get _latLng => _currentLocation != null
      ? LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)
      : LatLng(41.311081, 69.240562);

  @override
  void initState() {
    super.initState();
    _initialize();
  }


  Future<void> _initialize() async {
    await _getCurrentLocation();
    await _loadZakazlar();
    await _saveLocationToRealtimeDatabase();


  }


  Future<String> getDeviceId() async {
    String udId = await FlutterUdid.udid;
    String deviceId = udId;

    LogService.e(udId);
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    // return androidInfo.id.replaceAll(RegExp(r'[.#$\[\]]'), '_');
    return deviceId;
  }

  Future<void> _saveLocationToRealtimeDatabase() async {
    try {
      final String rawDeviceId = await getDeviceId();
      final String deviceId = rawDeviceId;

      if (_currentLocation != null) {
        final ref = FirebaseDatabase.instance.ref("locations/$deviceId");

        await ref.set({
          'lat': _currentLocation!.latitude,
          'lng': _currentLocation!.longitude,
          'timestamp': DateTime.now().toIso8601String(),
        });

        print("Joylashuv saqlandi: $deviceId");
      }
    } catch (e) {
      print("Joylashuvni saqlashda xatolik: $e");
    }
  }



  String? _calculateDistanceToSelected() {
    if (_currentLocation == null || selectedLat == null || selectedLng == null) return null;

    double distanceInMeters = Geolocator.distanceBetween(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
      selectedLat!,
      selectedLng!,
    );

    double distanceInKm = distanceInMeters / 1000;
    return "${distanceInKm.toStringAsFixed(2)} km";
  }


  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final locationData = await _location.getLocation();
    setState(() {
      _currentLocation = locationData;
    });

    await _saveLocationToRealtimeDatabase();
  }

  Future<BitmapDescriptor> createCustomMarkerBitmap(String text, int done, int type) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final double width = 120;
    final double height = 100;

    final double markerWidth = 100;
    final double markerHeight = 50;
    final double markerTop = 40;





    final Paint markerPaint = Paint()
      ..color = done == 0 && type == 1 ? Colors.purple : done == 0 && type == 0 ? Colors.red : done == 1 ? Colors.blueAccent : Colors.orange;

    const Radius radius = Radius.circular(15);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH((width - markerWidth) / 2, markerTop, markerWidth, markerHeight),
        topLeft: radius,
        topRight: radius,
        bottomRight: radius,
      ),
      markerPaint,
    );

    final parts = text.split('\n');
    String distance = parts.length > 0 ? parts[0] : '';
    String label = parts.length > 1 ? parts[1] : '';

    final distancePainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      text: TextSpan(
        text: distance,
        style: const TextStyle(fontSize: 25, color: Colors.purple, fontWeight: FontWeight.w900),
      ),
    );

    distancePainter.layout(maxWidth: width);
    distancePainter.paint(canvas, Offset((width - distancePainter.width) / 2, 5));

    final labelPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      text: TextSpan(
        text: label,
        style: const TextStyle(fontSize: 34, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );

    labelPainter.layout(maxWidth: markerWidth);
    labelPainter.paint(canvas, Offset((width - labelPainter.width) / 2, markerTop + (markerHeight - labelPainter.height) / 2));

    // Rasmga aylantirish
    final ui.Image image = await recorder.endRecording().toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }



  Future<void> _loadZakazlar() async {
    try {
      final OrdersModel response = await httpService.fetchOrders();

      final List<Order> orders = response.orders;

      LogService.i(orders.first.summa);

      for (var order in orders) {
        if (order.done != asistent) continue; // faqat done == 0 larni ko‘rsatamiz

        final String location = order.location;
        final parts = location.split(',');

        if (parts.length == 2) {
          final lat = double.tryParse(parts[0]);
          final lng = double.tryParse(parts[1]);

          if (lat != null && lng != null) {
            double distanceInMeters = Geolocator.distanceBetween(
              _currentLocation!.latitude!,
              _currentLocation!.longitude!,
              lat,
              lng,
            );

            double distanceInKm = distanceInMeters / 1000;
            String markerText = "${distanceInKm.toStringAsFixed(1)} km\n z${order.userId} ";
            LogService.i(markerText);

            final BitmapDescriptor markerIcon = await createCustomMarkerBitmap(
              markerText,
              order.done,
              order.type,
            );

            _markers.add(
              Marker(
                markerId: MarkerId(order.userId.toString()),
                position: LatLng(lat, lng),
                icon: markerIcon,
                onTap: () {
                  setState(() {
                    selectedZakaz = order;
                    selectedLat = lat;
                    selectedLng = lng;
                  });
                },
              ),
            );
          }
        }
      }


      setState(() {});
    } catch (e) {
      print("Error loading zakazlar: $e");
    }
  }

  void _openMaps() {
    if (selectedLat != null && selectedLng != null) {
      final Uri uri = Uri.parse("yandexnavi://build_route_on_map?lat_to=$selectedLat&lon_to=$selectedLng");

      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void collToUser(String phoneNumber,BuildContext context) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(ClipboardData(text: phoneNumber));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Telefon raqam nusxalandi: $phoneNumber"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Xatolik: $e');
    }
  }

  void updateAsistentr(int a, int b) {
    setState(() {
      asistent = a;
      asistentT = b;
      _markers.clear();
    });
    _loadZakazlar();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _latLng,
              zoom: 10.5,
            ),
            zoomControlsEnabled: false,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          if (selectedZakaz != null)
            DraggableScrollableSheet(
              initialChildSize: 0.32,
              minChildSize: 0.2,
              maxChildSize: 0.6,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Matnli qism
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Text(
                                  "Zakaz: ${selectedZakaz!.fish}",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${_calculateDistanceToSelected() ?? '-'}",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text("Suv soni: ",style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(
                                      selectedZakaz!.givedBottle.toString(),
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(" ta",style: TextStyle(fontSize: 16),),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text("Manzil:", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  selectedZakaz!.adress,
                                  softWrap: true,
                                  maxLines: null,
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    collToUser(selectedZakaz!.tel1,context);
                                  },
                                  icon: Icon(Icons.phone),
                                  label: Text("${selectedZakaz!.tel1}"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    collToUser(selectedZakaz!.tel2,context);
                                  },
                                  icon: Icon(Icons.phone),
                                  label: Text("${selectedZakaz!.tel2}"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: _openMaps,
                              icon: Icon(Icons.navigation),
                              label: Text("Borish"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: GroupedActionButtons(
        distance: 112,
        openButtonIcon: const Icon(Icons.accessibility,color: Colors.white,),
        closeButtonIcon: const Icon(Icons.close),
        children: [
          ActionButton(
            onPressed: () => updateAsistentr(0,0),
            backgroundColor: Colors.red,
            icon: const Icon(Iconsax.truck_fast,color: Colors.white,),
          ),
          ActionButton(
            onPressed: () => updateAsistentr(-1,0),
            backgroundColor: Colors.orange,
            icon: const Icon(Iconsax.truck_remove),
          ),
          ActionButton(
            onPressed: () => updateAsistentr(1,0),
            backgroundColor: Colors.blueAccent,
            icon: const Icon(Iconsax.truck_tick),
          ),
          ActionButton(
            onPressed: () => updateAsistentr(0,1),
            backgroundColor: Colors.purple,
            icon: const Icon(Iconsax.truck_time),
          ),
        ],
      ),
    );
  }
}