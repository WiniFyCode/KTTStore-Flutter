
import 'package:clothes_store/src/view/screen/login_page.dart';
import 'package:flutter/material.dart';
import 'dart:ui' show PointerDeviceKind;
import 'package:clothes_store/core/app_theme.dart';
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        },
      ),
      debugShowCheckedModeBanner: false,
      //home: const HomeScreen(),
      theme: AppTheme.lightAppTheme,
      // home: CreateAccountPage(),
      home: LoginPage(),
    );
  }
}
