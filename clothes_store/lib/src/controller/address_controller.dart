import 'dart:convert';
import 'package:clothes_store/server.dart';
import 'package:http/http.dart' as http;
import 'package:clothes_store/core/app_data.dart';
import 'package:clothes_store/src/model/ADDRESS_MODEL.dart';

class AddressController {

  Future<List<ADDRESS_MODEL>?> getAddresses() async {
    String url = '${Server.baseUrl}/api/address';
    String? authToken = AppData.token;

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => ADDRESS_MODEL.fromJson(json)).toList();
      } else {
        print('Failed to load addresses');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<ADDRESS_MODEL?> getAddressById(int id) async {
    String url = '${Server.baseUrl}/api/address/$id';
    String? authToken = AppData.token;

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return ADDRESS_MODEL.fromJson(jsonData);
      } else {
        print('Failed to load address');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<ReturnMessage> addAddress(String address, bool isDefault) async {
    String url = '${Server.baseUrl}/api/address';
    String? authToken = AppData.token;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          "address": address
        }),
      );

      if (response.statusCode == 201) {
        var jsonData = json.decode(response.body);
        return ReturnMessage(statusCode: response.statusCode, message: jsonData['message']);
      } else {
        print('Failed to add address');
        return ReturnMessage(statusCode: response.statusCode, message: 'Failed to add address');
      }
    } catch (e) {
      print('Error: $e');
      return ReturnMessage(statusCode: 500, message: 'Error: $e');
    }
  }

  Future<ReturnMessage> updateAddress(int id, String address, bool isDefault) async {
    String url = '${Server.baseUrl}/api/address/$id';
    String? authToken = AppData.token;

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          "address": address,
          "isDefault": isDefault,
        }),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return ReturnMessage(statusCode: response.statusCode, message: jsonData['message']);
      } else {
        print('Failed to update address');
        return ReturnMessage(statusCode: response.statusCode, message: 'Failed to update address');
      }
    } catch (e) {
      print('Error: $e');
      return ReturnMessage(statusCode: 500, message: 'Error: $e');
    }
  }

  Future<ReturnMessage> deleteAddress(int id) async {
    String url = '${Server.baseUrl}/api/address/$id';
    String? authToken = AppData.token;

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return ReturnMessage(statusCode: response.statusCode, message: jsonData['message']);
      } else {
        print('Failed to delete address');
        return ReturnMessage(statusCode: response.statusCode, message: 'Failed to delete address');
      }
    } catch (e) {
      print('Error: $e');
      return ReturnMessage(statusCode: 500, message: 'Error: $e');
    }
  }

  Future<ReturnMessage> setDefaultAddress(int id) async {
    String url = '${Server.baseUrl}/api/address/$id/default';
    String? authToken = AppData.token;

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return ReturnMessage(statusCode: response.statusCode, message: jsonData['message']);
      } else {
        print('Failed to set default address');
        return ReturnMessage(statusCode: response.statusCode, message: 'Failed to set default address');
      }
    } catch (e) {
      print('Error: $e');
      return ReturnMessage(statusCode: 500, message: 'Error: $e');
    }
  }
}

class ReturnMessage {
  int? statusCode;
  String? message;

  ReturnMessage({this.statusCode, this.message});
}