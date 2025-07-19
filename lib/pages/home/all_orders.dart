import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/http_service.dart';
import '../../models/orders_model.dart';

class AllOrdersPage extends StatefulWidget {
  const AllOrdersPage({super.key});

  @override
  State<AllOrdersPage> createState() => _AllOrdersPageState();
}

class _AllOrdersPageState extends State<AllOrdersPage> {
  final HttpService httpService = HttpService();
  late Future<OrdersModel> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = httpService.fetchOrders();
  }

  void _refreshData() {
    setState(() {
      _ordersFuture = httpService.fetchOrders();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Sahifa yangilandi.", style: TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        duration: const Duration(seconds: 3),
      ),
    );
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
  Widget build(BuildContext context) {
    return FutureBuilder<OrdersModel>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Xatolik: ${snapshot.error}")));
        }

        if (!snapshot.hasData || snapshot.data!.orders.isEmpty) {
          return const Scaffold(body: Center(child: Text("Ma'lumot yo'q")));
        }

        final orderList = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              onPressed: (){
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back,
                size: 30,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.blueAccent,
            centerTitle: true,
            title: const Text("Barcha Zakazlar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            iconTheme: const IconThemeData(color: Colors.white, size: 30),
            actions: [
              IconButton(
                icon: const Icon(Iconsax.refresh, color: Colors.white, size: 30),
                onPressed: _refreshData,
              )
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: orderList.orders.isEmpty
                    ? const Center(child: Text("Zakazlar topilmadi"))
                    : ListView.separated(
                  itemCount: orderList.orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final order = orderList.orders[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                      shadowColor: Colors.blueAccent,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: order.done == 1 ? Colors.green : Colors.red,
                                  child: Icon(
                                    order.done == 1 ? Iconsax.truck_tick : Iconsax.truck_fast,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "z${order.userId}",
                                        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                                      ),
                                      const SizedBox(height: 4),
                                      Text("Summa: ${order.summaQarz} so'm", style: const TextStyle(fontSize: 18)),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      order.sana.toLocal().toString().split(' ')[0],
                                      style: const TextStyle(fontSize: 20, color: Colors.grey),
                                    ),

                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildDividerH(),
                            Row(
                              children: [
                                _buildBottleBox("Zakaz"),
                                _buildDivider(),
                                _buildBottleBox("Qaytarilgan"),
                                _buildDivider(),
                                _buildBottleBox("Qoldi"),
                              ],
                            ),
                            _buildDividerH(),
                            Row(
                              children: [
                                _buildBottleBoxN(order.givedBottle),
                                _buildDivider(),
                                _buildBottleBoxN(order.returnedBottle),
                                _buildDivider(),
                                _buildBottleBoxN(order.qoldi),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Colors.black12, indent: 12, endIndent: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottleBox(String label) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900))],
      ),
    );
  }

  Widget _buildBottleBoxN(int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value == 0 ? "" : value.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => Container(width: 1, height: 20, color: Colors.blueAccent);

  Widget _buildDividerH() => Container(width: double.infinity, height: 1, color: Colors.blueAccent);
}
