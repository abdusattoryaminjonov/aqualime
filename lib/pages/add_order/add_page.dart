import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';

class AddOrderPage extends StatefulWidget {
  const AddOrderPage({super.key});

  @override
  State<AddOrderPage> createState() => _AddOrderPageState();
}

class _AddOrderPageState extends State<AddOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _waterCountController = TextEditingController();
  final TextEditingController _summaController = TextEditingController();

  String _selectedUserId = '';
  List<String> _userIdList = [];

  int waterPrice = 17000;

  String _orderId = '';
  DateTime _selectedDate = DateTime.now();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadPriceFromFirestore();
  }

  Future<void> _loadPriceFromFirestore() async {
    int price = await _firestoreService.getBottlePrice();
    setState(() {
      waterPrice = price;
    });
  }

  Future<void> _initializeData() async {
    final orderId = await _firestoreService.generateNextOrderId();
    final users = await _firestoreService.getAllUserIds();
    setState(() {
      _orderId = orderId;
      _userIdList = users;
      _selectedUserId = users.isNotEmpty ? users.first : '';
      _loading = false;
    });
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveOrder() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      await _firestoreService.addOrder(
        orderId: _orderId,
        userId: _selectedUserId,
        sana: DateFormat('yyyy-MM-dd').format(_selectedDate),
        waterCount: int.parse(_waterCountController.text),
        givedBottle: 0,
        returnedBottle: 0,
        qoldi: 0,
        summa: int.parse(_summaController.text),
        summaTolov: 0,
        summaQarz: 0,
        typeOfPayment: 'Naqd',
        done: false
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Buyurtma saqlandi", style: TextStyle(color: Colors.white)),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      _waterCountController.clear();
      _summaController.clear();
      await _initializeData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
          centerTitle: true,
          title: Text('Buyurtma qo‘shish',style: TextStyle(color: Colors.white),),
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
              Text('Buyurtma ID: $_orderId', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedUserId,
                items: _userIdList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedUserId = val);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Foydalanuvchi tanlang',
                ),
              ),
              SizedBox(height: 12),
              ListTile(
                title: Text('Sana: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              _buildTextField(_waterCountController, 'Suv miqdori (18.9L × ${waterPrice} so‘m)', isWater: true),
              _buildTextField(_summaController, 'Umumiy summa'),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: _saveOrder,
                child: Text('Saqlash', style: TextStyle(fontSize: 20,color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        TextInputType keyboardType = TextInputType.number,
        bool isWater = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) =>
        value == null || value.isEmpty ? 'Iltimos, $label kiriting' : null,
        onChanged: isWater
            ? (val) {
          final count = int.tryParse(val);
          if (count != null) {
            final calculatedSum = count * waterPrice;
            _summaController.text = calculatedSum.toString();
          } else {
            _summaController.clear();
          }
        }
            : null,
      ),
    );
  }

}
