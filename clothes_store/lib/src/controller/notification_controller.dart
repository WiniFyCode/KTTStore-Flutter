import 'dart:convert';
import 'package:clothes_store/core/app_data.dart';
import 'package:clothes_store/server.dart';
import 'package:clothes_store/src/model/NOTIFICATION_MODEL.dart';
import 'package:clothes_store/src/model/NOTIFICATION_PAGINATION_MODEL.dart';
import 'package:http/http.dart' as http;

  class NotificationController {

  Future<NOTIFICATION_PAGINATION_MODEL?> fetchFavorites(int page) async {
    String apiUrl = '${Server.baseUrl}/api/notification'; // Đường link API
    String? authToken = AppData.token; // Token xác thực của người dùng
    int limit = 15;

    try {
      Uri uri = Uri.parse(apiUrl).replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return NOTIFICATION_PAGINATION_MODEL.fromJson(data);
      } else {
        print('Failed to load notifications');
        print("fetching notification error ${response.statusCode}: ${json.decode(response.body)["message"]}");
        return null;
      }
    } catch (error) {
      print('Error fetching notifications: $error');
      return null;
    }
  }

  Future<String> markAsRead(int id) async {
    String apiUrl = '${Server.baseUrl}/api/notification/read/$id'; // Đường link API
    String? authToken = AppData.token; // Token xác thực của người dùng

    try {
      final response = await http.put(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      });

      if (response.statusCode == 200) {
        return 'Notification marked as read';
      } else {
        Map<String, dynamic> data = json.decode(response.body);
        String? error = data['error'];
        print("error ${response.statusCode}: $error");
        String errorResult = "";
        if(error!=null){
          errorResult = "\n$error";
        }
        return '${response.statusCode} - Failed to mark all as read $errorResult';
      }
    } catch (error) {
      return 'Error marking as read: $error';
    }
  }

  Future<String> markAllAsRead() async {
    String apiUrl = '${Server.baseUrl}/api/notification/read-all'; // Đường link API
    String? authToken = AppData.token; // Token xác thực của người dùng

    try {
      final response = await http.put(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      });

      if (response.statusCode == 200) {
        return 'All notifications marked as read';
      } else {
        Map<String, dynamic> data = json.decode(response.body);
        String? error = data['error'];
        print("error ${response.statusCode}: $error");
        String errorResult = "";
        if(error!=null){
          errorResult = "\n$error";
        }
        return '${response.statusCode} - Failed to mark all as read $errorResult';
      }
    } catch (error) {
      return 'Error marking all as read: $error';
    }
  }

  Future<int?> getUnreadCount() async {
    String apiUrl = '${Server.baseUrl}/api/notification/unread/count'; // Đường link API
    String? authToken = AppData.token; // Token xác thực của người dùng

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data['unreadCount'];
      } else {
        print('Failed to get unread count');
        return null;
      }
    } catch (error) {
      print('Error getting unread count: $error');
      return null;
    }
  }
}