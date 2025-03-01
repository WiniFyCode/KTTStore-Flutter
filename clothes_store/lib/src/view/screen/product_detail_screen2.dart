import 'package:clothes_store/src/controller/cart_controller.dart';
import 'package:clothes_store/src/controller/favorite_controller.dart';
import 'package:clothes_store/src/controller/product_controller2.dart';
import 'package:clothes_store/src/model/PRODUCT_MODEL.dart';
import 'package:clothes_store/src/view/screen/customer_reviews_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:clothes_store/core/app_color.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:clothes_store/src/view/widget/carousel_slider.dart';
import 'package:clothes_store/src/controller/product_controller.dart';
import 'package:intl/intl.dart';

final ProductController2 productController2 = Get.put(ProductController2());
final FavoriteController favoriteController = Get.put(FavoriteController());
final CartController cartController = Get.put(CartController());

class ProductDetailScreen2 extends StatefulWidget {
  final int id;

  const ProductDetailScreen2(this.id, {super.key});

  @override
  State<ProductDetailScreen2> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen2> {
  String loi = "";
  PRODUCT_MODEL? product;

  int colorChoosingIndex = 0;
  int sizeChoosingIndex = 0;
  late int productStock;
  bool isLoading = true;
  bool _isExpandedDescription = false;

  @override
  void initState() {
    super.initState();
    fetchProductById();
  }

  int quantity = 1;

  void incrementQuantity() {
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
    String maSKU = product!.colors![colorChoosingIndex].sizes![sizeChoosingIndex].sKU!;
    try {
      final data = await cartController.addToCart(maSKU, quantity);
      if(data.statusCode==201){
        showSnackBar(context, data.messager, Colors.green);
      }else{
        showSnackBar(context, data.messager, Colors.red);
      }
    } catch (e) {
      print("error tại add to cart:");
      print(e);
      showSnackBar(context, "Có lỗi xảy ra khi thêm vào giỏ hàng", Colors.red);
    }
  }

  Future<void> fetchProductById() async {
    try {
      final data = await productController2.getProductById(widget.id);
      if (data != null) {
        setState(() {
          product = data;
          isLoading = false;
        });

        if (product!.colors!.isEmpty ||
            product!.colors![0].sizes!.isEmpty ||
            product!.colors == null ||
            product!.colors?[0].sizes == null) {
          loi = "Sản phẩm không có màu hoặc kích thước";
        } else {
          productStock = product!.colors![0].sizes![0].stock!;
        }
      }
    } catch (e) {
      print("error tại fetch product by id:");
      print(e);
      setState(() {
        isLoading = false;
        loi = "Có lỗi xảy ra khi tải thông tin sản phẩm";
      });
    }
  }

  Future<void> addToFavorite() async {
    String maSKU = product!.colors![colorChoosingIndex].sizes![sizeChoosingIndex].sKU!;
    try {
      final data = await favoriteController.addToFavorites(maSKU, "Đã thêm vào sản phẩm yêu thích");
      if(data.statusCode==201){
        showSnackBar(context, data.messager ?? 'Có lỗi xảy ra', Colors.green);
      }else{
        showSnackBar(context, data.messager ?? 'Có lỗi xảy ra', Colors.red);
      }
    } catch (e) {
      print("error tại add to favorite:");
      print(e);
      showSnackBar(context, "Có lỗi xảy ra khi thêm vào yêu thích", Colors.red);
    }
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

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          Container(
            height: MediaQuery.of(context).size.height * 0.43,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(200),
                bottomLeft: Radius.circular(200),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                Container(
                  width: double.infinity,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                // Rating skeleton
                Row(
                  children: [
                    Container(
                      width: 120,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 80,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Price and stock skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 150,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 120,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Colors skeleton
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),
                // Sizes skeleton
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),
                // Quantity skeleton
                Center(
                  child: Container(
                    width: 150,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Action buttons skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
          items: product!.colors![colorChoosingIndex].images!),
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
                (product!.promotion != null && product!.promotion!.discountedPrice! > 0 ?
                NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(product!.promotion!.discountedPrice!) :
                NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(product!.price)),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkOrange,
                    fontSize: 18
                ),
              ),
              const SizedBox(height: 4),
              Text(
                (product!.promotion != null && product!.promotion!.discountedPrice! > 0 ? NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(product!.price) : ""),
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
      itemCount: product!.colors!.length,
      itemBuilder: (_, index) {
        return InkWell(
          onTap: () {
            setState(() {
              colorChoosingIndex = index;
              productStock = product!.colors![index].sizes![sizeChoosingIndex].stock!;
            });
          },
          child: AnimatedContainer(
            margin: const EdgeInsets.only(right: 5, left: 5),
            alignment: Alignment.center,
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
                  product!.colors![index].colorName!,
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
      itemCount: product!.colors![colorIndex].sizes!.length,
      itemBuilder: (_, index) {
        return InkWell(
          onTap: () {
            setState(() {
              sizeChoosingIndex = index;
              productStock = product!.colors![colorIndex].sizes![index].stock!;
            });
          },
          child: AnimatedContainer(
            margin: const EdgeInsets.only(right: 5, left: 5),
            alignment: Alignment.center,
            width: 40,
            decoration: BoxDecoration(
              color: sizeChoosingIndex != index
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
              child: Text(
                product!.colors![colorIndex].sizes![index].size!,
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

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _appBar(context),
        body: isLoading 
          ? _buildLoadingSkeleton()
          : loi.isEmpty && product != null
            ? SingleChildScrollView(
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
                                product!.name ?? "",
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
                              if (product!.description != null) ...[
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
                                        product!.description!,
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
                                        productID: product!.productID!
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
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            : Center(
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
