import 'dart:convert';

import 'package:clothes_store/core/app_data.dart';
import 'package:clothes_store/server.dart';
import 'package:clothes_store/src/model/CART_MODEL.dart';
import 'package:http/http.dart' as http;

class CartController{

  Future<List<CART_MODEL>?> fetchCarts() async {
    String apiUrl = '${Server.baseUrl}/api/cart';
    print("apiUrl: $apiUrl");
    String? authToken = AppData.token;
    print("authToken: $authToken");

    if (authToken != null) {
      try {
        var response = await http.get(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          if (responseData['items'] != null) {
            List<CART_MODEL> carts = [];
            var items = responseData['items'] as List;
            
            for (var item in items) {
              try {

                CART_MODEL cart = CART_MODEL.fromJson(item);
                carts.add(cart);
              } catch (e) {
                print('Error parsing cart item: $e');
                print('Problematic item: $item');
              }
            }
            return carts;
          }
        }
        print('Failed to fetch cart items. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      } catch (e) {
        print('Error while fetching carts: $e');
        return null;
      }
    } else {
      print('không tìm thấy token');
      return null;
    }
  }

  Future<ReturnMessager> addToCart(String sku, int quantity) async {
    String apiUrl =
        '${Server.baseUrl}/api/cart/add'; // Đường link API
    // print("user: ${AppData.userInfo.toString()}");
    String? authToken =
        AppData.token; // Token xác thực của người dùng

    if (authToken != null) {
      Map<String, dynamic> requestBody = {
        "SKU": sku,
        "quantity": quantity
      };

      try {
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        );
        Map<String, dynamic> responseData = json.decode(response.body);

        ReturnMessager messager = ReturnMessager(
            messager: responseData['message'], statusCode: response.statusCode);
        return messager;

      } catch (e) {
        print('Error while adding to favorites: $e');
        return ReturnMessager(
            messager: "Error while adding to favorites", statusCode: 0);
      }
    } else {
      print('không tìm thấy token');
      return ReturnMessager(messager: "không tìm thấy token", statusCode: 0);
    }
  }

  Future<String> deleteFromCart(int id) async {
    final String apiUrl = '${Server.baseUrl}/api/cart/$id'; // Replace with your actual API endpoint
    String? authToken =
        AppData.token; // Token xác thực của người dùng
    try {
      final response = await http.delete(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['message'];
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return errorData['message'] ?? 'Failed to delete item from cart';
      }
    } catch (error) {
      print('Error while deleting item from cart:');
      return 'Error occurred: $error';
    }
  }

  // update quantity trong cart theo cartID
  Future<String> updateQuantity(int id, int quantity) async {
    String apiUrl =
        '${Server.baseUrl}/api/cart/$id'; // Đường link API
    String? authToken =
        AppData.token; // Token xác thực của người dùng

    if (authToken != null) {
      Map<String, dynamic> requestBody = {
        "quantity": quantity
      };

      try {
        var response = await http.put(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        );
        Map<String, dynamic> responseData = json.decode(response.body);
        print("code: ${response.statusCode}");
        return responseData['message'];

      } catch (e) {
        print('Error while updating cart: $e');
        return "Cập nhật số lượng thất bại";
      }
    } else {
      print('không tìm thấy token');
      return "không tìm thấy token";
    }
  }


}
class ReturnMessager{
  String messager;
  int statusCode;
  ReturnMessager({required this.messager, required this.statusCode});
}
