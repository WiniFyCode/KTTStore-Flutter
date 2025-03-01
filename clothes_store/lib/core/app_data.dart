import 'package:clothes_store/src/model/USER_MODEL.dart';
import 'package:flutter/material.dart';
import 'package:clothes_store/src/model/product.dart';
import 'package:clothes_store/src/model/numerical.dart';
import 'package:clothes_store/src/model/categorical.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:clothes_store/src/model/product_category.dart';
import 'package:clothes_store/src/model/product_size_type.dart';
import 'package:clothes_store/src/model/recommended_product.dart';
import 'package:clothes_store/src/model/bottom_nav_bar_item.dart';
import 'package:intl/intl.dart';

class AppData {
  const AppData._();

  static USER_MODEL? userInfo;
  static String? token;

  static const String dummyText = 'Lorem Ipsum is simply dummy text of the printing and typesetting'
      ' industry. Lorem Ipsum has been the industry\'s standard dummy text'
      ' ever since the 1500s, when an unknown printer took a galley of type'
      ' and scrambled it to make a type specimen book.';

  static List<Product> products = [
    Product(
      name: 'Samsung Galaxy A53 5G',
      price: 460,
      isAvailable: true,
      off: 300,
      quantity: 0,
      images: [
        'assets/images/a53_1.png',
        'assets/images/a53_2.png',
        'assets/images/a53_3.png',
      ],
      isFavorite: true,
      rating: 1,
      type: ProductType.mobile,
    ),
    Product(
      name: 'Samsung Galaxy Tab S7 FE',
      price: 380,
      isAvailable: false,
      off: 220,
      quantity: 0,
      images: [
        'assets/images/tab_s7_fe_1.png',
        'assets/images/tab_s7_fe_2.png',
        'assets/images/tab_s7_fe_3.png',
      ],
      isFavorite: false,
      rating: 4,
      type: ProductType.tablet,
    ),
    Product(
      name: 'Samsung Galaxy Tab S8+',
      price: 650,
      isAvailable: true,
      off: null,
      quantity: 0,
      images: [
        'assets/images/tab_s8_1.png',
        'assets/images/tab_s8_2.png',
        'assets/images/tab_s8_3.png',
      ],
      isFavorite: false,
      rating: 3,
      type: ProductType.tablet,
    ),
    Product(
      name: 'Samsung Galaxy Watch 4',
      price: 229,
      isAvailable: true,
      off: 200,
      quantity: 0,
      images: [
        'assets/images/galaxy_watch_4_1.png',
        'assets/images/galaxy_watch_4_2.png',
        'assets/images/galaxy_watch_4_3.png',
      ],
      isFavorite: false,
      rating: 5,
      sizes: ProductSizeType(
        categorical: [
          Categorical(CategoricalType.small, true),
          Categorical(CategoricalType.medium, false),
          Categorical(CategoricalType.large, false),
        ],
      ),
      type: ProductType.watch,
    ),
    Product(
      name: 'Apple Watch 7',
      price: 330,
      isAvailable: true,
      off: null,
      quantity: 0,
      images: [
        'assets/images/apple_watch_series_7_1.png',
        'assets/images/apple_watch_series_7_2.png',
        'assets/images/apple_watch_series_7_3.png',
      ],
      isFavorite: false,
      rating: 4,
      sizes: ProductSizeType(
        numerical: [
          Numerical('41', true),
          Numerical('45', false),
        ],
      ),
      type: ProductType.watch,
    ),
    Product(
      name: 'Beats studio 3',
      price: 230,
      isAvailable: true,
      off: null,
      quantity: 0,
      images: [
        'assets/images/beats_studio_3-1.png',
        'assets/images/beats_studio_3-2.png',
        'assets/images/beats_studio_3-3.png',
        'assets/images/beats_studio_3-4.png',
      ],
      isFavorite: false,
      rating: 2,
      type: ProductType.headphone,
    ),
    Product(
      name: 'Samsung Q60 A',
      price: 497,
      isAvailable: true,
      off: null,
      quantity: 0,
      images: [
        'assets/images/samsung_q_60_a_1.png',
        'assets/images/samsung_q_60_a_2.png',
      ],
      isFavorite: false,
      rating: 3,
      sizes: ProductSizeType(
        numerical: [
          Numerical('43', true),
          Numerical('50', false),
          Numerical('55', false),
        ],
      ),
      type: ProductType.tv,
    ),
    Product(
      name: 'Sony x 80 J',
      price: 498,
      isAvailable: true,
      off: null,
      quantity: 0,
      images: [
        'assets/images/sony_x_80_j_1.png',
        'assets/images/sony_x_80_j_2.png',
      ],
      isFavorite: false,
      sizes: ProductSizeType(
        numerical: [
          Numerical('50', true),
          Numerical('65', false),
          Numerical('85', false),
        ],
      ),
      rating: 2,
      type: ProductType.tv,
    ),
  ];

  static List<ProductCategory> categories = [
    ProductCategory(
      type: ProductType.all,
      icon: Icons.all_inclusive,
    ),
    ProductCategory(
      type: ProductType.mobile,
      icon: FontAwesomeIcons.mobileScreenButton,
    ),
    ProductCategory(
      type: ProductType.watch,
      icon: Icons.watch,
    ),
    ProductCategory(
      type: ProductType.tablet,
      icon: FontAwesomeIcons.tablet,
    ),
    ProductCategory(
      type: ProductType.headphone,
      icon: Icons.headphones,
    ),
    ProductCategory(
      type: ProductType.tv,
      icon: Icons.tv,
    ),
  ];

  static List<Color> randomColors = [
    const Color(0xFFFCE4EC),
    const Color(0xFFF3E5F5),
    const Color(0xFFEDE7F6),
    const Color(0xFFE3F2FD),
    const Color(0xFFE0F2F1),
    const Color(0xFFF1F8E9),
    const Color(0xFFFFF8E1),
    const Color(0xFFECEFF1),
  ];

  static const Color lightOrangeColor = Color(0xFFEC6813);

  static List<BottomNavBarItem> bottomNavBarItems = [
    const BottomNavBarItem(
      "Home",
      Icon(Icons.home),
    ),
    const BottomNavBarItem(
      "Favorite",
      Icon(Icons.favorite),
    ),
    const BottomNavBarItem(
      "Cart",
      Icon(Icons.shopping_cart),
    ),
    const BottomNavBarItem(
      "Notif",
      Icon(Icons.notifications),
    ),
    const BottomNavBarItem(
      "Profile",
      Icon(Icons.person),
    ),
  ];

  static List<RecommendedProduct> recommendedProducts = [ // có thể làm carousel xem sản phẩm nam / nữ
    RecommendedProduct(
      cardBackgroundColor: const Color(0xFFFFBB69),
      buttonBackgroundColor: const Color(0xFFBA7DFF),
      buttonTextColor: Colors.white,
      detail: "Sản phẩm Nam",
      imagePath: "assets/images/aonam.png",
    ),
    RecommendedProduct(
      cardBackgroundColor: const Color(0xFF3081E1),
      buttonBackgroundColor: const Color(0xFFBA7DFF),
      buttonTextColor: Colors.white,
      detail: "Sản phẩm nữ",
      imagePath: "assets/images/aolen.png",
    ),
  ];

  static const List<Bank> banks = [
    Bank(code: 'vcb', name: 'Vietcombank'),
    Bank(code: 'tcb', name: 'Techcombank'),
    Bank(code: 'acb', name: 'ACB'),
    Bank(code: 'bidv', name: 'BIDV'),
    Bank(code: 'vtb', name: 'VietinBank'),
    Bank(code: 'mb', name: 'MB Bank'),
    Bank(code: 'scb', name: 'Sacombank'),
    Bank(code: 'tpb', name: 'TPBank'),
    Bank(code: 'ocb', name: 'OCB'),
    Bank(code: 'msb', name: 'MSB'),
    Bank(code: 'vpb', name: 'VPBank'),
    Bank(code: 'shb', name: 'SHB'),
    Bank(code: 'exb', name: 'Eximbank'),
    Bank(code: 'vib', name: 'VIB'),
    Bank(code: 'abb', name: 'ABBank'),
    Bank(code: 'pgb', name: 'PGBank'),
    Bank(code: 'bvb', name: 'BaoVietBank'),
    Bank(code: 'nab', name: 'NamABank'),
    Bank(code: 'vab', name: 'VietABank'),
    Bank(code: 'kib', name: 'KienLongBank'),
  ];

  static String formatDateTime(String dateTimeString) {
    try {
      final DateTime utcTime = DateTime.parse(dateTimeString);
      final DateTime localTime = utcTime.add(const Duration(hours: 7)); // UTC+7
      return DateFormat('HH:mm:ss dd-MM-yyyy').format(localTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

}

class Bank {
  final String code;
  final String name;

  const Bank({
    required this.code,
    required this.name,
  });
}
