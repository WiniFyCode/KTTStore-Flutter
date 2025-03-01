import 'package:clothes_store/src/view/screen/home_screen.dart';
import 'package:clothes_store/src/view/screen/order_list_screen.dart';
import 'package:clothes_store/src/view/screen/product_list_screen.dart';
import 'package:flutter/material.dart';

class OrderSuccessfullyPage extends StatelessWidget {
  const OrderSuccessfullyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 24),
            const Text(
              'Đặt hàng thành công!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cảm ơn bạn đã mua hàng.\nChúng tôi sẽ sớm liên hệ với bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Quay về trang chủ
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
              },
              child: const Text('Về trang chủ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Chuyển đến trang đơn hàng của tôi
                Navigator.push(context, MaterialPageRoute(builder: (context) => OrderListScreen()));
              },
              child: const Text('Xem đơn hàng của tôi'),
            ),
          ],
        ),
      ),
    );
  }
}