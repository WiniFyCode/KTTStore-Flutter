import 'package:clothes_store/core/app_color.dart';
import 'package:clothes_store/src/model/COUPON_PAGINATION_MODEL.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class CouponDetailScreen extends StatelessWidget {
  final UserCoupons coupon;

  const CouponDetailScreen({super.key, required this.coupon});

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatCurrency(int? amount) {
    if (amount == null) return 'N/A';
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');
    return formatter.format(amount);
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'trạng thái':
        return FontAwesomeIcons.circleInfo;
      case 'số lần sử dụng còn lại':
        return FontAwesomeIcons.repeat;
      case 'giảm giá':
        return FontAwesomeIcons.percent;
      case 'đơn hàng tối thiểu':
        return FontAwesomeIcons.cartShopping;
      case 'giảm tối đa':
        return FontAwesomeIcons.moneyBill;
      case 'thời gian hiệu lực':
        return FontAwesomeIcons.calendarDays;
      case 'hạn sử dụng':
        return FontAwesomeIcons.clock;
      case 'số sản phẩm tối thiểu':
        return FontAwesomeIcons.boxOpen;
      case 'áp dụng cho':
        return FontAwesomeIcons.tags;
      default:
        return FontAwesomeIcons.circle;
    }
  }

  String _getStatusText(String status) {
    // Kiểm tra trạng thái của mã giảm giá và trả về văn bản tương ứng
    switch (status.toLowerCase()) {
      case 'active':
        return 'Có thể sử dụng';
      case 'used':
        return 'Đã sử dụng';
      case 'expired':
        return 'Hết hạn';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Trạng thái không hợp lệ';
    }
  }

  @override
  Widget build(BuildContext context) {
    String mathang = coupon.couponInfo?.appliedCategories
            ?.map((category) => category.name)
            .where((name) => name != null)
            .join(', ') ??
        'Không có';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi tiết mã giảm giá',
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header section with coupon code
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColor.darkOrange.withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.ticket,
                                color: AppColor.darkOrange,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                coupon.couponInfo?.code ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkOrange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: coupon.status == 'active'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              coupon.status == 'active'
                                  ? 'Có thể sử dụng'
                                  : 'Hết hạn',
                              style: TextStyle(
                                color: coupon.status == 'active'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        coupon.couponInfo?.description ?? 'N/A',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Details section
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Thông tin chi tiết',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.darkOrange,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildDetailItem(
                            'Trạng thái',
                            _getStatusText(coupon.status ?? ''),
                          ),
                          _buildDetailItem(
                            'Số lần sử dụng còn lại',
                            '${coupon.usageLeft ?? 0} lần',
                          ),
                          _buildDetailItem(
                            'Giảm giá',
                            '${coupon.couponInfo?.discountValue}${coupon.couponInfo?.discountType == "percentage" ? '%' : 'VNĐ'}',
                          ),
                          _buildDetailItem(
                            'Đơn hàng tối thiểu',
                            _formatCurrency(coupon.couponInfo?.minOrderValue),
                          ),
                          _buildDetailItem(
                            'Giảm tối đa',
                            _formatCurrency(coupon.couponInfo?.maxDiscountAmount),
                          ),
                          _buildDetailItem(
                            'Thời gian hiệu lực',
                            '${_formatDate(coupon.couponInfo?.startDate)} - ${_formatDate(coupon.couponInfo?.endDate)}',
                          ),
                          _buildDetailItem(
                            'Hạn sử dụng',
                            _formatDate(coupon.expiryDate),
                          ),
                          _buildDetailItem(
                            'Số sản phẩm tối thiểu',
                            '${coupon.couponInfo?.minimumQuantity ?? 0} sản phẩm',
                          ),
                          _buildDetailItem(
                            'Áp dụng cho',
                            mathang,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColor.darkOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconForLabel(label),
              color: AppColor.darkOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
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
}