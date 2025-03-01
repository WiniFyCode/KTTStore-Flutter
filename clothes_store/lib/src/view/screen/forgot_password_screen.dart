import 'package:clothes_store/src/controller/user_controller.dart';
import 'package:clothes_store/src/view/screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:clothes_store/core/app_color.dart';

UserController userController = UserController();

class ForgotPasswordScreenPage extends StatefulWidget {
  const ForgotPasswordScreenPage({super.key});

  @override
  State<ForgotPasswordScreenPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<ForgotPasswordScreenPage> {
  TextEditingController emailCon = TextEditingController();
  TextEditingController passwordCon = TextEditingController();
  TextEditingController passwordVerifyCon = TextEditingController();
  TextEditingController otpCon = TextEditingController();

  bool hidePass1 = true;
  bool hidePass2 = true;
  bool isOtpSent = false;
  bool isLoading = false;

  Future<void> sendOTP() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final data = await userController.sendOTP(emailCon.text.toString());

      if(data.statusCode==200){
        setState(() {
          isOtpSent = true;
        });
        showSnackBar(context, data.messager!, Colors.green);
      } else {
        showSnackBar(context, data.messager!, Colors.red);
      }

    } catch (e) {
      print("error tại reset password:");
      print(e);
      showSnackBar(context, "Có lỗi xảy ra khi gửi OTP", Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> resetPassword() async {
    setState(() {
      isLoading = true;
    });

    try {
      int maOTP = int.parse(otpCon.text.trim());
      final data = await userController.resetPassword(
        emailCon.text.trim(), 
        maOTP.toString(), 
        passwordCon.text.toString()
      );

      if(data.statusCode==200){
        showSnackBar(context, data.messager!, Colors.green);
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => LoginPage())
        );
      } else {
        showSnackBar(context, data.messager!, Colors.red);
      }

    } catch (e) {
      print("error tại reset password:");
      print(e);
      showSnackBar(context, "Có lỗi xảy ra khi đặt lại mật khẩu", Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.05),
                  
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),

                  SizedBox(height: height * 0.02),

                  // Title
                  Text(
                    'Quên\nmật khẩu?',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: size.width * 0.13,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                  SizedBox(height: height * 0.02),

                  // Subtitle
                  Text(
                    'Đừng lo lắng! Vui lòng nhập email của bạn để nhận mã OTP',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: size.width * 0.04,
                    ),
                  ),

                  SizedBox(height: height * 0.05),

                  // Email field
                  Container(
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
                    child: TextField(
                      controller: emailCon,
                      enabled: !isOtpSent,
                      decoration: InputDecoration(
                        hintText: "Email",
                        prefixIcon: Icon(Icons.email_outlined, color: AppColor.darkOrange),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.02),

                  // Send OTP Button
                  if (!isOtpSent)
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.06,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () {
                          if (emailCon.text.isEmpty) {
                            showSnackBar(context, "Vui lòng nhập email", Colors.red);
                          } else {
                            sendOTP();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.darkOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Gửi mã OTP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                    ),

                  if (isOtpSent) ...[
                    // OTP field
                    Container(
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
                      child: TextField(
                        controller: otpCon,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Nhập mã OTP",
                          prefixIcon: Icon(Icons.lock_clock_outlined, color: AppColor.darkOrange),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.02),

                    // New Password field
                    Container(
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
                      child: TextField(
                        controller: passwordCon,
                        obscureText: hidePass1,
                        decoration: InputDecoration(
                          hintText: "Mật khẩu mới",
                          prefixIcon: Icon(Icons.lock_outline, color: AppColor.darkOrange),
                          suffixIcon: IconButton(
                            icon: Icon(
                              hidePass1 ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() => hidePass1 = !hidePass1),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.02),

                    // Confirm Password field
                    Container(
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
                      child: TextField(
                        controller: passwordVerifyCon,
                        obscureText: hidePass2,
                        decoration: InputDecoration(
                          hintText: "Xác nhận mật khẩu mới",
                          prefixIcon: Icon(Icons.lock_outline, color: AppColor.darkOrange),
                          suffixIcon: IconButton(
                            icon: Icon(
                              hidePass2 ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() => hidePass2 = !hidePass2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.04),

                    // Reset Password button
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.06,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () {
                          if (otpCon.text.isEmpty) {
                            showSnackBar(context, "Vui lòng nhập mã OTP", Colors.red);
                          } else if (passwordCon.text.isEmpty) {
                            showSnackBar(context, "Vui lòng nhập mật khẩu mới", Colors.red);
                          } else if (passwordVerifyCon.text.isEmpty) {
                            showSnackBar(context, "Vui lòng xác nhận mật khẩu", Colors.red);
                          } else if (passwordCon.text != passwordVerifyCon.text) {
                            showSnackBar(context, "Mật khẩu không khớp", Colors.red);
                          } else {
                            resetPassword();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.darkOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Đặt lại mật khẩu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                    ),

                    // Resend OTP button
                    TextButton(
                      onPressed: isLoading ? null : sendOTP,
                      child: Text(
                        'Gửi lại mã OTP',
                        style: TextStyle(
                          color: AppColor.darkOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: height * 0.02),

                  // Back to Login button
                  SizedBox(
                    width: double.infinity,
                    height: height * 0.06,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColor.darkOrange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Quay lại đăng nhập',
                        style: TextStyle(
                          color: AppColor.darkOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
