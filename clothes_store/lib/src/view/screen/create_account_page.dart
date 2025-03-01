import 'package:clothes_store/src/controller/user_controller.dart';
import 'package:clothes_store/src/view/screen/login_page.dart';
import 'package:flutter/material.dart';

UserController userController = UserController();

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {

  TextEditingController fullnameCon = TextEditingController();
  TextEditingController emailCon = TextEditingController();
  TextEditingController passwordCon = TextEditingController();
  TextEditingController passwordVerifyCon = TextEditingController();
  TextEditingController phoneCon = TextEditingController();
  String gender = "male";

  String selectedValue_target = 'male';
  List<String> dropdownItems = ['male', 'female'];
  bool hidePass1 = true;
  bool hidePass2 = true;

  Future<void> userSignup() async {
    try {
      final data = await userController.signUp(
        fullnameCon.text.toString(),
        emailCon.text.toString(),
        passwordCon.text.toString(),
        phoneCon.text.toString(),
        gender
      );
      if (data.userModel != null) {
        if(data.errorMessage==""){
          showSnackBar(context, "Đăng ký thành công", Colors.green);
        }
        else{
          showSnackBar(context, data.errorMessage!, Colors.red);
        }

      }
    } on Exception catch (e) {
      print("error tại sign up:");
      print(e);
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
                  'assets/images/bubbles.png',
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
                      SizedBox(height: height * 0.05),

                      // Create Account text
                      Text(
                        'Tạo tài khoản',
                        style: TextStyle(
                          color: const Color(0xFF202020),
                          fontSize: size.width * 0.13,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),

                      SizedBox(height: height * 0.04),

                      // Fullname field
                    Container(
                        height: height * 0.07,
                      decoration: ShapeDecoration(
                          color: const Color(0xFFEDEDF1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(59.29),
                        ),
                      ),
                        child: TextField(
                          controller: fullnameCon,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: height * 0.025,
                              horizontal: size.width * 0.05,
                            ),
                            border: InputBorder.none,
                            hintText: "Họ và tên",
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

                      // Phone and Gender row
                      Row(
                        children: [
                          // Phone field
                          Expanded(
                            flex: 7,
                            child: Container(
                              height: height * 0.07,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFEDEDF1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(59.29),
                                ),
                              ),
                              child: TextField(
                                controller: phoneCon,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: height * 0.025,
                                    horizontal: size.width * 0.05,
                                  ),
                                  border: InputBorder.none,
                                  hintText: "Phone",
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
                          ),
                          SizedBox(width: size.width * 0.03),
                          // Gender dropdown
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: height * 0.07,
                              padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(59.29),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.grey[200],
                                  value: gender,
                                  isExpanded: true,
                          items: dropdownItems.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          fontSize: size.width * 0.035,
                                        ),
                                      ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              gender = newValue!;
                            });
                          },
                        ),
                      ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: height * 0.02),

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
                                obscureText: hidePass1,
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
                              hidePass1 = !hidePass1;
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

                      // Verify Password field
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
                                controller: passwordVerifyCon,
                                obscureText: hidePass2,
                            decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: height * 0.025,
                                    horizontal: size.width * 0.05,
                                  ),
                              border: InputBorder.none,
                              hintText: "Nhập lại mật khẩu",
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
                                hidePass2 = !hidePass2;
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

                      SizedBox(height: height * 0.04),

                      // Done button
                      SizedBox(
                        width: double.infinity,
                        height: height * 0.07,
                child: ElevatedButton(
                          onPressed: () {
                            if (fullnameCon.text.isEmpty) {
                              showSnackBar(context, "Vui lòng nhập fullname", Colors.red);
                            } else if (emailCon.text.isEmpty) {
                              showSnackBar(context, "Vui lòng nhập email", Colors.red);
                            } else if (passwordCon.text.isEmpty) {
                              showSnackBar(context, "Vui lòng nhập password", Colors.red);
                            } else if (passwordVerifyCon.text.isEmpty) {
                              showSnackBar(context, "Vui lòng nhập password verify", Colors.red);
                            } else if (phoneCon.text.isEmpty) {
                              showSnackBar(context, "Vui lòng nhập phone", Colors.red);
                            } else if (passwordCon.text != passwordVerifyCon.text) {
                              showSnackBar(context, "Password và password verify không khớp", Colors.red);
                            } else {
                              userSignup();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0XFFFF8C00),
                            shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                  ),
                ),
                        child: Text(
                            'Hoàn tất',
                          style: TextStyle(
                              color: const Color(0xFFF3F3F3),
                              fontSize: size.width * 0.045,
                            fontFamily: 'Nunito Sans',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.02),

                      // Back to Login button
                      SizedBox(
                        width: double.infinity,
                        height: height * 0.07,
                child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
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
                            'Quay trở lại đăng nhập',
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