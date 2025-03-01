import 'package:clothes_store/src/model/FAVORITE_MODEL.dart';

class FAVORITE_PAGINATION_MODEL {
  List<FAVORITE_MODEL>? _products;
  int? _totalItem;
  int? _totalPage;
  int? _currentPage;

  FAVORITE_PAGINATION_MODEL(
      {List<FAVORITE_MODEL>? products,
        int? totalItem,
        int? totalPage,
        int? currentPage}) {
    if (products != null) {
      this._products = products;
    }
    if (totalItem != null) {
      this._totalItem = totalItem;
    }
    if (totalPage != null) {
      this._totalPage = totalPage;
    }
    if (currentPage != null) {
      this._currentPage = currentPage;
    }
  }

  List<FAVORITE_MODEL>? get products => _products;
  set products(List<FAVORITE_MODEL>? products) => _products = products;
  int? get totalItem => _totalItem;
  set totalItem(int? totalItem) => _totalItem = totalItem;
  int? get totalPage => _totalPage;
  set totalPage(int? totalPage) => _totalPage = totalPage;
  int? get currentPage => _currentPage;
  set currentPage(int? currentPage) => _currentPage = currentPage;

  FAVORITE_PAGINATION_MODEL.fromJson(Map<String, dynamic> json) {
    if (json['products'] != null) {
      _products = <FAVORITE_MODEL>[];
      json['products'].forEach((v) {
        _products!.add(new FAVORITE_MODEL.fromJson(v));
      });
    }
    _totalItem = json['totalItem'];
    _totalPage = json['totalPage'];
    _currentPage = json['currentPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this._products != null) {
      data['products'] = this._products!.map((v) => v.toJson()).toList();
    }
    data['totalItem'] = this._totalItem;
    data['totalPage'] = this._totalPage;
    data['currentPage'] = this._currentPage;
    return data;
  }
}


