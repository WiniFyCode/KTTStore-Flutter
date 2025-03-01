import 'dart:convert';

import 'package:clothes_store/core/app_data.dart';
import 'package:clothes_store/server.dart';
import 'package:clothes_store/src/model/USER_MODEL.dart';
import 'package:http/http.dart' as http;

class UserController {

  // đăng ký (POST)
  // http://localhost:5000/api/auth/register?fullname=test flutter account&email=duykhoi20071998@gmail.com&password=987654321Kh$&phone=0325555055&gender=male

  Future<SignUpResponse> signUp(String fullname, String email, String password,
      String phone, String gender) async {
    String url = '${Server.baseUrl}/api/auth/register';

    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(Uri.parse(url),
        headers: headers,
        body: json.encode({
          'fullname': fullname,
          'email': email,
          'password': password,
          'phone': phone,
          'gender': gender,
        }));

    if (response.statusCode == 201) {
      // code 201 tạo data thành công
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return SignUpResponse(
          userModel: USER_MODEL.fromJson(jsonResponse['user']),
          errorMessage: "");
    } else {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return SignUpResponse(
          userModel: null, errorMessage: jsonResponse['message']);
    }
  }

  Future<SignUpResponse> login(String email, String password) async {
    String url = '${Server.baseUrl}/api/auth/login';

    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(Uri.parse(url),
        headers: headers,
        body: json.encode({'email': email, 'password': password}));

    print("code: ${response.statusCode}");

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      USER_MODEL newUser = USER_MODEL.fromJson(jsonResponse['user']);
      String token = jsonResponse['token'];
      AppData.token = token;
      return SignUpResponse(
          userModel: newUser,
          token: token,
          errorMessage: "");
    } else {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return SignUpResponse(
          userModel: null, errorMessage: jsonResponse['message']);
    }
  }

  Future<ReturnMessager> sendOTP(String email) async {
    String url = '${Server.baseUrl}/api/auth/forgot-password';

    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(Uri.parse(url),
        headers: headers,
        body: json.encode({
          'email': email,
        }));

    Map<String, dynamic> jsonResponse = json.decode(response.body);
    String messager = jsonResponse['message'];
    int statusCode = response.statusCode;
    print("code: $statusCode");
    return ReturnMessager(messager: messager, statusCode: statusCode);
  }

  Future<ReturnMessager> resetPassword(String email, String otp, String password) async {
    String url = '${Server.baseUrl}/api/auth/reset-password';

    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(Uri.parse(url),
        headers: headers,
        body: json.encode({
          'email': email,
          'otp': otp,
          'newPassword': password
        }));

    Map<String, dynamic> jsonResponse = json.decode(response.body);
    String messager = jsonResponse['message'];
    int statusCode = response.statusCode;
    print("code: ${statusCode}");
    return ReturnMessager(messager: messager, statusCode: statusCode);
  }

  Future<USER_MODEL?> getUserByToken() async {
    String url = '${Server.baseUrl}/api/user/profile';
    String? authToken = AppData.token;
    print("token: $authToken");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        USER_MODEL user = USER_MODEL.fromJson(jsonData);

        // Cập nhật AppData
        AppData.userInfo = user;

        return user;
      } else {
        print('Failed to get user profile: ${response.statusCode}');
        print("message: ${json.decode(response.body)['message']}");
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }


}

class SignUpResponse {
  final USER_MODEL? userModel;
  final String? errorMessage;
  final String? token;

  SignUpResponse({this.userModel, this.errorMessage, this.token});
}

class ReturnMessager{
  final String? messager;
  final int? statusCode;
  ReturnMessager({this.messager, this.statusCode});
}
