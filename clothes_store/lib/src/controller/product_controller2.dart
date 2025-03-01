import 'dart:convert';

import 'package:clothes_store/core/app_data.dart';
import 'package:clothes_store/server.dart';
import 'package:clothes_store/src/model/CATEGORY_MODEL.dart';
import 'package:clothes_store/src/model/PRODUCT_LIST_MODEL.dart';
import 'package:clothes_store/src/model/PRODUCT_MODEL.dart';
import 'package:clothes_store/src/model/STOCK_MODEL.dart';
import 'package:http/http.dart' as http;

class ProductController2 {

  // Future<PRODUCT_LIST_MODEL?> getProducts() async {
  //   print("fetch dữ liệu ${Base_URL}/api/products");
  //   try {
  //     final response = await http.get(Uri.parse('$Base_URL/api/products'));
  //     if (response.statusCode == 200) {
  //       var data = response.body;
  //
  //       var products = json.decode(data);
  //       // print(products);
  //       return PRODUCT_LIST_MODEL.fromJson(products);
  //     }
  //     else {
  //       print('Empty response body received');
  //       return null;
  //     }
  //   } catch (error) {
  //     throw Exception('Error: ${error}');
  //   }
  // }

  Future<PRODUCT_LIST_MODEL?> getProducts2(int? pageNumber, String? sortType, String? categoryType, int? targetType, String? searchValue) async {

    // http://localhost:5000/api/products
    // ?page=1&sort=price-asc&category=5&target=1&search=áo%20thun&isActivated=true

    String baseProductsUrl = '${Server.baseUrl}/api/products';

    if(pageNumber != null||sortType != null||categoryType != null||targetType != null||searchValue!=null) {
      baseProductsUrl+="?";
      if(pageNumber != null) {
        baseProductsUrl += "page=$pageNumber";
      }
      if(sortType != null) {
        baseProductsUrl += "&sort=$sortType";
        // (price-asc, price-desc, name-asc, name-desc, createAt-desc, createAt-asc)
      }
      if(categoryType != null) { //ID hoặc tên danh mục sản phẩm
        baseProductsUrl += "&category=$categoryType";
      }
      if(targetType != null) { // (1: Nam, 2: Nữ)
        baseProductsUrl += "&target=$targetType";
      }
      if(searchValue != null) {
        searchValue = searchValue.trim();
        baseProductsUrl += "&search=$searchValue";
      }

    }
    baseProductsUrl += "&isActivated=true";

    String encodedUrl = Uri.encodeFull(baseProductsUrl);

    print("fetch dữ liệu $encodedUrl");
    try {
      final response = await http.get(Uri.parse(encodedUrl));
      if (response.statusCode == 200) {
        var data = response.body;

        var products = json.decode(data);
        // print(products);
        return PRODUCT_LIST_MODEL.fromJson(products);
      }
      else {
        print('Empty response body received');
        return null;
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  Future<List<CATEGORY_MODEL>> getCategories() async {
    print("fetch dữ liệu ${Server.baseUrl}/api/products");
    try {
      final response = await http.get(Uri.parse('${Server.baseUrl}/api/categories'));
      if (response.statusCode == 200) {
        var data = response.body;

        var cats = json.decode(data) as List;
        // print(products);
        return cats.map( (e) => CATEGORY_MODEL.fromJson(e) ).toList();
      }
      else {
        print('Empty response body received while fetching category');
        return [];
      }
    } catch (error) {
      throw Exception('Error fetch categories: $error');
    }
  }

  // danh sách sản phẩm liên quan
  // api/products?page=1&sort=createAt-desc&category=5&target=1&limit=5&isActivated=true
  // truyền vào categoryID, targetID
  Future<PRODUCT_LIST_MODEL?> getRelatedProducts(int? categoryType, int? targetType) async {
    // http://localhost:5000/api/products
    // ?page=1&sort=price-asc&category=5&target=1&search=áo%20thun&isActivated=true

    String base_products_url = '${Server.baseUrl}/api/products';

    if(categoryType != null||targetType != null) {
      base_products_url+="?";
      base_products_url += "page=1";
      base_products_url += "&sort=createAt-desc";
      if(categoryType != null) { //ID hoặc tên danh mục sản phẩm
        base_products_url += "&category=$categoryType";
      }
      if(targetType != null) { // (1: Nam, 2: Nữ)
        base_products_url += "&target=$targetType";
      }
    }
    base_products_url += "&limit=4&isActivated=true";

    String encodedUrl = Uri.encodeFull(base_products_url);

    print("fetch dữ liệu $encodedUrl");
    try {
      final response = await http.get(Uri.parse(encodedUrl));
      if (response.statusCode == 200) {
        var data = response.body;
        var products = json.decode(data);
        // print(products);
        return PRODUCT_LIST_MODEL.fromJson(products);
      }
      else {
        print('Empty response body received');
        return null;
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }


  Future<PRODUCT_MODEL?> getProductById(int id) async {
    print("fetch dữ liệu ${Server.baseUrl}/api/products/flutter/$id");
    try {
      final response = await http.get(Uri.parse('${Server.baseUrl}/api/products/flutter/$id'));
      if (response.statusCode == 200) {
        var data = response.body;
        var products = json.decode(data);
        // print(products);
        return PRODUCT_MODEL.fromJson(products);
      }
      else {
        print('Empty response body received while fetching product by id');
        return null;
      }
    } catch (error) {
      throw Exception('Error fetch Product By Id: $error');
    }
  }

  Future<STOCK_MODEL?> getStockBySKU(String sku) async {
    print("fetch dữ liệu ${Server.baseUrl}/api/products/stock/$sku");
    try {
      final response = await http.get(Uri.parse('${Server.baseUrl}/api/products/stock/$sku'));
      if (response.statusCode == 200) {
        var data = response.body;
        var stock = json.decode(data);
        // print(products);
        return STOCK_MODEL.fromJson(stock);
      }
      else {
        print('Empty response body received while fetching stock by sku');
        return null;
      }
    } catch (error) {
      throw Exception('Error fetch stock by sku: $error');
    }
  }

}

class ReturnMessager{
  String messager;
  int statusCode;
  ReturnMessager({required this.messager, required this.statusCode});
}
