import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../services/http_service.dart';

class HomeDrawer extends StatelessWidget{

  final int totalZakaz;
  final int totalTarqatildi;
  final int water_count;
  final int totalAtmen;
  final int totalNaxt;
  final int totalKarta;
  final int umumiyQarz;
  final int ortiqchaPul;
  final int umumiyPul;

  final HttpService httpService;
  final employee;

  const HomeDrawer ({
    super.key,
    required this.totalZakaz,
    required this.totalTarqatildi,
    required this.water_count,
    required this.totalAtmen,
    required this.totalNaxt,
    required this.totalKarta,
    required this.umumiyQarz,
    required this.ortiqchaPul,
    required this.umumiyPul,
    required this.httpService,
    required this.employee
});


  Future<void> clearCache() async {
    await httpService.updateEmployee(
      id: employee.id,
      tuman_id: employee.tumanId,
      name: employee.name,
      password: employee.password,
      qarz: 0,
      naqd: 0,
      karta: 0,
      zakaz: -1,
      tarqatildi: 0,
      ortiqchaPul: 0,
      kassaSanasi: employee.kassa_sanasi,
      atmen: 0
    );
    var box = Hive.box('myCache');
    box.clear();
  }


  @override
  Widget build(BuildContext context) {
    return  Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
           DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: SizedBox.expand(
              child: Image.asset(
                'assets/images/drawerImage.png',
                alignment: Alignment.center,
              ),
            ),
            // child: Text(
            //   'AquaLime',
            //   style: TextStyle(color: Colors.white, fontSize: 24),
            // ),
          ),
          ListTile(
            leading: const Icon(
              Icons.water_drop,
              size: 30,
              color: Colors.blueAccent,
            ),
            title: Text('Zakaz: $totalZakaz '),
          ),
          ListTile(
            leading: const Icon(
              Iconsax.truck_fast,
              size: 30,
              color: Colors.blueAccent,
            ),
            title: Text('Tarqatildi: $totalTarqatildi/$water_count'),
          ),
          ListTile(
            leading: const Icon(
              Iconsax.truck_remove,
              size: 30,
              color: Colors.red,
            ),
            title: Text('Bekor qilindi: $totalAtmen'),
          ),
          ListTile(
            leading: const Icon(
              Iconsax.money,
              size: 30,
              color: Colors.blueAccent,
            ),
            title:Text('Naxt: ${totalNaxt} so\'m'),
          ),
          ListTile(
            leading: const Icon(
              Iconsax.card,
              size: 30,
              color: Colors.blueAccent,
            ),
            title:  Text('Plastik: ${totalKarta} so\'m'),
          ),
          ListTile(
            leading: const Icon(
              Icons.money_off,
              size: 30,
              color: Colors.red,
            ),
            title: Text('Qarz: ${umumiyQarz} so\'m'),
          ),

          ListTile(
            leading: const Icon(
              Icons.monetization_on_outlined,
              size: 30,
              color: Colors.green,
            ),
            title: Text("Qo'shimcha pull : ${ortiqchaPul} so\'m"),
          ),

          ListTile(
            leading: const Icon(
              Iconsax.calculator,
              size: 30,
              color: Colors.blueAccent,
            ),
            title: Text('Summa: ${umumiyPul} so\'m'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: const Text(
                      "KASSA TOPSHIRISH",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      "Bugun sotilgan suvlarning umumiy summasi:\n\n${umumiyPul} so'm",
                      style: const TextStyle(fontSize: 18),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // AlertDialog ni yopish
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          clearCache();
                          Navigator.of(context).pop(); // AlertDialog ni yopish
                          Navigator.of(context).pop(); // Drawer ni yopish
                        },
                        child: const Text(
                          "OK",
                          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Iconsax.money_send, color: Colors.white),
              label: const Text(
                'KASSA',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

}