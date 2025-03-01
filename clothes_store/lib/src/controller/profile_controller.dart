import 'dart:convert';
import 'package:clothes_store/server.dart';
import 'package:http/http.dart' as http;
import 'package:clothes_store/core/app_data.dart';
import 'package:clothes_store/src/model/ADDRESS_MODEL.dart';
import 'package:clothes_store/src/model/USER_MODEL.dart';

class ProfileController {

  Future<ReturnMessage> changeAvatar(String filePath) async {
    String url = '${Server.baseUrl}/api/user/upload-avatar';
    String? authToken = AppData.token;

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers['Authorization'] = 'Bearer $authToken'
        ..files.add(await http.MultipartFile.fromPath('avatar', filePath));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      String message = jsonData['message'];
      if (response.statusCode == 200) {
        String link = jsonData['avatar'];
        print("link ảnh mới: $link");
        return ReturnMessage(statusCode: response.statusCode, message: link);
      } else {
        print("code: ${response.statusCode}");
        print("message error: $message");
        return ReturnMessage(statusCode: response.statusCode, message: message);
      }
    } catch (e) {
      print("error while changing avatar: $e");
      return ReturnMessage(statusCode: 500, message: 'Error: $e');
    }
  }

  Future<ReturnMessage> changePassword(String currentPassword, String newPassword) async {
    String url = '${Server.baseUrl}/api/user/change-password';
    String? authToken = AppData.token;

    try {
      var response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        }),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return ReturnMessage(statusCode: response.statusCode, message: jsonData['message']);
      } else {
        return ReturnMessage(statusCode: response.statusCode, message: 'Failed to change password');
      }
    } catch (e) {
      return ReturnMessage(statusCode: 500, message: 'Error: $e');
    }
  }

  Future<ReturnMessage> updateProfile(String fullname, String gender, String phone) async {
    String url = '${Server.baseUrl}/api/user/profile';
    String? authToken = AppData.token;

    try {
      var response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          "fullname": fullname,
          "gender": gender,
          "phone": phone,
        }),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return ReturnMessage(statusCode: response.statusCode, message: jsonData['message']);
      } else {
        return ReturnMessage(statusCode: response.statusCode, message: 'Failed to update profile');
      }
    } catch (e) {
      return ReturnMessage(statusCode: 500, message: 'Error: $e');
    }
  }

  Future<ReturnMessage> addAddress(String address) async {
    String url = '${Server.baseUrl}/api/address';
    String? authToken = AppData.token;

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          "address": address,
        }),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return ReturnMessage(statusCode: response.statusCode, message: jsonData['message']);
      } else {
        return ReturnMessage(statusCode: response.statusCode, message: 'Failed to add address');
      }
    } catch (e) {
      return ReturnMessage(statusCode: 500, message: 'Error: $e');
    }
  }

  Future<List<ADDRESS_MODEL>?> getUserAddress() async {
    String url = '${Server.baseUrl}/api/address';
    String? authToken = AppData.token;

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => ADDRESS_MODEL.fromJson(json)).toList();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<ReturnMessage> updateAddress(int id, String address, bool isDefault) async {
    String url = '${Server.baseUrl}/api/address/$id';
    String? authToken = AppData.token;

    try {
      var response = await http.put(
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
        return ReturnMessage(statusCode: response.statusCode, message: 'Failed to update address');
      }
    } catch (e) {
      return ReturnMessage(statusCode: 500, message: 'Error: $e');
    }
  }

  Future<ReturnMessage> deleteAddress(int id) async {
    String url = '${Server.baseUrl}/api/address/$id';
    String? authToken = AppData.token;

    try {
      var response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return ReturnMessage(statusCode: response.statusCode, message: jsonData['message']);
      } else {
        return ReturnMessage(statusCode: response.statusCode, message: 'Failed to delete address');
      }
    } catch (e) {
      return ReturnMessage(statusCode: 500, message: 'Error: $e');
    }
  }

  Future<ReturnMessage> setDefaultAddress(int id) async {
    String url = '${Server.baseUrl}/api/address/$id/default';
    String? authToken = AppData.token;

    try {
      var response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return ReturnMessage(statusCode: response.statusCode, message: jsonData['message']);
      } else {
        return ReturnMessage(statusCode: response.statusCode, message: 'Failed to set default address');
      }
    } catch (e) {
      return ReturnMessage(statusCode: 500, message: 'Error: $e');
    }
  }
}

class ReturnMessage {
  int? statusCode;
  String? message;

  ReturnMessage({this.statusCode, this.message});
}