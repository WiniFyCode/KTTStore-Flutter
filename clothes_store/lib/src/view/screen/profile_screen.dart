import 'dart:convert';
import 'dart:io';

import 'package:clothes_store/core/app_color.dart';
import 'package:clothes_store/core/app_data.dart';
import 'package:clothes_store/src/controller/profile_controller.dart';
import 'package:clothes_store/src/controller/user_controller.dart';
import 'package:clothes_store/src/model/USER_MODEL.dart';
import 'package:clothes_store/src/view/screen/account_info_screen.dart';
import 'package:clothes_store/src/view/screen/address_management.dart';
import 'package:clothes_store/src/view/screen/change_password_screen.dart';
import 'package:clothes_store/src/view/screen/contact_screen.dart';
import 'package:clothes_store/src/view/screen/coupon_list_screen.dart';
import 'package:clothes_store/src/view/screen/login_page.dart';
import 'package:clothes_store/src/view/screen/order_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ProfileController profileController = ProfileController();
final UserController userController = UserController();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  USER_MODEL? user_model;
  String imageURL = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final data = await userController.getUserByToken();
    if (data != null) {
      setState(() {
        user_model = data;
        AppData.userInfo = user_model;
        imageURL = data.avatar!;
        isLoading = false;
      });
    } else {
      print("fetchUserData error, data null");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final result = await profileController.changeAvatar(image.path);
      if (result.statusCode == 200) {
        showSnackBar(context, "Cập nhật ảnh đại diện thành công", Colors.green);
        await fetchUserData();
        await saveUserToSharedPreferences(user_model!, AppData.token!);
      } else {
        showSnackBar(context, result.message!, Colors.red);
      }
    }
  }

  Future<void> saveUserToSharedPreferences(USER_MODEL user,String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toMap()));
    await prefs.setString('token', token);
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Avatar skeleton
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 16),
          // Name skeleton
          Container(
            width: 200,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 32),
          // Menu items skeleton
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 7,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 200,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tài khoản",
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
            : user_model == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Có lỗi xảy ra khi tải thông tin",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: fetchUserData,
                    color: AppColor.darkOrange,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColor.darkOrange,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 55,
                                      backgroundImage: NetworkImage(imageURL),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColor.darkOrange,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Xin chào, ${user_model!.fullname}!",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildProfileOption(
                              context,
                              "Thay đổi thông tin tài khoản",
                              FontAwesomeIcons.userPen,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AccountInfoScreen()),
                              ),
                            ),
                            _buildProfileOption(
                              context,
                              "Quản lý địa chỉ",
                              FontAwesomeIcons.locationDot,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AddressManagementScreen()),
                              ),
                            ),
                            _buildProfileOption(
                              context,
                              "Thay đổi mật khẩu",
                              FontAwesomeIcons.key,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                              ),
                            ),
                            _buildProfileOption(
                              context,
                              "Theo dõi đơn hàng",
                              FontAwesomeIcons.boxOpen,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => OrderListScreen()),
                              ),
                            ),
                            _buildProfileOption(
                              context,
                              "Mã giảm giá",
                              FontAwesomeIcons.ticket,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CouponScreen()),
                              ),
                            ),
                            _buildProfileOption(
                              context,
                              "Liên hệ",
                              FontAwesomeIcons.headset,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ContactScreen()),
                              ),
                            ),
                            _buildProfileOption(
                              context,
                              "Đăng xuất",
                              FontAwesomeIcons.rightFromBracket,
                              () async {
                                AppData.userInfo = null;
                                final SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.remove('user_data');
                                await prefs.remove('lastLogin');
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginPage()),
                                  (route) => false,
                                );
                              },
                              isLogout: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isLogout ? Colors.red.withOpacity(0.1) : Colors.white,
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isLogout
                        ? Colors.red.withOpacity(0.1)
                        : AppColor.darkOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isLogout ? Colors.red : AppColor.darkOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isLogout ? Colors.red : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isLogout ? Colors.red : Colors.grey,
                  size: 16,
                ),
              ],
            ),
          ),
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
