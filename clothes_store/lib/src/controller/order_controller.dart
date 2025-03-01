import 'dart:convert';
import 'package:clothes_store/server.dart';
import 'package:clothes_store/src/model/MINI_PRODUCT_MODEL.dart';
import 'package:http/http.dart' as http;
import 'package:clothes_store/core/app_data.dart';
import 'package:clothes_store/src/model/order_model.dart';

class OrderController {

  Future<List<ORDER_MODEL>?> getOrders() async {
    String url = '${Server.baseUrl}/api/order/my-orders';
    String? authToken = AppData.token;
    print("url: $url");
    print("token: $authToken");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      print("fetch order, code: ${response.statusCode}");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body)["orders"];
        var totalPage = json.decode(response.body)["totalPages"];
        var currentPage = json.decode(response.body)["currentPage"];

        List<ORDER_MODEL> orders = [];
        for (var item in jsonData) {
          ORDER_MODEL order = ORDER_MODEL.fromJson(item);
          orders.add(order);
        }

        return orders;
      } else {
        print('Failed to load orders');
        print(json.decode(response.body)["message"]);
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<ORDER_MODEL?> getOrderById(int id) async {
    String url = '${Server.baseUrl}/api/order/my-orders/$id';
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
        return ORDER_MODEL.fromJson(jsonData);
      } else {
        print('Failed to load order');
        print("error code: ${response.statusCode}");
        print(json.decode(response.body)["message"]);
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<bool> createOrder({required String fullname, required String phone, required String email, required String address, String? note, required String paymentMethod, String? selectedBank, String? bankAccountNumber, required List<MINI_PRODUCT_MODEL> items, required double totalPrice, int? userCouponsID,}) async {
    String url = '${Server.baseUrl}/api/order/create';
    String? authToken = AppData.token;

    try {
      print("list sản phẩm (${items.length}): ");
      for(var item in items){
        print(item);
      }

      // Chuẩn bị dữ liệu gửi đi
      final orderData = {
        'fullname': fullname,
        'phone': phone,
        'email': email,
        'address': address,
        'note': note ?? '',
        'paymentMethod': paymentMethod,
        'selectedBank': selectedBank ?? '',
        'bankAccountNumber': bankAccountNumber ?? '',
        'items': items
            .map((item) => {
                  'SKU': item.sKU,
                  'quantity': item.quantity,
                  'price': item.price,
                })
            .toList(),
        'totalPrice': totalPrice,
        if (userCouponsID != null) 'userCouponsID': userCouponsID,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode(orderData),
      );

      if (response.statusCode == 201) {
        print('Order created successfully');
        // Có thể parse response để lấy thêm thông tin đơn hàng nếu cần
        // var orderResponse = json.decode(response.body);
        return true;
      } else {
        print('Failed to create order ${response.statusCode}');
        var errorData = json.decode(response.body)["message"];
        print("Lỗi khi tạo đơn hàng: $errorData");
        return false;
      }
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }

  Future<bool> cancelOrder(int id) async {
    String url = '${Server.baseUrl}/api/order/cancel/$id';
    String? authToken = AppData.token;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        print('Order canceled successfully');
        return true;
      } else {
        print('Failed to cancel order');
        print("error ${response.statusCode}: ${json.decode(response.body)["message"]}");
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<List<OrderDetails>?> getOrderDetails(int orderID) async {
    String url = '${Server.baseUrl}/api/order-details/order/$orderID';
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
        return jsonData.map((json) => OrderDetails.fromJson(json)).toList();
      } else {
        print('Failed to load order details');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<OrderDetails?> getOrderDetailById(int orderID, int id) async {
    String url = '${Server.baseUrl}/api/order-details/order/$orderID/detail/$id';
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
        return OrderDetails.fromJson(jsonData);
      } else {
        print('Failed to load order detail');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

}
