import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/firebase_service.dart';

class ZakazCard extends StatefulWidget {
  final DocumentSnapshot orderData;
  final Map<String, dynamic> userData;
  final String user_id;

  const ZakazCard({
    super.key,
    required this.orderData,
    required this.userData,
    required this.user_id,
  });

  @override
  State<ZakazCard> createState() => _ZakazCardState();
}

class _ZakazCardState extends State<ZakazCard> {
  late TextEditingController givedCtrl;
  late TextEditingController returnedCtrl;
  late TextEditingController paymentCtrl;
  final firestoreService = FirestoreService();

  int waterPrice = 17000;
  String paymentType = 'naqd';

  Future<void> _loadPriceFromFirestore() async {
    int price = await firestoreService.getBottlePrice();
      waterPrice = price;
  }

  Future<void> launchCaller(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Telefon qilishning iloji yo‘q: $number';
    }
  }

  @override
  void initState() {
    super.initState();
    final data = widget.orderData;
    _loadPriceFromFirestore();

    givedCtrl = TextEditingController(text: data['gived_bottle'].toString());
    returnedCtrl = TextEditingController(text: data['returned_bottle'].toString());
    paymentCtrl = TextEditingController(
      text: (int.tryParse(data['gived_bottle'].toString())! * waterPrice).toString(),
    );

    paymentType = (data['type_of_payment']?.toLowerCase() ?? 'naqd');

    givedCtrl.addListener(_recalculate);
    returnedCtrl.addListener(_recalculate);
  }

  void _recalculate() {
    int gived = int.tryParse(givedCtrl.text) ?? 0;
    int calculatedSum = gived * waterPrice;
    paymentCtrl.text = calculatedSum.toString();
    setState(() {});
  }

  @override
  void dispose() {
    givedCtrl.dispose();
    returnedCtrl.dispose();
    paymentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = widget.userData;
    final data = widget.orderData;
    final orderId = data.id;

    int gived = int.tryParse(givedCtrl.text) ?? 0;
    int returned = int.tryParse(returnedCtrl.text) ?? 0;
    int qoldi = gived - returned;
    int tolov = int.tryParse(paymentCtrl.text) ?? 0;
    int summa = gived * waterPrice;
    int qarz = summa - tolov;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: data['done'] == true ?  Colors.red : Colors.blueAccent,
          child: Text(data['water_count'].toString(), style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            fontSize: 30
          )),
        ),
        title: Row(
          children: [
            Text(widget.user_id,style:TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.purple,
              fontSize: 25
            ),),
          ],
        ),
        subtitle: Text(userData['adress'] ?? ''),
        children: [
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.green),
            title: Text("Telefon1: ${userData['tel1']}"),
            onTap: () => launchCaller(userData['tel1']),
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.green),
            title: Text("Telefon2: ${userData['tel2']}"),
            onTap: () => launchCaller(userData['tel2']),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: givedCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Berilgan butilka"),
                ),
                TextField(
                  controller: returnedCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Qaytarilgan butilka"),
                ),
                const SizedBox(height: 8),
                Text("Zakaz summasi: $summa so'm"),
                Text("Qoldiq: $qoldi"),
                TextField(
                  controller: paymentCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "To'lov (so'm)"),
                ),
                DropdownButton<String>(
                  value: paymentType,
                  items: ['naqd', 'karta'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        paymentType = newValue;
                      });
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
                          'gived_bottle': gived,
                          'returned_bottle': returned,
                          'qoldi': qoldi,
                          'summa': summa,
                          'summa_tolov': tolov,
                          'summa_qarz': qarz,
                          'type_of_payment': paymentType,
                          'done': true,
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Yangilandi!", style: TextStyle(color: Colors.white)),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(10),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      child: const Text("Saqlash"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}