import 'package:aqualime/pages/home/all_orders.dart';
import 'package:aqualime/pages/home/drawer_section.dart';
import 'package:aqualime/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/employees.dart';
import '../../services/http_service.dart';
import '../../models/orders_model.dart';
import '../../widgets/car_loading_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HttpService httpService = HttpService();

  final employeeBox = Hive.box<Employee>('employees');

  Future<OrdersModel>? _ordersFuture;

  late bool updateKassa;
  late bool updatedUser;
  int currentValue = 0;
  late int totalCarLength = 0;
  final int total = 0;
  late int totalZakaz = -1;
  late int totalTarqatildi = -1;
  late int totalBerildi = -1;

  late int water_count = 0;


  late int totalNaxt = 0;
  late int totalKarta = 0;

  late int totalAtmen = 0;
  late int umumiyQarz = 0;
  late int umumiyPul = 0;
  late int umumiyOrtiqchaPul = 0;

  void saveValues(int currentValue, int totalCarLength) {
    var box = Hive.box('myCache');
    box.put('currentValue', currentValue);
    box.put('totalCarLength', totalCarLength);
  }

  int getCurrentValue() {
    var box = Hive.box('myCache');
    return box.get('currentValue', defaultValue: 0);
  }

  int getTotalCarLength() {
    var box = Hive.box('myCache');
    return box.get('totalCarLength', defaultValue: 0);
  }



  void moveCar() {
    if (currentValue < totalCarLength) {
      currentValue++;
      saveValues(currentValue, totalCarLength);
    }
  }

  void _showOrderDialog(BuildContext context, Order order) {
    final TextEditingController givedBottleController =
    TextEditingController(text: order.givedBottle.toString());
    final TextEditingController returnedBottleController =
    TextEditingController(text: order.returnedBottle.toString());
    final TextEditingController paidAmountController = TextEditingController();
    const int bottlePrice = 17000;

    int qoldi = 0;
    int left = 0;
    int summa = 0;
    int ortiqchaPul = order.ortiqchapul;
    int qarz = 0;
    bool initialized = false;
    String selectedPaymentType = 'naqd';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updateCalculatedValues({bool updatePaid = false}) {
              final gived = int.tryParse(givedBottleController.text) ?? 0;
              final returned = int.tryParse(returnedBottleController.text) ?? 0;
              final paid = int.tryParse(paidAmountController.text) ?? 0;

              final total = gived * bottlePrice;
              final left2 = order.qoldi -returned;
              final debt = total - paid;

              setState(() {
                left = left2;
                qoldi = gived;
                summa = total;
                qarz = debt > 0 ? debt : 0;
                if (!updatePaid &&
                    (paidAmountController.text.isEmpty ||
                        int.tryParse(paidAmountController.text) == 0)) {
                  paidAmountController.text = total.toString();
                }
              });
            }

            if (!initialized) {
              initialized = true;
              updateCalculatedValues();
            }

            return AlertDialog(
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "👤 z${order.userId}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  SizedBox(height: 4),
                  Text("Suv narxi: $bottlePrice so'm"),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: TextField(
                              controller: givedBottleController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Beriladigan K",
                                prefixIcon: Icon(Icons.water_drop_outlined),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (_) {
                                // final gived = int.tryParse(givedBottleController.text) ?? 0;
                                // final returned = int.tryParse(returnedBottleController.text) ?? 0;
                                // if (returned > gived) {
                                //   ScaffoldMessenger.of(context).showSnackBar(
                                //     SnackBar(
                                //       content: Text("❗️Qaytarilgan kapsula soni berilgandan ko‘p bo‘lishi mumkin emas."),
                                //       backgroundColor: Colors.red,
                                //       duration: Duration(seconds: 2),
                                //       behavior: SnackBarBehavior.floating,
                                //       margin: EdgeInsets.all(10),
                                //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                //     ),
                                //   );
                                //   return;
                                //}
                                updateCalculatedValues();
                              }
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: returnedBottleController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Olinadigan K",
                              prefixIcon: Icon(Icons.undo),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => updateCalculatedValues(),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),
                    TextField(
                      controller: paidAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "To'langan summa",
                        prefixIcon: Icon(Icons.payments),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) =>
                          updateCalculatedValues(updatePaid: true),
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedPaymentType,
                      items: [
                        DropdownMenuItem(value: 'naqd', child: Text('Naqd')),
                        DropdownMenuItem(value: 'karta', child: Text('Karta')),
                      ],
                      decoration: InputDecoration(
                        labelText: "To'lov turi",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentType = value!;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.inventory),
                      title: Wrap(
                        spacing: 4.0,
                        children: [
                          Text("Qolgan kapsula: $left"),
                          Text(
                            "+ $qoldi",
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.attach_money),
                      title: Text("Umumiy summa: $summa so'm"),
                    ),

                    ListTile(
                      leading: Icon(Icons.warning_amber_outlined),
                      title: Text("Qarz: $qarz so'm"),
                    ),
                    ortiqchaPul > 0 ? ListTile(
                      leading: Icon(Icons.monetization_on_outlined),
                      title: Text("Qo'shimcha pul: $ortiqchaPul so'm"),
                    ) : SizedBox.shrink(),
                  ],
                ),
              ),
              actions: [
                MaterialButton(
                  color: Colors.red,
                  onPressed: () async {
                    bool success = await httpService.updateOrder(
                      id: order.id.toString(),
                      water_count: order.givedBottle,
                      returnedBottle: order.returnedBottle,
                      qoldi: order.qoldi,
                      summa: int.tryParse(order.summa) ?? 0,
                      summaTolov: int.tryParse(order.summaTolov) ?? 0,
                      summaQarz: int.tryParse(order.summaQarz) ?? 0,
                      typeOfPayment: order.typeOfPayment,
                      ortiqchaPul: ortiqchaPul,
                      done: -1,
                    );

                    if (success) {
                      httpService.sendMessageToTelegramUser(order.chatId.toString(),"❌Zakaz bekor qilindi.");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Zakaz bekor qilindi!",
                            style: TextStyle(color: Colors.white),
                          ),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(10),
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      _refreshData();
                      moveCar();
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Xatolik bor! Sahifani yangilab zakazni boshidan yoping",
                            style: TextStyle(color: Colors.white),
                          ),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(10),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.cancel_outlined, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Zakazni Bekor qilish",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                MaterialButton(
                  color: Colors.green,
                  onPressed: () async {
                    final gived = int.tryParse(givedBottleController.text) ?? 0;
                    final returned = int.tryParse(returnedBottleController.text) ?? 0;
                    final paid = int.tryParse(paidAmountController.text) ?? 0;

                    final total = gived * bottlePrice;
                    final debt = (paid < total) ? (total - paid) : 0;

                    int newQoldi = returned == 0
                        ? (order.qoldi + gived)  // eski qoldi + berilgan suv
                        : gived;


                    order.returnedBottle = order.returnedBottle - returned;
                    order.qoldi = newQoldi;
                    order.summa = total.toString();
                    order.summaTolov = total.toString();
                    order.summaQarz = debt.toString();
                    order.typeOfPayment = selectedPaymentType;
                    order.done = 1;

                    bool success = await httpService.updateOrder(
                      id: order.id.toString(),
                      water_count: gived,
                      returnedBottle: returned,
                      qoldi: newQoldi,
                      summa: total,
                      summaTolov: total,
                      summaQarz: debt,
                      typeOfPayment: selectedPaymentType,
                      ortiqchaPul: ortiqchaPul,
                      done: 1,
                    );

                    if (success) {
                      httpService.sendMessageToTelegramUser(order.chatId.toString(),"✅Zakaz yetkazib berildi."
                          "\nSuv: ${gived} dona\n"
                          "To'landi: ${order.summa } so'm\n"
                          "Qarz: ${order.summaQarz } so'm");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Zakaz Muvaffaqiyatli Berildi!",
                            style: TextStyle(color: Colors.white),
                          ),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(10),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      _refreshData();
                      moveCar();
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Xatolik bor! Sahifani yangilab zakazni boshidan yoping",
                            style: TextStyle(color: Colors.white),
                          ),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(10),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Zakaz berildi",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    updateKassa =  await httpService.httpKassa(employeeBox.values.first.id);
    _ordersFuture = updateKassa == true ? httpService.fetch0Orders() : httpService.fetchOrders();
    _ordersFuture!.then((ordersModel) async {
      final todayOrders = ordersModel.orders;
      final int zakazLength = todayOrders.length;

      final int tarqatildi = todayOrders.fold(
        0,
            (sum, order) => order.done != -1 ? sum + order.givedBottle : sum,
      );

      final int tarqatildi1 = todayOrders.fold(
        0,
            (sum, order) => order.done != -1 ? sum + order.water_count : sum,
      );

      final int atmen = todayOrders.fold(
        0,
            (sum, order) => order.done == -1 ? sum + order.givedBottle : sum,
      );

      final int qarz = todayOrders.fold(
        0,
            (sum, order) => order.done != -1 && order.done != 0 ? sum + int.parse(order.summaQarz) : sum,
      );

      final int ortiqchapul = todayOrders.fold(
        0,
            (sum, order) => order.ortiqchapul,
      );

      final int naxt = todayOrders.fold(
        0,
            (sum, order) {
          if (order.done != -1 && order.typeOfPayment == 'naqd') {
            return sum + (int.tryParse(order.summaTolov.toString().trim() ?? '0') ?? 0);
          }
          return sum;
        },
      );

      final int karta = todayOrders.fold(
        0,
            (sum, order) {
          if (order.done != -1 && order.typeOfPayment == 'karta') {
            return sum + (int.tryParse(order.summaTolov.toString().trim() ?? '0') ?? 0);
          }
          return sum;
        },
      );

      var box = Hive.box('myCache');
      if (box.containsKey('currentValue') && box.containsKey('totalCarLength')) {
        currentValue = getCurrentValue();
        totalCarLength = getTotalCarLength();
      } else {
        saveValues(0,zakazLength);
      }
      final employee = employeeBox.values.first;

      employee.tumanId = 1;
      employee.zakaz = zakazLength;
      employee.tarqatildi = tarqatildi;
      employee.atmen = atmen;
      employee.naqd = naxt;
      employee.karta = karta;
      employee.qarz = qarz;
      employee.ortiqchapul = ortiqchapul;
      employee.kassa_sanasi = todayOrders.first.sana.toString();

      await employee.save();

      updatedUser = await httpService.updateEmployee(
        id: employee.id,
        tuman_id: employee.tumanId,
        name: employee.name,
        password: employee.password,
        qarz: employee.qarz,
        naqd: employee.naqd,
        karta: employee.karta,
        zakaz: employee.zakaz,
        tarqatildi: employee.tarqatildi,
        ortiqchaPul: employee.ortiqchapul,
        kassaSanasi: employee.kassa_sanasi,
        atmen: employee.atmen,
      );

      setState(() {
        totalZakaz = zakazLength;
        totalTarqatildi = tarqatildi;
        totalNaxt = naxt;
        totalKarta  = karta;
        umumiyQarz  = qarz;
        totalAtmen = atmen;
        water_count = tarqatildi1;
        umumiyOrtiqchaPul = ortiqchapul;
        umumiyPul = totalNaxt +totalKarta + umumiyOrtiqchaPul;
      });
    });
  }

  Future<void> _refreshData() async {
    updateKassa = await httpService.httpKassa(employeeBox.values.first.id);

    setState(() {
      _ordersFuture = updateKassa == true ? httpService.fetch0Orders() : httpService.fetchOrders();
      _ordersFuture!.then((ordersModel) async {
        final todayOrders = ordersModel.orders;
        final int zakazLength = todayOrders.length;

        final int tarqatildi = todayOrders.fold(
          0,
              (sum, order) => order.done != -1 ? sum + order.givedBottle : sum,
        );

        final int tarqatildi1 = todayOrders.fold(
          0,
              (sum, order) => order.done != -1 ? sum + order.water_count : sum,
        );

        final int atmen = todayOrders.fold(
          0,
              (sum, order) => order.done == -1 ? sum + order.givedBottle : sum,
        );

        final int qarz = todayOrders.fold(
          0,
              (sum, order) => order.done != -1 && order.done != 0 ? sum + int.parse(order.summaQarz) : sum,
        );

        final int ortiqchapul = todayOrders.fold(
          0,
              (sum, order) => order.ortiqchapul,
        );

        final int naxt = todayOrders.fold(
          0,
              (sum, order) {
            if (order.done != -1 && order.typeOfPayment == 'naqd') {
              return sum + (int.tryParse(order.summaTolov.toString().trim() ?? '0') ?? 0);
            }
            return sum;
          },
        );

        final int karta = todayOrders.fold(
          0,
              (sum, order) {
            if (order.done != -1 && order.typeOfPayment == 'karta') {
              return sum + (int.tryParse(order.summaTolov.toString().trim() ?? '0') ?? 0);
            }
            return sum;
          },
        );

        var box = Hive.box('myCache');
        if (box.containsKey('currentValue') && box.containsKey('totalCarLength')) {
          currentValue = getCurrentValue();
          totalCarLength = getTotalCarLength();
        } else {
          saveValues(0,zakazLength);
        }
        final employee = employeeBox.values.first;

        employee.tumanId = 1;
        employee.zakaz = zakazLength;
        employee.tarqatildi = tarqatildi;
        employee.atmen = atmen;
        employee.naqd = naxt;
        employee.karta = karta;
        employee.qarz = qarz;
        employee.ortiqchapul = ortiqchapul;
        employee.kassa_sanasi = todayOrders.first.sana.toString();

        await employee.save();

        updatedUser = await httpService.updateEmployee(
          id: employee.id,
          tuman_id: employee.tumanId,
          name: employee.name,
          password: employee.password,
          qarz: employee.qarz,
          naqd: employee.naqd,
          karta: employee.karta,
          zakaz: employee.zakaz,
          tarqatildi: employee.tarqatildi,
          ortiqchaPul: employee.ortiqchapul,
          kassaSanasi: employee.kassa_sanasi,
          atmen: employee.atmen,
        );

        setState(() {
          totalZakaz = zakazLength;
          totalTarqatildi = tarqatildi;
          totalNaxt = naxt;
          totalKarta  = karta;
          umumiyQarz  = qarz;
          totalAtmen = atmen;
          water_count = tarqatildi1;
          umumiyOrtiqchaPul = ortiqchapul;
          umumiyPul = totalNaxt +totalKarta + umumiyOrtiqchaPul;
        });
      });
    });
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: GestureDetector(
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllOrdersPage()),
            );
          },
          child: SizedBox(
            width: 170,
              child: Image.asset('assets/images/aqulimeLogo.png')
          ),
          // child: Text(
          //   "AquaLime",
          //   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          // ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: Colors.white, size: 30),
            onPressed: _refreshData,
          ),
        ],
      ),
      drawer: HomeDrawer(
        totalZakaz: totalZakaz,
        totalTarqatildi: totalTarqatildi,
        water_count: water_count,
        totalAtmen: totalAtmen,
        totalNaxt: totalNaxt,
        totalKarta: totalKarta,
        umumiyQarz: umumiyQarz,
        ortiqchaPul: umumiyOrtiqchaPul,
        umumiyPul: umumiyPul,
        httpService: httpService,
        employee: employeeBox.values.first,
      ),
      body: FutureBuilder<OrdersModel>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            LogService.e(snapshot.error.toString());
            return Scaffold(
              body: Center(child: Text("Xatolik: ${snapshot.error}")),
            );
          }

          if (!snapshot.hasData || snapshot.data!.orders.isEmpty) {
            return  Scaffold(
              body: Center(
                child: SizedBox(
                  width: 180,
                  height: 180,
                    child: Lottie.asset('assets/lotties/loading.json')),
              ),
            );
          }
          final orders = snapshot.data!.orders;
          final doneZero = orders
              .where((o) => o.done == 0)
              .toList()
            ..sort((a, b) => a.userId.compareTo(b.userId));
          final doneMinusOne = orders.where((o) => o.done == -1).toList()..sort((a, b) => a.userId.compareTo(b.userId));
          final doneOne = orders.where((o) => o.done == 1).toList()..sort((a, b) => a.userId.compareTo(b.userId));
          final todayOrders = [...doneZero, ...doneMinusOne, ...doneOne];

          return Column(
            children: [
              totalCarLength > 1 ?
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: CarLoadingBar(
                        totalLength: totalCarLength,
                        currentValue: currentValue,
                      ),
                    ),
                  ),
                ),
              ): SizedBox(height: 10),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: todayOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final order = todayOrders[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 4,
                      shadowColor: Colors.blueAccent,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 16,
                          right: 16,
                          left: 16,
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      order.done == 1
                                          ? Colors.green
                                          : order.done == -1
                                          ? Colors.orange
                                          : Colors.red,
                                  child: Icon(
                                    order.done == 1
                                        ? Iconsax.truck_tick
                                        : order.done == -1
                                        ? Iconsax.truck_remove
                                        : Iconsax.truck_fast,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "z${order.userId}",
                                        style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Summa: ${order.summa} so'm",
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "${order.sana.toLocal().toString().split(' ')[0]}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.grey,
                                      ),
                                    ),

                                    order.done == 0 ?
                                    MaterialButton(
                                      color: Colors.blueAccent,
                                      onPressed: () {
                                        _showOrderDialog(context, order);
                                      },
                                      child: const Text(
                                        "yopish",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ) : SizedBox.shrink(),
                                  ],
                                ),
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
                                _buildBottleBox("Qoldiq"),
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
              const Divider(
                height: 1,
                thickness: 1,
                color: Colors.black12,
                indent: 12,
                endIndent: 12,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottleBox(String label) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
          ),
        ],
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

  Widget _buildDivider() =>
      Container(width: 1, height: 20, color: Colors.blueAccent);

  Widget _buildDividerH() =>
      Container(width: double.infinity, height: 1, color: Colors.blueAccent);
}
