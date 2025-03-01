import 'package:clothes_store/src/model/PRODUCT_MODEL.dart';
import 'package:flutter/material.dart';
import 'package:clothes_store/src/view/animation/open_container_wrapper.dart';
import 'package:intl/intl.dart';
import 'package:clothes_store/core/app_color.dart';

class ProductGridView2 extends StatelessWidget {
  ProductGridView2({
    super.key,
    required this.items,
  });

  final List<PRODUCT_MODEL> items;

  Widget _buildProductCard(PRODUCT_MODEL product, BuildContext context) {
    String originalPrice = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(product.price);
    String? discountedPrice;
    
    if (product.promotion != null && product.promotion!.discountedPrice != null && product.promotion!.discountedPrice! > 0) {
      discountedPrice = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ')
          .format(product.promotion!.discountedPrice!);
    }

    return OpenContainerWrapper(
      product: product,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần ảnh sản phẩm
            Stack(
              children: [
                // Ảnh sản phẩm
                Container(
                  height: 180,
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.colors?.isNotEmpty == true && 
                      product.colors![0].images?.isNotEmpty == true ? 
                      product.colors![0].images![0] : 
                      product.thumbnail ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey[400],
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Tag giảm giá
                if (product.promotion != null && product.promotion!.discountPercent != null && product.promotion!.discountedPrice!=null && product.promotion!.discountedPrice!>0)
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColor.darkOrange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '-${product.promotion!.discountPercent}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                // Overlay hết hàng
                if (product.totalStock == 0)
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Hết hàng',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Phần thông tin sản phẩm
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên sản phẩm
                    Text(
                      product.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                        fontSize: 15,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Danh mục và đối tượng
                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${product.category ?? ''} • ${product.target ?? ''}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Giá
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (product.promotion != null && discountedPrice != null) ...[
                          Text(
                            discountedPrice,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColor.darkOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            originalPrice,
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ] else
                          Text(
                            originalPrice,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(items.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: GridView.builder(
          itemCount: items.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 0.50,
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
          ),
          itemBuilder: (context, index) => _buildProductCard(items[index], context),
        ),
      );
    } else return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không có sản phẩm',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
