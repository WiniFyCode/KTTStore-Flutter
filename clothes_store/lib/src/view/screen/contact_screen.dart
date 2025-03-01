import 'package:clothes_store/core/app_color.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  // Kiểm tra thời gian có trong giờ làm việc không
  bool _isWithinWorkingHours() {
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final openMinutes = 8 * 60; // 8:00
    final closeMinutes = 22 * 60; // 22:00
    return currentMinutes >= openMinutes && currentMinutes < closeMinutes;
  }

  // Hàm gọi điện thoại
  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    if (!_isWithinWorkingHours()) {
      // Hiển thị thông báo nếu ngoài giờ làm việc
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể liên lạc ở thời gian này, vui lòng liên hệ qua Gmail'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Không thể gọi $phoneNumber';
    }
  }

  // Hàm mở email
  Future<void> _launchEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Không thể mở email $email';
    }
  }

  // Hàm mở google map
  Future<void> _launchGoogleMap() async {
    // Mã hóa địa chỉ để tránh các ký tự đặc biệt
    final String encodedAddress = Uri.encodeComponent("123 đường ABC, quận XYZ, TP.HCM");
    final Uri launchUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(
        launchUri,
        mode: LaunchMode.externalApplication, // Mở trong ứng dụng Google Maps
      );
    } else {
      throw 'Không thể mở Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Liên hệ",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo và Tên cửa hàng
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "KTT",
                            style: TextStyle(
                              color: AppColor.darkOrange,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "KTT STORE",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Thời trang cho mọi người",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Thông tin liên hệ
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Thông tin liên hệ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.darkOrange,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildContactItem(
                        icon: FontAwesomeIcons.locationDot,
                        title: "Địa chỉ",
                        content: "123 đường ABC, quận XYZ, TP.HCM",
                      ),
                      _buildContactItem(
                        icon: FontAwesomeIcons.phone,
                        title: "Điện thoại",
                        content: "0836200798",
                      ),
                      _buildContactItem(
                        icon: FontAwesomeIcons.envelope,
                        title: "Email",
                        content: "kttstore3cg@gmail.com",
                      ),
                      _buildContactItem(
                        icon: FontAwesomeIcons.clock,
                        title: "Giờ làm việc",
                        content: "8:00 - 22:00 (Thứ 2 - Chủ nhật)",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Mạng xã hội
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kết nối với chúng tôi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.darkOrange,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSocialButton(
                            icon: FontAwesomeIcons.facebook,
                            color: const Color(0xFF1877F2),
                          ),
                          _buildSocialButton(
                            icon: FontAwesomeIcons.instagram,
                            color: const Color(0xFFE4405F),
                          ),
                          _buildSocialButton(
                            icon: FontAwesomeIcons.tiktok,
                            color: Colors.black,
                          ),
                          _buildSocialButton(
                            icon: FontAwesomeIcons.youtube,
                            color: const Color(0xFFFF0000),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColor.darkOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColor.darkOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                if (title == "Điện thoại")
                  Builder(
                    builder: (context) => InkWell(
                      onTap: () => _makePhoneCall(context, "0836200798"),
                      child: Row(
                        children: [
                          Text(
                            content,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColor.darkOrange,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isWithinWorkingHours() ? "(Có thể gọi)" : "(Ngoài giờ làm việc)",
                            style: TextStyle(
                              fontSize: 12,
                              color: _isWithinWorkingHours() ? Colors.green : Colors.red,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (title == "Email")
                  InkWell(
                    onTap: () => _launchEmail("kttstore3cg@gmail.com"),
                    child: Text(
                      content,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColor.darkOrange,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else if (title == "Địa chỉ")
                  InkWell(
                    onTap: _launchGoogleMap,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            content,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColor.darkOrange,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FontAwesomeIcons.mapLocationDot,
                                size: 12,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Xem bản đồ",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: color,
        size: 28,
      ),
    );
  }
}
