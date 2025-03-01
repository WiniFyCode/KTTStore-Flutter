import 'package:carousel_slider/carousel_options.dart';
import 'package:clothes_store/src/controller/cart_controller.dart';
import 'package:clothes_store/src/controller/favorite_controller.dart';
import 'package:clothes_store/src/controller/product_controller2.dart';
import 'package:clothes_store/src/model/PRODUCT_MODEL.dart';
import 'package:clothes_store/src/view/screen/customer_reviews_screen.dart';
import 'package:clothes_store/src/view/widget/product_grid_view2.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:clothes_store/core/app_color.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:clothes_store/src/view/widget/carousel_slider.dart';
import 'package:clothes_store/src/controller/product_controller.dart';
import 'package:intl/intl.dart';

final ProductController2 controller = Get.put(ProductController2());
final FavoriteController favoriteController = Get.put(FavoriteController());
final CartController cartController = Get.put(CartController());

class ProductDetailScreen extends StatefulWidget {
  // final Product product;
  final PRODUCT_MODEL product;

  const ProductDetailScreen(this.product, {super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String loi = "";

  int colorChoosingIndex = 0;
  int sizeChoosingIndex = 0; // 0 là S, 1 là M, 2 là L
  late int productStock;
  bool isLoadingRelatedProducts = true;
  bool _isExpandedDescription = false;

  int quantity = 1;

  List<PRODUCT_MODEL> relatedProducts = [];

  void incrementQuantity() {
    print("stock: $productStock");
    if(quantity < productStock) {
      setState(() {
      quantity++;
    });
    }
  }

  void decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  Future<void> addToCart() async {
    print('id: ${widget.product.productID}');
    print('colorChoosingIndex: $colorChoosingIndex');
    print('sizeChoosingIndex: $sizeChoosingIndex');
    String maSKU = widget.product.colors![colorChoosingIndex].sizes![sizeChoosingIndex].sKU!;
    print("maSKU = $maSKU");
    try {
      final data = await cartController.addToCart(maSKU, quantity);

        if(data.statusCode==201){
          showSnackBar(context, 'Thêm vào giỏ hàng thành công', Colors.green);
        }else{
          showSnackBar(context, data.messager, Colors.red);
        }

    } on Exception catch (e) {
      print("error tại fetch add to favorite:");
      print(e);
    }
  }

  Future<void> addToFavorite() async {
    print('id: ${widget.product.productID}');
    print('colorChoosingIndex: $colorChoosingIndex');
    print('sizeChoosingIndex: $sizeChoosingIndex');
    String maSKU = widget.product.colors![colorChoosingIndex].sizes![sizeChoosingIndex].sKU!;
    print("maSKU = $maSKU");
    try {
      final data = await favoriteController.addToFavorites(maSKU, "Đ");

      // Hiển thị thông báo từ server với màu phù hợp
      showSnackBar(
        context, 
        data.messager ?? 'Có lỗi xảy ra', 
        data.statusCode == 201 ? Colors.green : Colors.orange
      );

    } on Exception catch (e) {
      print("error tại fetch add to favorite:");
      print(e);
      showSnackBar(context, 'Có lỗi xảy ra khi thêm vào yêu thích', Colors.red);
    }
  }

  Future<void> getRelatedProducts() async {
    try {
      final data = await controller.getRelatedProducts(widget.product.categoryID, widget.product.targetID);

      if(data?.products != null && data != null){
        print("length: ${data.products?.length}");
        setState(() {
          relatedProducts = data.products!;
          isLoadingRelatedProducts = false;
        });
      }else{
        print("lỗi null khi lấy related product");
      }

    } on Exception catch (e) {
      print("error tại fetch add to favorite:");
      print(e);
    }
  }


  @override
  void initState() {
    super.initState();
    print("đang xem sản phẩm id = ${widget.product.productID}");
    if (widget.product.colors!.isEmpty ||
        widget.product.colors![0].sizes!.isEmpty||
        widget.product.colors == null ||
        widget.product.colors?[0].sizes == null) {
      loi += "Sản phẩm không có màu hoặc kích thước";
    } else {
      productStock = widget.product.colors![0].sizes![0].stock!;
    }
    getRelatedProducts();
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.black),
      ),
    );
  }

  Widget productPageView(double width, double height) {
    return Container(
      height: height * 0.45,
      width: width,
      decoration: const BoxDecoration(
        color: Color(0xFFE5E6E8),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(200),
          bottomLeft: Radius.circular(200),
        ),
      ),
      child: CarouselSlider(
          items: widget.product.colors![colorChoosingIndex].images!,

        ),
    );
  }

  Widget _ratingBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              RatingBar.builder(
                initialRating: 4.0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 20,
                ignoreGestures: true,
                itemBuilder: (_, __) => const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                ),
                onRatingUpdate: (_) {},
              ),
              const SizedBox(width: 8),
              Text(
                "4.0",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "(99+ đánh giá)",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (widget.product.promotion != null && widget.product.promotion!.discountedPrice! > 0 ?
                NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(widget.product.promotion!.discountedPrice!) :
                NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(widget.product.price)),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkOrange,
                  fontSize: 18
                ),
              ),
              const SizedBox(height: 4),
              Text(
                (widget.product.promotion != null && widget.product.promotion!.discountedPrice! > 0 ? NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(widget.product.price) : ""),
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey[500],
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: productStock > 0 ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: productStock > 0 ? Colors.green[200]! : Colors.red[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  productStock > 0 ? Icons.check_circle : Icons.error,
                  size: 16,
                  color: productStock > 0 ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  productStock > 0 ? "Còn $productStock sản phẩm" : "Hết hàng",
                  style: TextStyle(
                    color: productStock > 0 ? Colors.green : Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove_circle_outline, color: Colors.grey[700]),
            onPressed: decrementQuantity,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.grey[700]),
            onPressed: incrementQuantity,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              await addToFavorite();
            },
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            label: const Text("Yêu thích", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              await addToCart();
            },
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text("Thêm vào giỏ"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.darkOrange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget productColorsListView() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.product.colors!.length,
      itemBuilder: (_, index) {
        return InkWell(
          onTap: () {
            setState(() {
              colorChoosingIndex = index;
              productStock = widget
                  .product.colors![index].sizes![sizeChoosingIndex].stock!;
            });
          },
          // onTap: () => controller.switchBetweenProductSizes(product, index),
          child: AnimatedContainer(
            margin: const EdgeInsets.only(right: 5, left: 5),
            alignment: Alignment.center,
            // width: controller.isNominal(product) ? 40 : 70,
            width: 40,
            decoration: BoxDecoration(
              color: colorChoosingIndex != index
                  ? Colors.white
                  : AppColor.lightOrange,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
                width: 0.4,
              ),
            ),
            duration: const Duration(milliseconds: 300),
            child: FittedBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  //controller.sizeType(product)[index].numerical,
                  widget.product.colors![index].colorName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget productSizesListView(int colorIndex) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.product.colors![colorIndex].sizes!.length,
      itemBuilder: (_, index) {
        return InkWell(
          onTap: () {
            setState(() {
              sizeChoosingIndex = index;
              productStock =
                  widget.product.colors![colorIndex].sizes![index].stock!;
            });
          },
          // onTap: () => controller.switchBetweenProductSizes(product, index),
          child: AnimatedContainer(
            margin: const EdgeInsets.only(right: 5, left: 5),
            alignment: Alignment.center,
            // width: controller.isNominal(product) ? 40 : 70,
            width: 40,
            decoration: BoxDecoration(
              color: sizeChoosingIndex != index
                  ? Colors.white
                  : AppColor.lightOrange,
              // color: Colors.white ,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
                width: 0.4,
              ),
            ),
            duration: const Duration(milliseconds: 300),
            child: FittedBox(
              child: Text(
                widget.product.colors![colorIndex].sizes![index].size!,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    print("length: ${relatedProducts.length}");

    if (loi == "") {
      return SafeArea(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _appBar(context),
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    productPageView(width, 850),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name ?? "",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ratingBar(context),
                          const SizedBox(height: 16),
                          _buildPriceSection(context),
                          const SizedBox(height: 24),
                          Text(
                            "Màu sắc",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 40,
                            child: GetBuilder<ProductController>(
                              builder: (_) => productColorsListView(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Kích thước",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 40,
                            child: GetBuilder<ProductController>(
                              builder: (_) => productSizesListView(colorChoosingIndex),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Số lượng",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(child: _buildQuantitySelector()),
                          const SizedBox(height: 24),
                          _buildActionButtons(context),
                          const SizedBox(height: 24),
                          if (widget.product.description != null) ...[
                            Text(
                              "Mô tả sản phẩm",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.product.description!,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                    maxLines: _isExpandedDescription ? null : 3,
                                    overflow: _isExpandedDescription ? null : TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isExpandedDescription = !_isExpandedDescription;
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _isExpandedDescription ? "Thu gọn" : "Xem thêm",
                                          style: TextStyle(
                                            color: AppColor.darkOrange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          _isExpandedDescription 
                                            ? FontAwesomeIcons.chevronUp 
                                            : FontAwesomeIcons.chevronDown,
                                          size: 14,
                                          color: AppColor.darkOrange,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CustomerReviewsScreen(
                                    productID: widget.product.productID!
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColor.darkOrange,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: AppColor.darkOrange),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.rate_review_outlined),
                                SizedBox(width: 8),
                                Text("Xem đánh giá từ khách hàng"),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (relatedProducts.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Sản phẩm liên quan",
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Xử lý xem tất cả
                                  },
                                  child: Text(
                                    "Xem tất cả",
                                    style: TextStyle(
                                      color: AppColor.darkOrange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ProductGridView2(items: relatedProducts),
                          ] else
                            Center(
                              child: Text(
                                "Không có sản phẩm liên quan",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: _appBar(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                loi,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

showSnackBar(context, String message, Color mau){
  return(
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: mau,))
  );
}
