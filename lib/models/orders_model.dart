import 'dart:convert';

OrdersModel ordersModelFromJson(String str) => OrdersModel.fromJson(json.decode(str));

String ordersModelToJson(OrdersModel data) => json.encode(data.toJson());

class OrdersModel {
  bool success;
  int count;
  List<Order> orders;

  OrdersModel({
    required this.success,
    required this.count,
    required this.orders,
  });

  factory OrdersModel.fromJson(Map<String, dynamic> json) => OrdersModel(
    success: json["success"],
    count: json["count"],
    orders: List<Order>.from(json["orders"].map((x) => Order.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "count": count,
    "orders": List<dynamic>.from(orders.map((x) => x.toJson())),
  };
}

class Order {
  int id;
  int userId;
  int chatId;
  String fish;
  String location;
  String adress;
  String tel1;
  String tel2;
  DateTime sana;
  int givedBottle;
  int water_count;
  int returnedBottle;
  int qoldi;
  String typeOfPayment;
  String summa;
  String summaTolov;
  String summaQarz;
  int done;
  int type;

  Order({
    required this.id,
    required this.userId,
    required this.chatId,
    required this.fish,
    required this.location,
    required this.adress,
    required this.tel1,
    required this.tel2,
    required this.sana,
    required this.givedBottle,
    required this.water_count,
    required this.returnedBottle,
    required this.qoldi,
    required this.typeOfPayment,
    required this.summa,
    required this.summaTolov,
    required this.summaQarz,
    required this.done,
    required this.type,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"],
    userId: json["user_id"],
    chatId: json["chat_id"],
    fish: json["fish"],
    location: json["location"],
    adress: json["adress"],
    tel1: json["tel1"],
    tel2: json["tel2"],
    sana: DateTime.parse(json["sana"]),
    givedBottle: json["gived_bottle"],
    water_count: json["water_count"],
    returnedBottle: json["returned_bottle"],
    qoldi: json["qoldi"],
    typeOfPayment: json["type_of_payment"],
    summa: json["summa"],
    summaTolov: json["summa_tolov"],
    summaQarz: json["summa_qarz"],
    done: json["done"],
    type: json["type"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "chat_id": chatId,
    "fish": fish,
    "location": location,
    "adress": adress,
    "tel1": tel1,
    "tel2": tel2,
    "sana": "${sana.year.toString().padLeft(4, '0')}-${sana.month.toString().padLeft(2, '0')}-${sana.day.toString().padLeft(2, '0')}",
    "gived_bottle": givedBottle,
    "water_count": water_count,
    "returned_bottle": returnedBottle,
    "qoldi": qoldi,
    "type_of_payment": typeOfPayment,
    "summa": summa,
    "summa_tolov": summaTolov,
    "summa_qarz": summaQarz,
    "done": done,
    "type": type,
  };
}
