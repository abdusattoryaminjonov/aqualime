import 'package:hive/hive.dart';
import '../models/employees.dart';

class EmployeeService {
  static final _box = Hive.box<Employee>('employees');

  // CREATE
  static Future<void> addEmployee(Employee employee) async {
    await _box.add(employee);
  }

  // READ
  static List<Employee> getAllEmployees() {
    return _box.values.toList();
  }

  // UPDATE
  static Future<void> updateEmployee(int index, Employee updated) async {
    await _box.putAt(index, updated);
  }

  // DELETE
  static Future<void> deleteEmployee(int index) async {
    await _box.deleteAt(index);
  }
}