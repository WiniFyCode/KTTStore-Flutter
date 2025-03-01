import 'package:clothes_store/core/app_color.dart';
import 'package:clothes_store/src/view/screen/home_screen.dart';
import 'package:clothes_store/src/view/screen/product_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmptyCart extends StatelessWidget {
  const EmptyCart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final size = MediaQuery.of(context).size;
    final imageSize = size.width * 0.6; // 60% chiều rộng màn hình
    
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hình ảnh giỏ hàng trống
            Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                color: AppColor.darkOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Icon giỏ hàng
                  Icon(
                    FontAwesomeIcons.cartShopping,
                    size: imageSize * 0.4,
                    color: AppColor.darkOrange.withOpacity(0.3),
                  ),
                  // Icon dấu x
                  Positioned(
                    top: imageSize * 0.25,
                    right: imageSize * 0.25,
                    child: Container(
                      padding: EdgeInsets.all(imageSize * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        FontAwesomeIcons.xmark,
                        size: imageSize * 0.15,
                        color: Colors.red.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: size.height * 0.04),
            
            // Tiêu đề
            Text(
              'Giỏ hàng trống',
              style: TextStyle(
                fontSize: size.width * 0.07,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            SizedBox(height: size.height * 0.02),
            
            // Mô tả
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
              child: Text(
                'Có vẻ như bạn chưa thêm sản phẩm nào vào giỏ hàng',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
            
            SizedBox(height: size.height * 0.04),
            
            // Nút mua sắm
            SizedBox(
              width: size.width * 0.7,
              height: size.height * 0.06,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                },
                icon: Icon(
                  FontAwesomeIcons.bagShopping,
                  size: size.width * 0.05,
                ),
                label: Text(
                  'Mua sắm ngay',
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.darkOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(size.width * 0.03),
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
