import 'package:clothes_store/core/app_color.dart';
import 'package:flutter/material.dart';
import 'package:clothes_store/src/controller/address_controller.dart';
import 'package:clothes_store/src/model/ADDRESS_MODEL.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final AddressController addressController = AddressController();

class AddressManagementScreen extends StatefulWidget {
  @override
  _AddressManagementScreenState createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  final AddressController addressController = AddressController();
  List<ADDRESS_MODEL>? addresses;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      addresses = await addressController.getAddresses();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading addresses: $e');
      showSnackBar(context, "Lỗi khi tải danh sách địa chỉ", Colors.red);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addOrEditAddress({ADDRESS_MODEL? address}) async {
    final isEditing = address != null;
    final TextEditingController addressController = TextEditingController(text: address?.address ?? '');
    bool isDefault = address?.isDefault ?? false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isEditing ? 'Chỉnh sửa địa chỉ' : 'Thêm địa chỉ mới',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Địa chỉ',
                      prefixIcon: Icon(FontAwesomeIcons.locationDot, color: AppColor.darkOrange, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColor.darkOrange),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CheckboxListTile(
                      title: const Text(
                        'Đặt làm mặc định',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      value: isDefault,
                      activeColor: AppColor.darkOrange,
                      onChanged: (value) {
                        setState(() {
                          isDefault = value!;
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Hủy',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.darkOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      if (isEditing) {
        await _editAddress(address!.addressID!, addressController.text, isDefault);
      } else {
        await _addAddress(addressController.text, isDefault);
      }

      // Nếu địa chỉ được đặt làm mặc định, gọi hàm _setDefaultAddress
      if (isDefault) {
        await _setDefaultAddress(address!.addressID!);
      }
      await _loadAddresses();
    }
  }

  Future<void> _addAddress(String address, bool isDefault) async {
    try {
      final result = await addressController.addAddress(address, isDefault);
      if (result.statusCode == 201) {
        await _loadAddresses();
        showSnackBar(context, "Thêm địa chỉ thành công", Colors.green);
      } else {
        showSnackBar(context, result.message!, Colors.red);
      }
    } catch (e) {
      print('Error adding address: $e');
      showSnackBar(context, "Lỗi khi thêm địa chỉ", Colors.red);
    }
  }

  Future<void> _editAddress(int id, String address, bool isDefault) async {
    try {
      final result = await addressController.updateAddress(id, address, isDefault);
      if (result.statusCode == 200) {
        await _loadAddresses();
        showSnackBar(context, "Cập nhật địa chỉ thành công", Colors.green);
      } else {
        showSnackBar(context, result.message!, Colors.red);
      }
    } catch (e) {
      print('Error editing address: $e');
      showSnackBar(context, "Lỗi khi cập nhật địa chỉ", Colors.red);
    }
  }

  Future<void> _deleteAddress(int id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Xác nhận xóa',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text('Bạn có chắc chắn muốn xóa địa chỉ này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await addressController.deleteAddress(id);
      if (result.statusCode == 200) {
        await _loadAddresses();
        showSnackBar(context, "Xóa địa chỉ thành công", Colors.green);
      } else {
        showSnackBar(context, result.message!, Colors.red);
      }
    }
  }

  Future<void> _setDefaultAddress(int id) async {
    final result = await addressController.setDefaultAddress(id);
    if (result.statusCode == 200) {
      await _loadAddresses();
      showSnackBar(context, "Đặt làm địa chỉ mặc định thành công", Colors.green);
    } else {
      showSnackBar(context, result.message!, Colors.red);
    }
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      itemCount: 3,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
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
      appBar: AppBar(
        title: const Text(
          'Quản lý địa chỉ',
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
        child: isLoading
            ? _buildLoadingSkeleton()
            : addresses == null || addresses!.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.locationDot,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Chưa có địa chỉ nào",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadAddresses,
                    color: AppColor.darkOrange,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: addresses!.length,
                      itemBuilder: (context, index) {
                        final address = addresses![index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
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
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _addOrEditAddress(address: address),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: address.isDefault!
                                            ? AppColor.darkOrange.withOpacity(0.1)
                                            : Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.locationDot,
                                        color: address.isDefault!
                                            ? AppColor.darkOrange
                                            : Colors.grey[400],
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            address.address!,
                                            style: TextStyle(
                                              fontWeight: address.isDefault!
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              fontSize: 16,
                                              color: address.isDefault!
                                                  ? Colors.black
                                                  : Colors.grey[700],
                                            ),
                                          ),
                                          if (address.isDefault!) ...[
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColor.darkOrange.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Mặc định',
                                                style: TextStyle(
                                                  color: AppColor.darkOrange,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (!address.isDefault!)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteAddress(address.addressID!),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditAddress(),
        backgroundColor: AppColor.darkOrange,
        elevation: 2,
        child: const Icon(Icons.add),
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