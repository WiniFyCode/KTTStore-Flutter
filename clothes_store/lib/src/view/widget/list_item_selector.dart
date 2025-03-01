import 'package:clothes_store/src/model/CATEGORY_MODEL.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:clothes_store/core/app_color.dart';

class ListItemSelector extends StatefulWidget {
  ListItemSelector({
    super.key,
    required this.categories,
    required this.onItemPressed,
  });

  List<CATEGORY_MODEL> categories;
  final Function(int) onItemPressed;

  bool thereIsASelectedItem() {
    for (var element in categories) {
      if (element.isSelected) {
        return true;
      }
    }
    return false;
  }

  @override
  State<ListItemSelector> createState() => _ListItemSelectorState();
}

class _ListItemSelectorState extends State<ListItemSelector> {
  Widget item(CATEGORY_MODEL item, int index, Size size) {
    // Tính toán kích thước dựa trên màn hình
    final itemWidth = size.width * 0.28; // 28% chiều rộng màn hình
    final itemHeight = size.height * 0.2; // 20% chiều cao màn hình
    final imageSize = itemWidth * 0.9; // 70% chiều rộng của item
    final fontSize = size.width * 0.03; // 3% chiều rộng màn hình cho font size

    return Tooltip(
      message: item.name?.capitalizeFirst,
      child: AnimatedContainer(
        margin: EdgeInsets.only(right: size.width * 0.03), // 3% margin
        duration: const Duration(milliseconds: 500),
        width: itemWidth,
        height: itemHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: item.isSelected ? AppColor.darkOrange : Colors.grey.withOpacity(0.3),
            width: item.isSelected ? 2 : 1,
          ),
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
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              widget.onItemPressed(index);
              for (var element in widget.categories) {
                element.isSelected = false;
              }
              item.isSelected = true;
              setState(() {});
            },
            child: item.name != "ALL" 
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Container hình ảnh
                  Container(
                    width: imageSize,
                    height: imageSize,
                    padding: EdgeInsets.all(size.width * 0.02),
                    decoration: BoxDecoration(
                      color: item.isSelected 
                          ? AppColor.darkOrange.withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.network(
                      item.imageURL ?? 'https://www.google.com.vn/images/branding/googlelogo/1x/googlelogo_light_color_272x92dp.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  // Tên danh mục
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                    child: Text(
                      item.name!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fontSize,
                        height: 1.2,
                        fontWeight: item.isSelected ? FontWeight.bold : FontWeight.normal,
                        color: item.isSelected ? AppColor.darkOrange : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: item.isSelected
                        ? [AppColor.darkOrange, AppColor.darkOrange.withOpacity(0.8)]
                        : [Colors.grey[300]!, Colors.grey[200]!],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  "TẤT CẢ",
                  style: TextStyle(
                    fontSize: fontSize * 1.2,
                    fontWeight: FontWeight.bold,
                    color: item.isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final size = MediaQuery.of(context).size;
    final height = size.height * 0.22; // 22% chiều cao màn hình

    return Container(
      height: height,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.01,
          horizontal: size.width * 0.02,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        itemBuilder: (_, index) => item(widget.categories[index], index, size),
      ),
    );
  }
}
