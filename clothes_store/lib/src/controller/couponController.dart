import 'dart:convert';
import 'package:clothes_store/core/app_data.dart';
import 'package:clothes_store/server.dart';
import 'package:clothes_store/src/model/COUPON_PAGINATION_MODEL.dart';
import 'package:http/http.dart' as http;

  class CouponController {

  Future<COUPON_PAGINATION_MODEL?> getUserCoupons(int page) async {
    String url = '${Server.baseUrl}/api/user-coupon/my-coupons';
    String? authToken = AppData.token;
    print("authToken: $authToken");
    int limit = 2;

    try {
      Uri uri = Uri.parse(url).replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });
      print("uri: $uri");

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      });

      print(response.statusCode);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print("Decoded data: $data"); // Thêm dòng này
        var model = COUPON_PAGINATION_MODEL.fromJson(data);
        print("Parsed model userCoupons length: ${model.userCoupons?.length}"); // Thêm dòng này
        return model;
      } else {
        print(response.statusCode);
        print('Failed to load coupons, error ${response.statusCode}');
        return null;
      }
    } catch (error) {
      throw Exception('Failed to load coupons: $error');
    }
  }
  
}