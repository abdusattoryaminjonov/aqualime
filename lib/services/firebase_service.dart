import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _settingsCollection = FirebaseFirestore.instance.collection('settings');

  final Location _location = Location();

  Future<void> updateUserLocation({
    required String userId,
    required String name,
  }) async {
    try {
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

      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'lat': locationData.latitude,
        'lng': locationData.longitude,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Joylashuvni yozishda xatolik: $e");
    }
  }


  Future<Map<String, dynamic>?> getDailySummary(String date) async {
    final doc = await _firestore.collection('daily_summary').doc(date).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  // Bugungi kundagi hisob-kitobni yangilash yoki yaratish
  Future<void> updateDailySummary({
    required String date,
    int? orderCount,
    int? totalWaterGiven,
    int? cashAmount,
    int? cardAmount,
  }) async {
    final docRef = _firestore.collection('daily_summary').doc(date);

    // Avvalgi ma'lumotni olish
    final snapshot = await docRef.get();
    Map<String, dynamic> currentData = snapshot.exists ? snapshot.data()! : {};

    // Yangi qiymatlar bilan birlashtirish (null bo‘lmaganlarini yangilash)
    if (orderCount != null) currentData['orderCount'] = orderCount;
    if (totalWaterGiven != null) currentData['totalWaterGiven'] = totalWaterGiven;
    if (cashAmount != null) currentData['cashAmount'] = cashAmount;
    if (cardAmount != null) currentData['cardAmount'] = cardAmount;

    await docRef.set(currentData);
  }

  // Narxni olish (default 17000)
  Future<int> getBottlePrice() async {
    try {
      final doc = await _settingsCollection.doc('prices').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['bottle_price'] ?? 17000;
      }
      return 17000;
    } catch (e) {
      print("Narxni olishda xatolik: $e");
      return 17000;
    }
  }

  // Narxni saqlash
  Future<void> setBottlePrice(int price) async {
    try {
      await _settingsCollection.doc('prices').set({
        'bottle_price': price,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Narxni saqlashda xatolik: $e");
      rethrow;
    }
  }
  /// Foydalanuvchini yozish
  Future<void> addUser({
    required String userId,
    required String fish,
    required String tel1,
    required String tel2,
    required String adress,
    required String location,
    required int defaultWaterCount,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'fish': fish,
      'tel1': tel1,
      'tel2': tel2,
      'adress': adress,
      'location': location,
      'default_water_count': defaultWaterCount,
    });
  }

  /// Buyurtma yozish
  Future<void> addOrder({
    required String orderId,
    required String userId,
    required String sana,
    required int waterCount,
    required int givedBottle,
    required int returnedBottle,
    required int qoldi,
    required int summa,
    required int summaTolov,
    required int summaQarz,
    required String typeOfPayment,
    required bool done,
  }) async {
    await _firestore.collection('orders').doc(orderId).set({
      'user_id': userId,
      'sana': sana,
      'water_count': waterCount,
      'gived_bottle': givedBottle,
      'returned_bottle': returnedBottle,
      'qoldi': qoldi,
      'summa': summa,
      'summa_tolov': summaTolov,
      'summa_qarz': summaQarz,
      'type_of_payment': typeOfPayment,
      "done": false
    });
  }

  /// Foydalanuvchining order_records subcollectioniga yozish
  Future<void> addOrderRecord({
    required String userId,
    required String sana,
    required int berildi,
    required int olindi,
    required int qoldi,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('order_records')
        .add({
      'sana': sana,
      'berildi': berildi,
      'olindi': olindi,
      'qoldi': qoldi,
    });
  }

  Future<String> generateNextUserId() async {
    final snapshot = await _firestore.collection('users').get();
    final ids = snapshot.docs.map((doc) => doc.id).toList();

    final uIds = ids.where((id) => id.startsWith('u')).toList();
    final numbers = uIds.map((id) {
      final numStr = id.replaceFirst('u', '');
      return int.tryParse(numStr) ?? 0;
    }).toList();

    final nextId = (numbers.isEmpty ? 1 : numbers.reduce((a, b) => a > b ? a : b) + 1);
    return 'u$nextId';
  }

  Future<String> generateNextOrderId() async {
    final snapshot = await _firestore.collection('orders').get();
    final count = snapshot.docs.length + 1;
    return 'o$count';
  }

  Future<List<String>> getAllUserIds() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => doc.id).toList(); // Assuming doc.id = 'u1', 'u2', ...
  }


}
