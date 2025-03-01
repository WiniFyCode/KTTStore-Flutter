import 'package:clothes_store/src/controller/product_controller2.dart';
import 'package:clothes_store/src/model/CATEGORY_MODEL.dart';
import 'package:clothes_store/src/model/PRODUCT_LIST_MODEL.dart';
import 'package:clothes_store/src/model/PRODUCT_MODEL.dart';
import 'package:clothes_store/src/model/recommended_product.dart';
import 'package:clothes_store/src/view/widget/Pagination.dart';
import 'package:clothes_store/src/view/widget/product_grid_view2.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:clothes_store/core/app_data.dart';
import 'package:clothes_store/core/app_color.dart';
import 'package:clothes_store/src/controller/product_controller.dart';
import 'package:clothes_store/src/view/widget/list_item_selector.dart';

ProductController2 productController2 = ProductController2();

enum AppbarActionType { leading, trailing }

final ProductController controller = Get.put(ProductController());

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<CATEGORY_MODEL> categoryList = [];
  PRODUCT_LIST_MODEL? product_list_model;
  List<PRODUCT_MODEL> productList = [];
  bool isLoading = true;
  String errorMessage = '';

  String? sortType = "createAt-desc";
  String? categoryType, searchValue;
  int? targetType;
  int totalPage = -1;
  int currentPage = 1;
  GlobalKey _key = GlobalKey();

  String selectedValue_target = 'All';
  String selectedValue_sort = 'Mới nhất';
  bool isSearching = false;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    fetchDataCategories();
    fetchDataProducst();
    searchController = TextEditingController();
  }

  Future<void> fetchDataCategories() async {
    try {
      final data = await productController2.getCategories();
      if (data.isNotEmpty) {
        setState(() {
          categoryList = data;
          CATEGORY_MODEL allCat = CATEGORY_MODEL(name: "ALL", imageURL: null);
          allCat.isSelected = true;
          categoryList = [allCat, ...categoryList];
          isLoading = false;
        });
      }
    } on Exception catch (e) {
      print("error tại fetch category list:");
      print(e);
    }
  }

  Future<void> fetchDataProducst() async {
    try {
      final data = await productController2.getProducts2(
          currentPage, sortType, categoryType, targetType, searchValue);
      if (data != null) {
        setState(() {
          productList = data.products!;
          totalPage = data.totalPages!;
          currentPage = data.currentPage!;
          isLoading = false;
        });
      }
    } on Exception catch (e) {
      print("error tại fetch product list:");
      print(e);

    }
  }

  void setPageNumber(int newPage) {
    setState(() {
      currentPage = newPage;
    });
    print("đã thay đổi page, currentPage = $currentPage");
    fetchDataProducst();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(_key.currentContext!,
          duration: Duration(milliseconds: 500));
    });
  }

  PreferredSize get _appBar {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Row(
            children: [
              // Logo thương hiệu
              Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  "KTT STORE",
                  style: TextStyle(
                    color: AppColor.darkOrange,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              SizedBox(width: 15),

              // Thanh tìm kiếm với thiết kế mới
              Expanded(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: 45,
                  decoration: BoxDecoration(
                    color: isSearching ? Colors.white : Colors.grey[100],
                    borderRadius: BorderRadius.circular(25), // Bo tròn hơn
                    border: Border.all(
                      color: isSearching
                          ? AppColor.darkOrange
                          : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: isSearching
                        ? [
                            BoxShadow(
                              color: AppColor.darkOrange.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Icon(
                          Icons.search,
                          color: isSearching
                              ? AppColor.darkOrange
                              : Colors.grey[400],
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Bạn đang tìm gì?',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                          ),
                          onTap: () {
                            setState(() {
                              isSearching = true;
                            });
                          },
                          onSubmitted: (value) {
                            setState(() {
                              searchValue = value;
                              if (searchValue != "" &&
                                  searchValue?.trim() != "") {
                                currentPage = 1;
                                targetType = null;
                                categoryType = null;
                                sortType = "createAt-desc";
                                selectedValue_sort = "Mới nhất";
                                fetchDataProducst();
                              }
                            });
                          },
                        ),
                      ),
                      if (isSearching)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            icon: Icon(Icons.close,
                                color: Colors.grey[400], size: 18),
                            onPressed: () {
                              setState(() {
                                searchController.clear();
                                searchValue = null;
                                isSearching = false;
                                currentPage = 1;
                                targetType = null;
                                categoryType = null;
                                sortType = "createAt-desc";
                                selectedValue_sort = "Mới nhất";
                                fetchDataProducst();
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recommendedProductListView(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: AppData.recommendedProducts.length,
        itemBuilder: (_, index) {
          RecommendedProduct recommendedProduct =
              AppData.recommendedProducts[index];

          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: AppData.recommendedProducts[index].cardBackgroundColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Stack(
                children: [
                  // Nội dung bên trái
                  Positioned(
                    left: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            recommendedProduct.detail,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              child: ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    targetType = index+1;
                                    selectedValue_target = (targetType==1 ? "Male" : "Female");
                                  });
                                  await fetchDataProducst();
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    Scrollable.ensureVisible(_key.currentContext!,
                                        duration: Duration(milliseconds: 500));
                                  });

                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    recommendedProduct.buttonBackgroundColor!,
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Xem ngay",
                                  style: TextStyle(
                                    color: Color(0xFFFCE4EC),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  // Hình ảnh bên phải
                  Positioned(
                    right: 15,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(recommendedProduct.imagePath),
                          fit: BoxFit.contain,
                          alignment: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _topCategoriesHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Danh mục",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }

  Widget _topCategoriesListView() {
    return ListItemSelector(
      key: _key,
      categories: categoryList,
      onItemPressed: (index) async {
        print("đã chọn: ${categoryList[index].name}");
        if (categoryList[index].name != "ALL") {
          setState(() {
            currentPage = 1;
            // sortType = "createAt-desc";
            categoryType = "${categoryList[index].categoryID}";
            // targetType = null;
            // searchValue = null;
          });
          await fetchDataProducst();
        } else {
          setState(() {
            currentPage = 1;
            // sortType = "createAt-desc";
            categoryType = null;
            // targetType = null;
            // searchValue = null;
          });
          await fetchDataProducst();
        }
      },
    );
  }

  Widget targetBox() {
    List<String> dropdownItems = ['All', 'Male', 'Female'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue_target,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColor.darkOrange),
          items: dropdownItems.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              print("đã chọn target $newValue");
              selectedValue_target = newValue!;
              targetType = newValue == 'All'
                  ? null
                  : newValue == "Male"
                      ? 1
                      : 2;
              print("targetType = $targetType");
              currentPage = 1;
              fetchDataProducst();
            });
          },
        ),
      ),
    );
  }

  Widget sortBox() {
    List<String> dropdownItems = [
      'Mới nhất',
      'Cũ nhất',
      'Tên A-Z',
      'Tên Z-A',
      'Giá tăng dần',
      'Giá giảm dần'
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue_sort,
          icon: Icon(Icons.sort, color: AppColor.darkOrange),
          items: dropdownItems.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              print("đã chọn target ${newValue}");
              if (newValue == 'Mới nhất') {
                sortType = "createAt-desc";
              } else if (newValue == 'Cũ nhất') {
                sortType = "createAt-asc";
              } else if (newValue == 'Tên A-Z') {
                sortType = "name-asc";
              } else if (newValue == 'Tên Z-A') {
                sortType = "name-desc";
              } else if (newValue == 'Giá tăng dần') {
                sortType = "price-asc";
              } else if (newValue == 'Giá giảm dần') {
                sortType = "price-desc";
              }
              print("sortType = $sortType");
              currentPage = 1;
              fetchDataProducst();
              selectedValue_sort = newValue!;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.getAllItems();

    if (productList.isNotEmpty || totalPage > 1 || categoryList.isNotEmpty) {
      return Scaffold(
        appBar: _appBar,
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
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phần chào mừng với màu sắc mới
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Xin chào, ${AppData.userInfo?.fullname}",
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  color: AppColor.darkOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            "Bạn muốn mua gì hôm nay?",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    _recommendedProductListView(context),
                    _topCategoriesHeader(context),
                    SizedBox(height: 10),
                    _topCategoriesListView(),
                    SizedBox(height: 20),

                    // Phần filter và sort mới
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Filter by target
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Text(
                                    "Đối tượng:",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                targetBox(),
                              ],
                            ),
                            SizedBox(width: 15),
                            // Sort options
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Text(
                                    "Sắp xếp:",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                sortBox(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Grid sản phẩm
                    GetBuilder(
                      builder: (ProductController controller) {
                        return ProductGridView2(
                          items: productList,
                        );
                      },
                    ),
                    SizedBox(height: 15),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        child: PaginationWidget(
                            totalPage, currentPage, setPageNumber)),
                    SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
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
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
  }
}
