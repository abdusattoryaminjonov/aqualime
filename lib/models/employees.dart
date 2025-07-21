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
  int ortiqchapul;

  @HiveField(10)
  String kassa_sanasi;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  int id;

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
    this.ortiqchapul = 0,
    this.kassa_sanasi = '',
    required this.createdAt,
    this.id = 0,
  });


  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      tumanId: json['tuman_id'],
      name: json['name'] ?? '',
      password: json['password'] ?? '',
      zakaz: json['zakaz'] ?? 0,
      tarqatildi: json['tarqatildi'] ?? 0,
      atmen: json['atmen'] ?? 0,
      naqd: json['naqd'] ?? 0,
      karta: json['karta'] ?? 0,
      qarz: json['qarz'] ?? 0,
      ortiqchapul: json['ortiqchapul'] ?? 0,
      kassa_sanasi: json['kassa-sanasi'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
