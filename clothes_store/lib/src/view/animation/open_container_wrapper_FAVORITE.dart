import 'package:clothes_store/src/model/FAVORITE_MODEL.dart';
import 'package:clothes_store/src/view/screen/product_detail_screen2.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class OpenContainerWrapper_FAVORITE extends StatelessWidget {
  const OpenContainerWrapper_FAVORITE({
    super.key,
    required this.child,
    required this.favProduct,
  });

  final Widget child;
  // final Product product;
  final FAVORITE_MODEL favProduct;

  @override
  Widget build(BuildContext context) {

    String firstNumberString = favProduct.sKU!.split('_')[0]; // Tách chuỗi theo dấu '_'
    int id = int.tryParse(firstNumberString) ?? 0; // Chuyển chuỗi thành số nguyên

    return OpenContainer(
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      closedColor: const Color(0xFFE5E6E8),
      transitionType: ContainerTransitionType.fade,
      transitionDuration: const Duration(milliseconds: 250),
      closedBuilder: (_, VoidCallback openContainer) {
        return InkWell(onTap: openContainer, child: child);
      },
      openBuilder: (_, __) => ProductDetailScreen2(id),
    );
  }
}
