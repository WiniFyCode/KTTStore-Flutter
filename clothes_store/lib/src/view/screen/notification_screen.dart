import 'package:clothes_store/src/controller/notification_controller.dart';
import 'package:clothes_store/src/model/NOTIFICATION_MODEL.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:clothes_store/core/app_color.dart';

final NotificationController notificationController =
    Get.put(NotificationController());

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NOTIFICATION_MODEL> notifications = [];
  int currentPage = 1;
  int totalPage = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final data = await notificationController.fetchFavorites(currentPage);
      if (data != null) {
        setState(() {
          List<NOTIFICATION_MODEL> newList = data.notifications ?? [];
          notifications.addAll(newList);
          if(data.pagination!=null){
            totalPage = data.pagination!.totalPages ?? 1;
            currentPage = data.pagination!.currentPage ?? 1;
          } else{
            totalPage = 1;
            currentPage = 1;
            print("data.pagination bị null");
          }
          isLoading = false;
        });
      }
    } on Exception catch (e) {
      print("Error fetching notifications:");
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      final data = await notificationController.markAllAsRead();
      if (data != null) {
        showSnackBar(
            context, data, data.contains("Failed") ? Colors.red : Colors.green);
      }
      setState(() {
        notifications = [];
        currentPage = 1;
      });
      await fetchNotifications();
    } on Exception catch (e) {
      print("Error marking all notifications as read:");
      print(e);
    }
  }

  Future<void> markNotificationAsRead(int notificationID) async {
    try {
      final data = await notificationController.markAsRead(notificationID);
      if (data != null) {
        showSnackBar(
            context, data, data.contains("Failed") ? Colors.red : Colors.green);
      }
      setState(() {
        notifications = [];
        currentPage = 1;
      });
      await fetchNotifications();
    } on Exception catch (e) {
      print("Error marking notification as read:");
      print(e);
    }
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity * 0.7,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Thông báo",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(
                FontAwesomeIcons.envelopeOpenText,
                color: AppColor.darkOrange,
                size: 20,
              ),
              onPressed: () async {
                await markAllNotificationsAsRead();
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              AppColor.darkOrange.withOpacity(0.05),
              AppColor.darkOrange.withOpacity(0.1),
            ],
          ),
        ),
        child: isLoading
            ? _buildLoadingSkeleton()
            : notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.bellSlash,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Không có thông báo nào",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              notifications = [];
                              currentPage = 1;
                              isLoading = true;
                            });
                            await fetchNotifications();
                          },
                          color: AppColor.darkOrange,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              NOTIFICATION_MODEL notification = notifications[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () async {
                                      if (!notification.isRead!) {
                                        await markNotificationAsRead(
                                            notification.userNotificationID!);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: notification.isRead!
                                                  ? Colors.grey[100]
                                                  : AppColor.darkOrange.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              FontAwesomeIcons.bell,
                                              color: notification.isRead!
                                                  ? Colors.grey[400]
                                                  : AppColor.darkOrange,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  notification.title!,
                                                  style: TextStyle(
                                                    fontWeight: notification.isRead!
                                                        ? FontWeight.normal
                                                        : FontWeight.bold,
                                                    fontSize: 16,
                                                    color: notification.isRead!
                                                        ? Colors.grey[600]
                                                        : Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  notification.message!,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (!notification.isRead!)
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: const BoxDecoration(
                                                color: AppColor.darkOrange,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (currentPage < totalPage)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                currentPage++;
                              });
                              fetchNotifications();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.darkOrange,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: const Text(
                              'Xem thêm',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}

showSnackBar(context, String message, Color mau) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: mau,
      duration: const Duration(seconds: 2),
    ),
  );
}
