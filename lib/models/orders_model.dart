import 'dart:convert';

OrdersModel ordersModelFromJson(String str) =>
    OrdersModel.fromJson(json.decode(str));

String ordersModelToJson(OrdersModel data) => json.encode(data.toJson());

class OrdersModel {
  bool success;
  int employeeId;
  String date;
  int ordersCount;
  int usersCount;
  List<Order> orders;
  List<UserWithDefaultWater> usersWithDefaultWater;

  OrdersModel({
    required this.success,
    required this.employeeId,
    required this.date,
    required this.ordersCount,
    required this.usersCount,
    required this.orders,
    required this.usersWithDefaultWater,
  });

  factory OrdersModel.fromJson(Map<String, dynamic> json) => OrdersModel(
    success: json["success"] ?? false,
    employeeId: json["employee_id"] ?? 0,
    date: json["date"] ?? "",
    ordersCount: json["orders_count"] ?? json["count"] ?? 0,
    usersCount: json["users_count"] ?? 0,
    orders: json["orders"] == null
        ? []
        : List<Order>.from(json["orders"].map((x) => Order.fromJson(x))),
    usersWithDefaultWater: json["users_with_default_water"] == null
        ? []
        : List<UserWithDefaultWater>.from(
        json["users_with_default_water"]
            .map((x) => UserWithDefaultWater.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "employee_id": employeeId,
    "date": date,
    "orders_count": ordersCount,
    "users_count": usersCount,
    "orders": List<dynamic>.from(orders.map((x) => x.toJson())),
    "users_with_default_water":
    List<dynamic>.from(usersWithDefaultWater.map((x) => x.toJson())),
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
  int waterCount;
  int returnedBottle;
  int qoldi;
  String typeOfPayment;
  String summa;
  String summaTolov;
  String summaQarz;
  int ortiqchapul;
  int done;
  int employeeId;
  int orderType;

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
    required this.waterCount,
    required this.returnedBottle,
    required this.qoldi,
    required this.typeOfPayment,
    required this.summa,
    required this.summaTolov,
    required this.summaQarz,
    required this.ortiqchapul,
    required this.done,
    required this.employeeId,
    required this.orderType,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"],
    userId: json["user_id"],
    chatId: json["chat_id"],
    fish: json["fish"] ?? "",
    location: json["location"] ?? "",
    adress: json["adress"] ?? "",
    tel1: json["tel1"] ?? "",
    tel2: json["tel2"] ?? "",
    sana: DateTime.parse(json["sana"]),
    givedBottle: json["gived_bottle"] ?? 0,
    waterCount: json["water_count"] ?? 0,
    returnedBottle: json["returned_bottle"] ?? 0,
    qoldi: json["qoldi"] ?? 0,
    typeOfPayment: json["type_of_payment"] ?? "",
    summa: json["summa"] ?? "0",
    summaTolov: json["summa_tolov"] ?? "0",
    summaQarz: json["summa_qarz"] ?? "0",
    ortiqchapul: json["ortiqchapul"] ?? 0,
    done: json["done"] ?? 0,
    employeeId: json["employee_id"] ?? 0,
    orderType: json["order_type"] ?? 0,
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
    "sana":
    "${sana.year.toString().padLeft(4, '0')}-${sana.month.toString().padLeft(2, '0')}-${sana.day.toString().padLeft(2, '0')}",
    "gived_bottle": givedBottle,
    "water_count": waterCount,
    "returned_bottle": returnedBottle,
    "qoldi": qoldi,
    "type_of_payment": typeOfPayment,
    "summa": summa,
    "summa_tolov": summaTolov,
    "summa_qarz": summaQarz,
    "ortiqchapul": ortiqchapul,
    "done": done,
    "employee_id": employeeId,
    "order_type": orderType,
  };
}

class UserWithDefaultWater {
  int id;
  int chatId;
  String fish;
  String location;
  String adress;
  String tel1;
  String tel2;
  int defaultWaterCount;

  UserWithDefaultWater({
    required this.id,
    required this.chatId,
    required this.fish,
    required this.location,
    required this.adress,
    required this.tel1,
    required this.tel2,
    required this.defaultWaterCount,
  });

  factory UserWithDefaultWater.fromJson(Map<String, dynamic> json) =>
      UserWithDefaultWater(
        id: json["id"],
        chatId: json["chat_id"] ?? 0,
        fish: json["fish"] ?? "",
        location: json["location"] ?? "",
        adress: json["adress"] ?? "",
        tel1: json["tel1"] ?? "",
        tel2: json["tel2"] ?? "",
        defaultWaterCount: json["default_water_count"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "chat_id": chatId,
    "fish": fish,
    "location": location,
    "adress": adress,
    "tel1": tel1,
    "tel2": tel2,
    "default_water_count": defaultWaterCount,
  };
}