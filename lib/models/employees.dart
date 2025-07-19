import 'package:hive/hive.dart';

part 'employees.g.dart';

@HiveType(typeId: 0)
class Employee extends HiveObject {
  @HiveField(0)
  int tumanId;

  @HiveField(1)
  String name;

  @HiveField(2)
  String password;

  @HiveField(3)
  int zakaz;

  @HiveField(4)
  int tarqatildi;

  @HiveField(5)
  int atmen;

  @HiveField(6)
  int naqd;

  @HiveField(7)
  int karta;

  @HiveField(8)
  int qarz;

  @HiveField(9)
  DateTime createdAt;

  Employee({
    required this.tumanId,
    required this.name,
    required this.password,
    this.zakaz = 0,
    this.tarqatildi = 0,
    this.atmen = 0,
    this.naqd = 0,
    this.karta = 0,
    this.qarz = 0,
    required this.createdAt,
  });
}
