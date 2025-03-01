import 'package:clothes_store/src/controller/cart_controller.dart';
import 'package:clothes_store/src/model/CART_MODEL.dart';
import 'package:clothes_store/src/view/screen/order_confirm_screen.dart';
import 'package:clothes_store/src/view/screen/product_detail_screen2.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:clothes_store/core/extensions.dart';
import 'package:clothes_store/src/model/product.dart';
import 'package:clothes_store/src/view/widget/empty_cart.dart';
import 'package:clothes_store/src/controller/product_controller.dart';
import 'package:clothes_store/src/view/animation/animated_switcher_wrapper.dart';
import 'package:intl/intl.dart';
import 'package:clothes_store/core/app_color.dart';

// final ProductController controller = Get.put(ProductController());
final CartController cartController = Get.put(CartController());

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CART_MODEL>? items;
  bool isLoading = true;
  double totalPrice = 0;
  double selectedTotal = 0;
  List<String> skuList = [];
  List<CART_MODEL> cartItemsToOrder = [];

  void caculateTotalPrice() {
    try {
    totalPrice = 0;
      if (items != null) {
    for (var element in items!) {
          if (element.subtotal != null) {
        totalPrice += element.subtotal!;
          }
        }
      }
      setState(() {});
    } catch (e) {
      print("Lỗi khi tính tổng tiền: $e");
    }
  }

  void calculateSelectedTotal() {
    try {
    double total = 0;
    List<String> skuList_temp = [];
      
      if (items != null) {
    for (var item in items!) {
          if (item.isSelected == true && item.subtotal != null) {
        total += item.subtotal!;
            if (item.SKU != null) {
        skuList_temp.add(item.SKU!);
      }
    }
        }
      }

    setState(() {
      selectedTotal = total;
      skuList = skuList_temp;
    });
    } catch (e) {
      print("Lỗi khi tính tổng tiền đã chọn: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      setState(() {
        isLoading = true;
        items = [];
      });

      final cartItems = await cartController.fetchCarts();
      
      if (cartItems != null && cartItems.isNotEmpty) {
        setState(() {
          items = cartItems;
          isLoading = false;
        });

        // Tính tổng tiền sau khi đã có items hợp lệ
          caculateTotalPrice();
        calculateSelectedTotal();

        print('Số lượng sản phẩm hợp lệ: ${cartItems.length}');
      } else {
        setState(() {
          items = [];
          isLoading = false;
        });
        if (mounted) {
          showSnackBar(context, "Giỏ hàng trống", Colors.orange);
        }
      }
    } catch (e) {
      print("Lỗi khi tải giỏ hàng:");
      print(e);
      setState(() {
        items = [];
        isLoading = false;
      });
      if (mounted) {
        showSnackBar(
          context, 
          "Có lỗi xảy ra khi tải giỏ hàng. Vui lòng thử lại sau", 
          Colors.red
        );
      }
    }
  }

  Future<int?> fetchStock(String sku) async {
    try {
      final data = await productController2.getStockBySKU(sku);
      if (data != null) {
        int productStock = 0;
        setState(() {
          productStock = data.stock!;
        });
        return productStock;
      } else {
        print("data stock bị null");
        return null;
      }
    } catch (e) {
      print("error tại fetch stock:");
      print(e);
      return null;
    }
  }

  Future<void> updateQuantity(int id, int quantity) async {
    try {
      final data = await cartController.updateQuantity(id, quantity);
      if (data != null) {
        print("thay đổi số lượng trong mongoDB: $data");
      } else {
        print("data stock bị null");
        print("thay đổi số lượng trong mongoDB: $data");
      }
    } catch (e) {
      print("error tại fetch stock:");
      print(e);
    }

  }

  Future<void> deleteProductInCart(int id) async {
    try {
      final data = await cartController.deleteFromCart(id);
      if (data != null) {
        showSnackBar(context, data, Colors.green);
      } else {
        print("data delete product bị null");
        showSnackBar(context, "Xóa sản phẩm thất bại", Colors.red);
      }
    } catch (e) {
      print("error tại fetch stock:");
      print(e);
      showSnackBar(context, "Xóa sản phẩm thất bại", Colors.red);
    }

  }

  String convertToVNCurrency(double price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(price);
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      title: const Text(
        "Giỏ hàng của tôi",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
    );
  }

  Widget cartList() {
    return ListView.builder(
          itemCount: items!.length,
      padding: const EdgeInsets.all(16),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            CART_MODEL item = items![index];
            return Container(
              width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
                    child: Column(
                      children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox
                        Transform.scale(
                      scale: 1,
                          child: Checkbox(
                        value: item.isSelected ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                item.isSelected = value ?? false;
                                calculateSelectedTotal();
                              });
                            },
                        activeColor: AppColor.darkOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                    const SizedBox(width: 8),
                    // Ảnh sản phẩm
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.product!.thumbnail!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Thông tin sản phẩm
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product!.name!,
                            maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                              fontSize: 16,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Text(
                                  'Size: ${item.size!}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Text(
                                  'Màu: ${item.colorName ?? ''}',
                          style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        Text(
                            convertToVNCurrency(item.subtotal!),
                          style: const TextStyle(
                              color: AppColor.darkOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                          ),
                        ),
                      ],
                    ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                    // Nút xóa
                    Material(
                      color: Colors.transparent,
                                child: InkWell(
                        onTap: () async {
                                    setState(() {
                                      items!.removeAt(index);
                                      caculateTotalPrice();
                                      calculateSelectedTotal();
                                    });
                                    await deleteProductInCart(item.cartID!);
                                  },
                        borderRadius: BorderRadius.circular(12),
                                    child: Container(
                          padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red[700], size: 20),
                              const SizedBox(width: 4),
                              Text(
                                'Xóa',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Số lượng
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    if (item.quantity! > 1) {
                                      setState(() {
                                        item.quantity = item.quantity! - 1;
                                        item.subtotal = item.quantity! * item.product!.discountPrice!;
                                        caculateTotalPrice();
                                        calculateSelectedTotal();
                                      });
                                      showSnackBar(context, 'Đã cập nhật số lượng thành công', Colors.green);
                                      await updateQuantity(item.cartID!, item.quantity!);
                                    } else {
                                      setState(() {
                                        items!.removeAt(index);
                                        caculateTotalPrice();
                                      });
                                      await deleteProductInCart(item.cartID!);
                                    }
                                  },
                            icon: const Icon(Icons.remove, color: AppColor.darkOrange),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                ),
                                IconButton(
                                  onPressed: () async {
                              int? currentStock = await fetchStock(item.SKU!);
                              if (currentStock != null && currentStock != 0 && item.quantity! < currentStock) {
                                      setState(() {
                                        item.quantity = item.quantity! + 1;
                                        item.subtotal = item.quantity! * item.product!.discountPrice!;
                                        print("Thay đổi item sku: ${item.SKU}");
                                        print("discount price: ${item.product!.discountPrice!}");
                                        print("subtotal: ${item.subtotal!}");
                                        caculateTotalPrice();
                                        calculateSelectedTotal();
                                      });
                                      showSnackBar(context, 'Đã cập nhật số lượng thành công', Colors.green);
                                      await updateQuantity(item.cartID!, item.quantity!);
                              } else {
                                      showSnackBar(context, 'Sản phẩm đã đạt tối đa', Colors.red);
                                    }
                                  },
                            icon: const Icon(Icons.add, color: AppColor.darkOrange),
                                ),
                              ],
                            ),
                          ),
                        ],
                ),
              ),
            ],
              ),
            );
          },
    );
  }

  Widget bottomBarTitle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
                "Tổng thanh toán",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
          ),
          AnimatedSwitcherWrapper(
            child: Text(
                  convertToVNCurrency(selectedTotal),
              key: ValueKey<double>(selectedTotal),
              style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
      width: double.infinity,
        child: ElevatedButton(
          onPressed: items!.isEmpty ? null : () {
                if (skuList.isEmpty) {
              showSnackBar(context, "Vui lòng chọn sản phẩm", Colors.red);
                } else {
              cartItemsToOrder = items!.where((e) => e.isSelected).toList();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OrderConfirmPage(
                          cartItems: cartItemsToOrder,
                        totalPrice: selectedTotal,
                      ),
                    ),
              );
            }
          },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.darkOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Mua ngay",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      itemCount: 3,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox skeleton
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Image skeleton
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Content skeleton
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title skeleton
                          Container(
                            width: double.infinity,
                            height: 16,
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            width: double.infinity * 0.7,
                            height: 16,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          // Size and color skeleton
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 80,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Price skeleton
                          Container(
                            width: 100,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom actions skeleton
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Delete button skeleton
                    Container(
                      width: 80,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // Quantity controls skeleton
                    Container(
                      width: 120,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: _appBar(context),
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
        child: isLoading 
          ? Stack(
          children: [
                _buildLoadingSkeleton(),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 120,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Container(
                              width: 150,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                ],
              ),
            ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: items!.isNotEmpty ? cartList() : const EmptyCart(),
                ),
                if (items!.isNotEmpty) bottomBarTitle(),
              ],
            ),
      ),
    );
  }
}

showSnackBar(context, String message, Color mau) {
  return (ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: mau,
    duration: Durations.extralong4,
  )));
}
