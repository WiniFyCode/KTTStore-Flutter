import 'package:clothes_store/src/model/NOTIFICATION_MODEL.dart';

class NOTIFICATION_PAGINATION_MODEL {
  String? _message;
  List<NOTIFICATION_MODEL>? _notifications;
  Pagination? _pagination;

  NOTIFICATION_PAGINATION_MODEL(
      {String? message,
        List<NOTIFICATION_MODEL>? notifications,
        Pagination? pagination}) {
    if (message != null) {
      this._message = message;
    }
    if (notifications != null) {
      this._notifications = notifications;
    }
    if (pagination != null) {
      this._pagination = pagination;
    }
  }

  String? get message => _message;
  set message(String? message) => _message = message;
  List<NOTIFICATION_MODEL>? get notifications => _notifications;
  set notifications(List<NOTIFICATION_MODEL>? notifications) =>
      _notifications = notifications;
  Pagination? get pagination => _pagination;
  set pagination(Pagination? pagination) => _pagination = pagination;

  NOTIFICATION_PAGINATION_MODEL.fromJson(Map<String, dynamic> json) {
    _message = json['message'];
    if (json['notifications'] != null) {
      _notifications = <NOTIFICATION_MODEL>[];
      json['notifications'].forEach((v) {
        _notifications!.add(new NOTIFICATION_MODEL.fromJson(v));
      });
    }
    _pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this._message;
    if (this._notifications != null) {
      data['notifications'] =
          this._notifications!.map((v) => v.toJson()).toList();
    }
    if (this._pagination != null) {
      data['pagination'] = this._pagination!.toJson();
    }
    return data;
  }
}


class Pagination {
  int? _total;
  int? _totalPages;
  int? _currentPage;
  int? _limit;

  Pagination({int? total, int? totalPages, int? currentPage, int? limit}) {
    if (total != null) {
      this._total = total;
    }
    if (totalPages != null) {
      this._totalPages = totalPages;
    }
    if (currentPage != null) {
      this._currentPage = currentPage;
    }
    if (limit != null) {
      this._limit = limit;
    }
  }

  int? get total => _total;
  set total(int? total) => _total = total;
  int? get totalPages => _totalPages;
  set totalPages(int? totalPages) => _totalPages = totalPages;
  int? get currentPage => _currentPage;
  set currentPage(int? currentPage) => _currentPage = currentPage;
  int? get limit => _limit;
  set limit(int? limit) => _limit = limit;

  Pagination.fromJson(Map<String, dynamic> json) {
    _total = json['total'];
    _totalPages = json['totalPages'];
    _currentPage = json['currentPage'];
    _limit = json['limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this._total;
    data['totalPages'] = this._totalPages;
    data['currentPage'] = this._currentPage;
    data['limit'] = this._limit;
    return data;
  }
}
