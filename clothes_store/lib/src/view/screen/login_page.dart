import 'package:clothes_store/core/app_data.dart';
import 'package:clothes_store/src/controller/user_controller.dart';
import 'package:clothes_store/src/model/USER_MODEL.dart';
import 'package:clothes_store/src/view/screen/create_account_page.dart';
import 'package:clothes_store/src/view/screen/forgot_password_screen.dart';
import 'package:clothes_store/src/view/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

UserController userController = UserController();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController emailCon = TextEditingController();
  TextEditingController passwordCon = TextEditingController();

  bool hidePass = true;

  @override
  void initState() {
    super.initState();
    checkLastLoginAndUpdate();
  }

  Future<void> checkLastLoginAndUpdate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lastLogin = prefs.getString('lastLogin');
    print("last login: ${lastLogin}");

    if (lastLogin != null) {
      DateTime lastLoginTime = DateTime.parse(lastLogin);
      DateTime currentTime = DateTime.now();
      Duration difference = currentTime.difference(lastLoginTime);

      if (difference.inDays > 7) {
        // Nếu đã quá 7 ngày, cập nhật lastLogin thành null
        await prefs.setString('lastLogin', "");
      }
      else{
        print("vẫn còn phiên đăng nhập, chuyển đến trang HomePage");
        USER_MODEL? user = await getUserFromSharedPreferences();
        AppData.userInfo = user;
        AppData.token = prefs.getString('token');
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    }
  }

  Future<void> userLogin() async {
    try {
      final data = await userController.login(
          emailCon.text.toString(),
          passwordCon.text.toString()
      );
        if(data.errorMessage==""){
          showSnackBar(context, "Đăng nhập thành công", Colors.green);
          setState(() {
            AppData.userInfo = data.userModel;
          });
          print("user = ${data.userModel?.toString()}");

          // Lưu thông tin người dùng vào SharedPreferences
          await saveUserToSharedPreferences(data.userModel!, data.token!);

          // get thông tin từ sharedPreferences
          // USER_MODEL? testUser = await getUserFromSharedPreferences();
          // print("testUser = ${testUser?.toString()}");

          String lastLogin = await getLastLoginTime();
          print("lastLogin = $lastLogin");

          Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        }
        else{
          showSnackBar(context, data.errorMessage!, Colors.red);
        }


    } on Exception catch (e) {
      print("error tại login:");
      print(e);
    }
  }

  // Hàm lưu thông tin người dùng vào SharedPreferences
  Future<void> saveUserToSharedPreferences(USER_MODEL user,String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toMap()));
    await prefs.setString('lastLogin', DateTime.now().toString());
    await prefs.setString('token', token);
  }

  Future<USER_MODEL?> getUserFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      Map<String, dynamic> userDataMap = json.decode(userDataString);
      return USER_MODEL(
        userID: userDataMap['userID'],
        fullname: userDataMap['fullname'],
        gender: userDataMap['gender'],
        email: userDataMap['email'],
        password: userDataMap['password'],
        phone: userDataMap['phone'],
        token: userDataMap['token'],
      );
    } else {
      return null;
    }
  }

  Future<String> getLastLoginTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastLogin') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final height = size.height - padding.top - padding.bottom;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            // Background image
            Positioned(
              left: -size.width * 0.3,
              top: -size.height * 0.3,
              child: Container(
                width: size.width * 2,
                height: size.height * 1.2,
                child: Image.asset(
                  'assets/images/bubbles (2).png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: height * 0.1),
                      
                      // Login text
                      Text(
                        'Đăng nhập',
                        style: TextStyle(
                          color: const Color(0xFF202020),
                          fontSize: size.width * 0.13,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.52,
                        ),
                      ),

                      SizedBox(height: height * 0.02),

                      // Welcome text
                      Row(
                        children: [
                          Text(
                            'Chào mừng bạn trở lại! ',
                            style: TextStyle(
                              color: const Color(0xFF202020),
                              fontSize: size.width * 0.045,
                              fontFamily: 'Nunito Sans',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Icon(FontAwesomeIcons.solidHeart, size: size.width * 0.04),
                        ],
                      ),

                      SizedBox(height: height * 0.06),

                      // Email field
                      Container(
                        height: height * 0.07,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFEDEDF1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(59.29),
                          ),
                        ),
                        child: TextField(
                          controller: emailCon,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: height * 0.025,
                              horizontal: size.width * 0.05,
                            ),
                            border: InputBorder.none,
                            hintText: "Email",
                            hintStyle: TextStyle(
                              color: const Color(0xFFD2D2D2),
                              fontSize: size.width * 0.035,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),

                      SizedBox(height: height * 0.02),

                      // Password field
                      Container(
                        height: height * 0.07,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFEDEDF1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(59.29),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: passwordCon,
                                obscureText: hidePass,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: height * 0.025,
                                    horizontal: size.width * 0.05,
                                  ),
                                  border: InputBorder.none,
                                  hintText: "Mật khẩu",
                                  hintStyle: TextStyle(
                                    color: const Color(0xFFD2D2D2),
                                    fontSize: size.width * 0.035,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  hidePass = !hidePass;
                                });
                              },
                              icon: Image.asset(
                                'assets/images/eye-slash.png',
                                height: size.width * 0.04,
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                          ],
                        ),
                      ),

                      SizedBox(height: height * 0.02),

                      // Forget Password button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreenPage(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                          ),
                          child: Text(
                            'Quên mật khẩu ?',
                            style: TextStyle(
                              fontSize: size.width * 0.030,
                              fontFamily: 'Nunito Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.06),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: height * 0.07,
                        child: ElevatedButton(
                          onPressed: () {
                            if (emailCon.text.isEmpty) {
                              showSnackBar(context, "Vui lòng nhập email", Colors.red);
                            } else if (passwordCon.text.isEmpty) {
                              showSnackBar(context, "Vui lòng nhập password", Colors.red);
                            } else {
                              userLogin();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0XFFFF8C00),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Tiếp tục',
                            style: TextStyle(
                              color: const Color(0xFFF3F3F3),
                              fontSize: size.width * 0.045,
                              fontFamily: 'Nunito Sans',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.04),

                      // Sign up button
                      SizedBox(
                        width: double.infinity,
                        height: height * 0.07,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateAccountPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEDEDF1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Không có tài khoản ?",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * 0.04,
                              fontFamily: 'Nunito Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
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

showSnackBar(context, String message, Color mau){
  return(
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: mau,))
  );
}
