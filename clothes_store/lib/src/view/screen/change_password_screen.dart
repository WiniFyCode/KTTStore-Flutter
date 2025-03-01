import 'dart:convert';

import 'package:clothes_store/core/app_color.dart';
import 'package:clothes_store/core/app_data.dart';
import 'package:clothes_store/src/controller/profile_controller.dart';
import 'package:clothes_store/src/model/USER_MODEL.dart';
import 'package:clothes_store/src/view/screen/account_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:clothes_store/src/controller/user_controller.dart'; // Đảm bảo bạn có UserController với hàm changePassword
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ProfileController profileController = ProfileController();

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final currentPassword = _currentPasswordController.text;
        final newPassword = _newPasswordController.text;

        final result = await profileController.changePassword(currentPassword, newPassword);

        if (result.statusCode == 200) {
          showSnackBar(context, result.message!, Colors.green);
          setState(() {
            AppData.userInfo!.password = newPassword;
          });
          await saveUserToSharedPreferences(AppData.userInfo!, AppData.token!);
          print("đã lưu user vào SharedPreferences");
          Navigator.of(context).pop();
        } else {
          showSnackBar(context, result.message!, Colors.red);
        }
      } catch (e) {
        showSnackBar(context, "Có lỗi xảy ra khi đổi mật khẩu", Colors.red);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    if (value.length < 8 || value.length > 25) {
      return 'Mật khẩu phải từ 8 đến 25 ký tự';
    }
    if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(value)) {
      return 'Mật khẩu phải bao gồm số, chữ thường, chữ in hoa và ký tự đặc biệt';
    }
    return null;
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required Function(bool) onToggleVisibility,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
          prefixIcon: Icon(prefixIcon ?? FontAwesomeIcons.lock, color: AppColor.darkOrange, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
              size: 20,
            ),
            onPressed: () => onToggleVisibility(!obscureText),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColor.darkOrange),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Future<void> saveUserToSharedPreferences(USER_MODEL user,String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toMap()));
    await prefs.setString('token', token);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đổi mật khẩu',
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                    children: [
                      _buildPasswordField(
                        controller: _currentPasswordController,
                        label: 'Mật khẩu hiện tại',
                        obscureText: _obscureCurrentPassword,
                        onToggleVisibility: (value) => setState(() => _obscureCurrentPassword = value),
                        validator: _validatePassword,
                        prefixIcon: FontAwesomeIcons.key,
                      ),
                      _buildPasswordField(
                        controller: _newPasswordController,
                        label: 'Mật khẩu mới',
                        obscureText: _obscureNewPassword,
                        onToggleVisibility: (value) => setState(() => _obscureNewPassword = value),
                        validator: _validatePassword,
                      ),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: 'Xác nhận mật khẩu mới',
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: (value) => setState(() => _obscureConfirmPassword = value),
                        validator: (value) {
                          if (value != _newPasswordController.text) {
                            return 'Mật khẩu xác nhận không khớp';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColor.darkOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Mật khẩu phải:',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• Có độ dài từ 8 đến 25 ký tự\n• Chứa ít nhất một chữ in hoa\n• Chứa ít nhất một chữ thường\n• Chứa ít nhất một số\n• Chứa ít nhất một ký tự đặc biệt (!@#\$&*~)',
                              style: TextStyle(
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.darkOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Đổi mật khẩu',
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
