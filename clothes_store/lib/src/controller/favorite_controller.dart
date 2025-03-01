import 'package:clothes_store/core/app_data.dart';
import 'package:clothes_store/server.dart';
import 'package:clothes_store/src/model/FAVORITE_MODEL.dart';
import 'package:clothes_store/src/model/FAVORITE_PAGINATION_MODEL.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoriteController {

  Future<FAVORITE_PAGINATION_MODEL?> fetchFavorites(int page, int limit) async {
    String apiUrl = '${Server.baseUrl}/api/favorite'; // Đường link API
    print("apiUrl: $apiUrl");
    String? authToken =
        AppData.token; // Token xác thực của người dùng
    print("authToken: $authToken");

    if (authToken != null) {
      try {
        Uri uri = Uri.parse(apiUrl).replace(queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        });

        var response = await http.get(
          uri,
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          return FAVORITE_PAGINATION_MODEL.fromJson(data);
        } else {
          print('Failed to fetch favorites. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          return null;
        }
      } catch (e) {
        print('Error while fetching favorites: $e');
        return null;
      }
    } else {
      print('không tìm thấy token');
      return null;
    }
  }

  Future<ReturnMessager> addToFavorites(String sku, String note) async {
    String apiUrl = '${Server.baseUrl}/api/favorite/add';
    print("user: ${AppData.userInfo.toString()}");
    String? authToken = AppData.token;

    if (authToken != null) {
      Map<String, String> requestBody = {
        'SKU': sku,
        'note': note,
      };

      print("requestBody: $requestBody");
      try {
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        );
        
        print("Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        
        Map<String, dynamic> responseData = json.decode(response.body);

        // Trả về message từ server bất kể status code là gì
        return ReturnMessager(
            messager: responseData['message'], 
            statusCode: response.statusCode
        );

      } catch (e) {
        print('Error while adding to favorites: $e');
        return ReturnMessager(
            messager: "Có lỗi xảy ra khi thêm vào yêu thích", 
            statusCode: 0
        );
      }
    } else {
      print('không tìm thấy token');
      return ReturnMessager(
          messager: "Vui lòng đăng nhập để thêm vào yêu thích", 
          statusCode: 0
      );
    }
  }

  Future<ReturnMessager> removeFavorite(String sku) async {
    String apiUrl = '${Server.baseUrl}/api/favorite/$sku';
    String? authToken = AppData.token;

    if (authToken != null) {
      try {
        var response = await http.delete(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        );
        
        print("Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        
        Map<String, dynamic> responseData = json.decode(response.body);

        return ReturnMessager(
            messager: responseData['message'], 
            statusCode: response.statusCode
        );

      } catch (e) {
        print('Error while removing from favorites: $e');
        return ReturnMessager(
            messager: "Có lỗi xảy ra khi xóa khỏi danh sách yêu thích", 
            statusCode: 0
        );
      }
    } else {
      print('không tìm thấy token');
      return ReturnMessager(
          messager: "Vui lòng đăng nhập để thực hiện chức năng này", 
          statusCode: 0
      );
    }
  }

  Future<ReturnMessager> updateFavoriteNote(int favoriteID, String note) async {
    String apiUrl = '${Server.baseUrl}/api/favorite/$favoriteID';
    String? authToken = AppData.token;

    if (authToken != null) {
      try {
        var response = await http.put(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          body: json.encode({'note': note}),
        );
        
        print("Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        
        Map<String, dynamic> responseData = json.decode(response.body);

        return ReturnMessager(
            messager: responseData['message'], 
            statusCode: response.statusCode
        );

      } catch (e) {
        print('Error while updating favorite note: $e');
        return ReturnMessager(
            messager: "Có lỗi xảy ra khi cập nhật ghi chú", 
            statusCode: 0
        );
      }
    } else {
      print('không tìm thấy token');
      return ReturnMessager(
          messager: "Vui lòng đăng nhập để thực hiện chức năng này", 
          statusCode: 0
      );
    }
  }
}

class ReturnMessager {
  final String? messager;
  final int? statusCode;
  ReturnMessager({this.messager, this.statusCode});
}
