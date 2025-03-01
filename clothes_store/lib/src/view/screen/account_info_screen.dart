import 'dart:convert';

import 'package:clothes_store/core/app_color.dart';
import 'package:clothes_store/src/controller/profile_controller.dart';
import 'package:clothes_store/src/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:clothes_store/core/app_data.dart';
import 'package:clothes_store/src/model/USER_MODEL.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ProfileController profileController = ProfileController();
final UserController userController = UserController();

class AccountInfoScreen extends StatefulWidget {
  @override
  _AccountInfoScreenState createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  String? fullname;
  String? gender;
  String? phone;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fullname = AppData.userInfo?.fullname;
    gender = AppData.userInfo?.gender;
    phone = AppData.userInfo?.phone;
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      _formKey.currentState!.save();
      
      try {
        final result = await profileController.updateProfile(fullname!, gender!, phone!);
        if (result.statusCode == 200) {
          setState(() {
            AppData.userInfo!.fullname = fullname;
            AppData.userInfo!.gender = gender;
            AppData.userInfo!.phone = phone;
          });
          await saveUserToSharedPreferences(AppData.userInfo!, AppData.token!);
          showSnackBar(context, "Cập nhật thông tin thành công", Colors.green);
          Navigator.of(context).pop();
        } else {
          showSnackBar(context, result.message!, Colors.red);
        }
      } catch (e) {
        showSnackBar(context, "Có lỗi xảy ra khi cập nhật thông tin", Colors.red);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> saveUserToSharedPreferences(USER_MODEL user,String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toMap()));
    await prefs.setString('token', token);
  }

  Widget _buildTextField({
    required String label,
    required String? initialValue,
    bool readOnly = false,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    IconData? prefixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        initialValue: initialValue,
        readOnly: readOnly,
        onSaved: onSaved,
        validator: validator,
        style: TextStyle(
          color: readOnly ? Colors.grey[600] : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppColor.darkOrange, size: 22)
              : null,
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
          fillColor: readOnly ? Colors.grey[100] : Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông tin tài khoản',
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
                      _buildTextField(
                        label: 'User ID',
                        initialValue: "${AppData.userInfo?.userID}",
                        readOnly: true,
                        prefixIcon: FontAwesomeIcons.idCard,
                      ),
                      _buildTextField(
                        label: 'Email',
                        initialValue: AppData.userInfo?.email,
                        readOnly: true,
                        prefixIcon: FontAwesomeIcons.envelope,
                      ),
                      _buildTextField(
                        label: 'Họ và tên',
                        initialValue: fullname,
                        onSaved: (value) => fullname = value,
                        validator: (value) => value!.isEmpty ? 'Vui lòng nhập họ và tên' : null,
                        prefixIcon: FontAwesomeIcons.user,
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 12),
                              child: Text(
                                'Giới tính',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Nam'),
                                    value: 'male',
                                    groupValue: gender,
                                    onChanged: (value) {
                                      setState(() {
                                        gender = value;
                                      });
                                    },
                                    activeColor: AppColor.darkOrange,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Nữ'),
                                    value: 'female',
                                    groupValue: gender,
                                    onChanged: (value) {
                                      setState(() {
                                        gender = value;
                                      });
                                    },
                                    activeColor: AppColor.darkOrange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildTextField(
                        label: 'Số điện thoại',
                        initialValue: phone,
                        onSaved: (value) => phone = value,
                        validator: (value) => value!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                        prefixIcon: FontAwesomeIcons.phone,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.darkOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
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
                            'Cập nhật thông tin',
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