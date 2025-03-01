import 'package:clothes_store/core/app_color.dart';
import 'package:flutter/material.dart' show Color, Colors;

class RecommendedProduct {
  Color? cardBackgroundColor;
  Color? buttonTextColor;
  Color? buttonBackgroundColor;
  String imagePath;
  String detail;

  RecommendedProduct({
    this.cardBackgroundColor,
    this.buttonTextColor = AppColor.darkOrange,
    this.buttonBackgroundColor = Colors.white,
    this.imagePath = "assets/images/shopping.png",
    this.detail = "Shop Now",
  });

  @override
  String toString() {
    return 'RecommendedProduct{cardBackgroundColor: $cardBackgroundColor, buttonTextColor: $buttonTextColor, buttonBackgroundColor: $buttonBackgroundColor, imagePath: $imagePath, detail: $detail}';
  }
}
