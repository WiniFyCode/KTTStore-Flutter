// order_confirm_page.dart
import 'package:clothes_store/core/app_color.dart';
import 'package:clothes_store/core/app_data.dart';
import 'package:clothes_store/src/controller/CouponController.dart';
import 'package:clothes_store/src/controller/address_controller.dart';
import 'package:clothes_store/src/controller/order_controller.dart';
import 'package:clothes_store/src/controller/user_controller.dart';
import 'package:clothes_store/src/model/ADDRESS_MODEL.dart';
import 'package:clothes_store/src/model/CART_MODEL.dart';
import 'package:clothes_store/src/model/COUPON_PAGINATION_MODEL.dart';
import 'package:clothes_store/src/model/MINI_PRODUCT_MODEL.dart';
import 'package:clothes_store/src/view/screen/coupon_list_screen.dart';
import 'package:clothes_store/src/view/screen/order_successfully_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

final OrderController orderController = OrderController();
final AddressController addressController = AddressController();
final CouponController couponController = CouponController();

class OrderConfirmPage extends StatefulWidget {
  final List<CART_MODEL> cartItems;
  final double totalPrice;

  const OrderConfirmPage({
    Key? key,
    required this.cartItems,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<OrderConfirmPage> createState() => _OrderConfirmPageState();
}

class _OrderConfirmPageState extends State<OrderConfirmPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  // Payment info
  String _selectedPaymentMethod = 'COD';
  String? _selectedBank;
  final _bankAccountController = TextEditingController();
  double paymentPrice = 0;

  // Address & Coupon
  List<ADDRESS_MODEL> _addresses = [];
  ADDRESS_MODEL? _selectedAddress;
  bool _useNewAddress = false;

  List<UserCoupons> _coupons = [];
  UserCoupons? _selectedCoupon;
  bool _isLoading = false;

  double priceAfterDiscountCalculate(double oldPrice, int categoryID) {
    // Nếu không có coupon được chọn, trả về giá gốc
    if (_selectedCoupon == null || _selectedCoupon!.couponInfo == null) {
      return oldPrice;
    }

    // Tính tổng giá trị đơn hàng và tổng giảm giá dự kiến
    double totalOrderValue = 0;
    double totalExpectedDiscount = 0;

    for (var item in widget.cartItems) {
      double itemTotal = (item.product?.price ?? 0) * (item.quantity ?? 1);
      totalOrderValue += itemTotal;

      bool itemApplicable = _selectedCoupon!.couponInfo!.appliedCategories!
          .any((category) => category.categoryID == item.product?.categoryID);

      if (itemApplicable) {
        if (_selectedCoupon!.couponInfo!.discountType == 'percentage') {
          totalExpectedDiscount += (itemTotal * _selectedCoupon!.couponInfo!.discountValue!) / 100;
        } else {
          totalExpectedDiscount += _selectedCoupon!.couponInfo!.discountValue!.toDouble();
        }
      }
    }

    // Tính tỷ lệ giảm giá thực tế sau khi áp dụng maxDiscountAmount
    double discountRate = 1.0;
    double maxDiscountAmount = _selectedCoupon!.couponInfo!.maxDiscountAmount?.toDouble() ?? double.infinity;

    if (totalExpectedDiscount > maxDiscountAmount) {
      discountRate = maxDiscountAmount / totalExpectedDiscount;
    }

    // Kiểm tra sản phẩm hiện tại có được áp dụng không
    bool isApplicable = _selectedCoupon!.couponInfo!.appliedCategories!
        .any((category) => category.categoryID == categoryID);

    if (!isApplicable) {
      return oldPrice;
    }

    // Tính giảm giá cho sản phẩm hiện tại
    double discountAmount = 0;
    if (_selectedCoupon!.couponInfo!.discountType == 'percentage') {
      discountAmount = (oldPrice * _selectedCoupon!.couponInfo!.discountValue!) / 100;
    } else {
      discountAmount = _selectedCoupon!.couponInfo!.discountValue!.toDouble();
      if (discountAmount > oldPrice) {
        discountAmount = oldPrice;
      }
    }

    // Áp dụng tỷ lệ giảm giá thực tế
    discountAmount *= discountRate;

    return oldPrice - discountAmount;
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadAddresses();
    _loadCoupons();
    setState(() {
      paymentPrice = widget.totalPrice;
    });
    _calculatePaymentPrice(); // Thêm dòng này
  }

  void _calculatePaymentPrice() {
    double total = 0;
    for (var item in widget.cartItems) {
      double originalPrice = 0;
      if(item.product!.discountPrice!= null && item.product!.discountPrice! > 0){
        originalPrice = item.product?.discountPrice ?? 0;
      }
      else{
        originalPrice = item.product?.price ?? 0;
      }
      double discountedPrice = priceAfterDiscountCalculate(
        originalPrice,
        item.product?.categoryID ?? 0,
      );
      total += discountedPrice * (item.quantity ?? 1);
    }
    setState(() {
      paymentPrice = total;
    });
  }

  void _loadUserInfo() {
    final user = AppData.userInfo;
    if (user != null) {
      _nameController.text = user.fullname ?? '';
      _phoneController.text = user.phone ?? '';
      _emailController.text = user.email ?? '';
    }
  }

  Future<void> _loadAddresses() async {
    try {
      final addresses = await AddressController().getAddresses();
      setState(() {
        _addresses = addresses!.where((addr) => !addr.isDelete!).toList();

        // Tìm địa chỉ mặc định
        var defaultAddress = _addresses.where((addr) => addr.isDefault!).toList();
        if (defaultAddress.isNotEmpty) {
          _selectedAddress = defaultAddress.first;
        } else if (_addresses.isNotEmpty) {
          _selectedAddress = _addresses.first;
        }

        // Cập nhật text controller nếu có địa chỉ được chọn
        if (_selectedAddress != null) {
          _addressController.text = _selectedAddress!.address!;
        }
      });
    } catch (e) {
      print('Error loading addresses: $e');
    }
  }

  Future<void> _loadCoupons() async {
    try {
      final coupons = await couponController.getUserCoupons(0);
      if(coupons!=null){
        setState(() {
          _coupons = coupons!.userCoupons!;
        });
      }
      else{
        print("coupons is null");
        setState(() {
          _coupons = [];
        });
      }

    } catch (e) {
      print('Error loading coupons: $e');
    }
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) return;

    print("cart items có  ${widget.cartItems.length} sản phẩm");

    List<MINI_PRODUCT_MODEL> items = [];
    widget.cartItems.forEach((item) {
      double originalPrice = item.product?.price ?? 0;
      double discountedPrice = priceAfterDiscountCalculate(originalPrice, item.product?.categoryID ?? 0,);

      items.add(MINI_PRODUCT_MODEL(
        sKU: item.SKU,
        quantity: item.quantity,
        price: discountedPrice, // Sử dụng giá đã giảm
      ));
    });

    final success = await orderController.createOrder(
      fullname: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      address: _useNewAddress ? _addressController.text : _selectedAddress!.address!,
      note: _noteController.text,
      paymentMethod: _selectedPaymentMethod,
      selectedBank: _selectedBank,
      bankAccountNumber: _bankAccountController.text,
      items: items,
      totalPrice: widget.totalPrice,
      // totalPrice: paymentPrice,
      userCouponsID: _selectedCoupon?.userCouponsID,
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OrderSuccessfullyPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt hàng thất bại. Vui lòng thử lại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Xác nhận đơn hàng',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  // Thông tin người nhận
                  _buildSection(
                    title: 'Thông tin người nhận',
                    icon: FontAwesomeIcons.user,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Họ tên',
                          prefixIcon: FontAwesomeIcons.user,
                          validator: (value) => value?.isEmpty ?? true ? 'Vui lòng nhập họ tên' : null,
                        ),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Số điện thoại',
                          prefixIcon: FontAwesomeIcons.phone,
                          validator: (value) => value?.isEmpty ?? true ? 'Vui lòng nhập số điện thoại' : null,
                        ),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          prefixIcon: FontAwesomeIcons.envelope,
                          validator: (value) => value?.isEmpty ?? true ? 'Vui lòng nhập email' : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Địa chỉ giao hàng
                  _buildSection(
                    title: 'Địa chỉ giao hàng',
                    icon: FontAwesomeIcons.locationDot,
                    child: Column(
                      children: [
                        if (_addresses.isNotEmpty) ...[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonFormField<ADDRESS_MODEL>(
                              value: _selectedAddress,
                              isExpanded: true,
                              isDense: false,
                              items: _addresses.map((addr) => DropdownMenuItem<ADDRESS_MODEL>(
                                value: addr,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: addr.isDefault == true
                                                  ? Colors.green.withOpacity(0.1)
                                                  : Colors.grey[100],
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              addr.isDefault == true ? "Mặc định" : "Địa chỉ ${addr.addressID}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: addr.isDefault == true
                                                    ? Colors.green
                                                    : Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              addr.address ?? "",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )).toList(),
                              onChanged: _useNewAddress ? null : (addr) {
                                setState(() {
                                  _selectedAddress = addr;
                                  if (addr != null) {
                                    _addressController.text = addr.address ?? "";
                                  }
                                });
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                prefixIcon: Icon(
                                  FontAwesomeIcons.locationDot,
                                  color: AppColor.darkOrange,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CheckboxListTile(
                              title: const Text(
                                'Sử dụng địa chỉ mới',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              value: _useNewAddress,
                              activeColor: AppColor.darkOrange,
                              onChanged: (value) {
                                setState(() {
                                  _useNewAddress = value ?? false;
                                  if (!_useNewAddress && _selectedAddress != null) {
                                    _addressController.text = _selectedAddress!.address ?? "";
                                  }
                                });
                              },
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (_useNewAddress || _addresses.isEmpty)
                          _buildTextField(
                            controller: _addressController,
                            label: 'Địa chỉ mới',
                            prefixIcon: FontAwesomeIcons.locationDot,
                            validator: (value) => value?.isEmpty ?? true ? 'Vui lòng nhập địa chỉ' : null,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Mã giảm giá
                  if (_coupons.isNotEmpty)
                    _buildSection(
                      title: 'Mã giảm giá',
                      icon: FontAwesomeIcons.ticket,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<UserCoupons>(
                          value: _selectedCoupon,
                          isExpanded: true,
                          isDense: false,
                          items: _coupons.map((coupon) => DropdownMenuItem<UserCoupons>(
                            value: coupon,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColor.darkOrange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          coupon.couponInfo!.code ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.darkOrange,
                                          ),
                                        ),
                                      ),
                                      if (coupon.couponInfo!.maxDiscountAmount != null) ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Giảm tối đa ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(coupon.couponInfo!.maxDiscountAmount)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )).toList(),
                          onChanged: (coupon) {
                            setState(() {
                              _selectedCoupon = coupon;
                              _calculatePaymentPrice();
                            });
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            prefixIcon: Icon(
                              FontAwesomeIcons.ticket,
                              color: AppColor.darkOrange,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Phương thức thanh toán
                  _buildSection(
                    title: 'Phương thức thanh toán',
                    icon: FontAwesomeIcons.creditCard,
                    child: Column(
                      children: [
                        _buildPaymentMethod(
                          title: 'Thanh toán khi nhận hàng',
                          value: 'COD',
                          icon: FontAwesomeIcons.moneyBill,
                        ),
                        _buildPaymentMethod(
                          title: 'Chuyển khoản ngân hàng',
                          value: 'banking',
                          icon: FontAwesomeIcons.buildingColumns,
                        ),
                        if (_selectedPaymentMethod == 'banking') ...[
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedBank,
                              isExpanded: true,
                              items: AppData.banks.map((bank) =>
                                  DropdownMenuItem(
                                    value: bank.name,
                                    child: Text(bank.name),
                                  )
                              ).toList(),
                              onChanged: (value) {
                                setState(() => _selectedBank = value);
                              },
                              decoration: InputDecoration(
                                labelText: 'Chọn ngân hàng',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                prefixIcon: Icon(
                                  FontAwesomeIcons.buildingColumns,
                                  color: AppColor.darkOrange,
                                  size: 20,
                                ),
                              ),
                              validator: (value) => value == null ? 'Vui lòng chọn ngân hàng' : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _bankAccountController,
                            label: 'Số tài khoản',
                            prefixIcon: FontAwesomeIcons.creditCard,
                            validator: (value) => _selectedPaymentMethod == 'banking' && (value?.isEmpty ?? true)
                                ? 'Vui lòng nhập số tài khoản'
                                : null,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Ghi chú
                  _buildSection(
                    title: 'Ghi chú',
                    icon: FontAwesomeIcons.noteSticky,
                    child: _buildTextField(
                      controller: _noteController,
                      label: 'Ghi chú cho đơn hàng',
                      prefixIcon: FontAwesomeIcons.pen,
                      maxLines: 3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Danh sách sản phẩm
                  _buildSection(
                    title: 'Danh sách sản phẩm',
                    icon: FontAwesomeIcons.cartShopping,
                    child: Column(
                      children: widget.cartItems.map((item) => _buildProductCard(item)).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tổng tiền
                  _buildSection(
                    title: 'Tổng thanh toán',
                    icon: FontAwesomeIcons.moneyBill,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tổng tiền gốc:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(widget.totalPrice),
                              style: TextStyle(
                                fontSize: 16,
                                decoration: paymentPrice < widget.totalPrice ? TextDecoration.lineThrough : null,
                                color: paymentPrice < widget.totalPrice ? Colors.grey : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        if (paymentPrice < widget.totalPrice) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tổng tiền sau giảm:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(paymentPrice),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tiết kiệm:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(widget.totalPrice - paymentPrice),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // Nút đặt hàng
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.darkOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Xác nhận đặt hàng',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColor.darkOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          prefixIcon: Icon(
            prefixIcon,
            color: AppColor.darkOrange,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: _selectedPaymentMethod == value
              ? AppColor.darkOrange
              : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RadioListTile(
        title: Row(
          children: [
            Icon(
              icon,
              color: _selectedPaymentMethod == value
                  ? AppColor.darkOrange
                  : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: _selectedPaymentMethod == value
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
        value: value,
        groupValue: _selectedPaymentMethod,
        onChanged: (value) {
          setState(() {
            _selectedPaymentMethod = value.toString();
            if (_selectedPaymentMethod != 'banking') {
              _selectedBank = null;
              _bankAccountController.clear();
            }
          });
        },
        activeColor: AppColor.darkOrange,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildProductCard(CART_MODEL item) {
    double originalPrice = item.product?.discountPrice ?? 0;
    double discountedPrice = priceAfterDiscountCalculate(
      originalPrice,
      item.product?.categoryID ?? 0,
    );
    item.product!.discountedPriceByCoupon = discountedPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product?.thumbnail ?? '',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.name ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Màu: ${item.colorName ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Size: ${item.size ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (discountedPrice < originalPrice) ...[
                  Text(
                    'Giá gốc: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(originalPrice)}',
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Giá sau giảm: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(discountedPrice)}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ] else
                  Text(
                    'Giá: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(originalPrice)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Số lượng: ${item.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Tổng: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(item.quantity! * discountedPrice)}",
                      style: TextStyle(
                        color: discountedPrice == item.product!.price
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }
}

