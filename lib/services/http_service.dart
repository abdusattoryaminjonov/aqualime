import 'dart:convert';
import 'package:aqualime/services/log_service.dart';
import 'package:http/http.dart' as http;

import '../constands/const.dart';
import '../models/orders_model.dart';

class HttpService {

  Future<http.Response> httpGetOrders() async {
    final url = Uri.parse("$BASE_URL/api/get-orders/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
      }),
    );

    LogService.e(response.body.toString());

    if (response.statusCode >= 400) {
      _throwException(response);
    }
    return response;
  }
  static Future<Map<String, dynamic>> decodeResponse(String body) async {
    return json.decode(body) as Map<String, dynamic>;
  }

  Future<OrdersModel> fetchOrders() async {
    final response = await http.get(
      Uri.parse("$BASE_URL/api/get-orders/"),
      headers: {"Content-Type": "application/json"},
    );

    LogService.e(response.body.toString());


    if (response.statusCode == 200) {
      final ordersModel = ordersModelFromJson(response.body);
      return ordersModel;
    } else {
      throw Exception("Zakazlar olinmadi: ${response.statusCode}");
    }
  }

  Future<http.Response> httpGetUserById(String id) async {
    final url = Uri.parse("$BASE_URL/api/get-user/?user_id=$id");

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode >= 400) {
      _throwException(response);
    }

    return response;
  }

  Future<Map<String, dynamic>> httpLogin(String name, String password) async {
    final url = Uri.parse("$BASE_URL/api/login/");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      LogService.i("📥 Javob: $data");

      return Map<String, dynamic>.from(data);

    } catch (e) {
      LogService.e("❗ Exception: $e");
      return {
        'success': false,
        'message': 'Serverga ulanishda xatolik: $e',
      };
    }
  }




  Future<void> sendMessageToTelegramUser(String chatId, String message) async {
    final String url = 'https://api.telegram.org/bot$BOT_TOKEN/sendMessage';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'chat_id': chatId,
        'text': message,
      }),
    );

    if (response.statusCode == 200) {
      print('Message sent successfully');
    } else {
      print('Failed to send message: ${response.body}');
    }
  }

  Future<bool> updateOrder({
    required String id,
    required int water_count,
    required int returnedBottle,
    required int qoldi,
    required int summa,
    required int summaTolov,
    required int summaQarz,
    required String typeOfPayment,
    required int done,
  }) async {
    final queryParameters = {
      'id': id,
      'water_count': water_count.toString(),
      'returned_bottle': returnedBottle.toString(),
      'qoldi': qoldi.toString(),
      'summa': summa.toString(),
      'summa_tolov': summaTolov.toString(),
      'summa_qarz': summaQarz.toString(),
      'type_of_payment': typeOfPayment,
      'done': done.toString(),
    };

    final uri = Uri.parse("$BASE_URL/api/put-order/").replace(queryParameters: queryParameters);

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    LogService.e("updateOrder response: ${response.body}");

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['success'] == true;
    } else {
      _throwException(response);
      return false; // fallback
    }
  }

  Future<bool> updateEmployee({
    required int id,
    required int tuman_id,
    required String name,
    required String password,
    required int zakaz,
    required int tarqatildi,
    required int atmen,
    required int naqd,
    required int karta,
    required int qarz,
    required int ortiqchaPul,
    required String kassaSanasi,
  }) async {
    final uri = Uri.parse("$BASE_URL/api/update-employee/");

    final body = jsonEncode({
      "id": id,
      "tuman_id": tuman_id,
      "name": name,
      "password": password,
      "zakaz": zakaz,
      "tarqatildi": tarqatildi,
      "atmen": atmen,
      "naqd": naqd,
      "karta": karta,
      "qarz": qarz,
      "ortiqchapul": ortiqchaPul,
      "kassa-sanasi": kassaSanasi, // format: "2025-07-21"
    });

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['success'] == true;
    } else {
      print("Xatolik: ${response.statusCode}");
      return false;
    }
  }





  static void _throwException(http.Response response) {
    String reason = response.reasonPhrase ?? 'Unknown error';
    switch (response.statusCode) {
      case 400:
        throw BadRequestException(reason);
      case 401:
        throw InvalidInputException(reason);
      case 403:
        throw UnauthorisedException(reason);
      case 404:
        throw FetchDataException(reason);
      case 500:
      default:
        throw FetchDataException(reason);
    }
  }
}

class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);
}

class InvalidInputException implements Exception {
  final String message;
  InvalidInputException(this.message);
}

class UnauthorisedException implements Exception {
  final String message;
  UnauthorisedException(this.message);
}

class FetchDataException implements Exception {
  final String message;
  FetchDataException(this.message);
}
