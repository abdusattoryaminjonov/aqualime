import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/firebase_service.dart';
import '../map/location_picker_page.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _fishController = TextEditingController();
  final TextEditingController _tel1Controller = TextEditingController();
  final TextEditingController _tel2Controller = TextEditingController();
  final TextEditingController _adressController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _defaultWaterCountController = TextEditingController();

  late String _userId = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _generateUserId();
  }

  Future<void> _generateUserId() async {
    final id = await _firestoreService.generateNextUserId();
    setState(() {
      _userId = id;
      _loading = false;
    });
  }

  void _saveUser() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      await _firestoreService.addUser(
        userId: _userId,
        fish: _fishController.text,
        tel1: _tel1Controller.text,
        tel2: _tel2Controller.text,
        adress: _adressController.text,
        location: _locationController.text,
        defaultWaterCount: int.parse(_defaultWaterCountController.text),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Foydalanuvchi muvaffaqiyatli qo‘shildi", style: TextStyle(color: Colors.white)),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      // Maydonlarni tozalash
      _fishController.clear();
      _tel1Controller.clear();
      _tel2Controller.clear();
      _adressController.clear();
      _locationController.clear();
      _defaultWaterCountController.clear();

      // Keyingi userId uchun yangilash
      await _generateUserId();
    }
  }

  @override
  void dispose() {
    _fishController.dispose();
    _tel1Controller.dispose();
    _tel2Controller.dispose();
    _adressController.dispose();
    _locationController.dispose();
    _defaultWaterCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
          title: Text('Yangi Mijoz qo‘shish',style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,

          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Yangi User ID: $_userId", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildTextField(_fishController, 'FISH'),
              _buildTextField(_tel1Controller, 'Telefon 1',TextInputType.phone),
              _buildTextField(_tel2Controller, 'Telefon 2',TextInputType.phone),
              _buildTextField(_adressController, 'Manzil'),
              _buildLocationPicker(context),
              _buildTextField(_defaultWaterCountController, 'Default water count', TextInputType.number),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: _saveUser,
                child: Text('Saqlash',style: TextStyle(
                  color: Colors.white,
                  fontSize: 20
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
        ),
        validator: (value) => value == null || value.isEmpty ? 'Iltimos, $label kiriting' : null,
      ),
    );
  }
  Widget _buildLocationPicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LocationPickerPage()),
          );

          if (result != null && result is LatLng) {
            setState(() {
              _locationController.text = '${result.latitude},${result.longitude}';
            });
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Joylashuv (xaritadan tanlang)',
              suffixIcon: Icon(Icons.map),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Iltimos, joylashuvni tanlang' : null,
          ),
        ),
      ),
    );
  }

}
