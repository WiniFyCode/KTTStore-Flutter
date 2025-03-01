import 'dart:convert';

import 'package:clothes_store/core/app_data.dart';
import 'package:clothes_store/server.dart';
import 'package:clothes_store/src/model/REVIEW_MODEL.dart';
import 'package:http/http.dart' as http;

class ReviewController {

  Future<List<REVIEW_MODEL>?> getReviewsByProductId(int productID) async {
    print("fetch dữ liệu ${Server.baseUrl}/api/reviews/product/$productID");
    try {
      final response =
          await http.get(Uri.parse('${Server.baseUrl}/api/reviews/product/$productID'));
      if (response.statusCode == 200) {
        var data = response.body;
        var reviews = json.decode(data)["reviews"] as List;
        // print(products);
        return reviews.map((e) => REVIEW_MODEL.fromJson(e)).toList();
      } else {
        print(
            'Empty response body received while fetching review by product id');
        return null;
      }
    } catch (error) {
      throw Exception('Error fetch review By product Id: $error');
    }
  }

  Future<String> createReview({required String sku, required int rating, required String comment,}) async {
    final apiUrl = '${Server.baseUrl}/api/reviews';

    if(AppData.token==null){
      print("token null");
    }
    String token = AppData.token!;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'SKU': sku,
          'rating': rating,
          'comment': comment
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return 'Tạo đánh giá thành công';
      } else {
        print('Lỗi khi tạo đánh giá ${response.statusCode}: ${data['message']}');
      }
      return data['message'];
    } catch (e) {
      print('Có lỗi xảy ra khi tạo đánh giá: $e');
      print(e);
      return e.toString();
    }
  }

}
