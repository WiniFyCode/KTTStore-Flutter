class COUPON_PAGINATION_MODEL {
  List<UserCoupons>? _userCoupons;
  Pagination? _pagination;

  COUPON_PAGINATION_MODEL(
      {List<UserCoupons>? userCoupons, Pagination? pagination}) {
    if (userCoupons != null) {
      this._userCoupons = userCoupons;
    }
    if (pagination != null) {
      this._pagination = pagination;
    }
  }

  List<UserCoupons>? get userCoupons => _userCoupons;
  set userCoupons(List<UserCoupons>? userCoupons) => _userCoupons = userCoupons;
  Pagination? get pagination => _pagination;
  set pagination(Pagination? pagination) => _pagination = pagination;

  COUPON_PAGINATION_MODEL.fromJson(Map<String, dynamic> json) {
    print("Starting to parse JSON"); // Debug print
    if (json['userCoupons'] != null) {
      print("userCoupons exists in JSON"); // Debug print
      _userCoupons = <UserCoupons>[];
      try {
        (json['userCoupons'] as List).forEach((v) {
          print("Parsing coupon: $v"); // Debug print
          _userCoupons!.add(UserCoupons.fromJson(v));
        });
      } catch (e) {
        print("Error parsing userCoupons: $e"); // Debug print
      }
    }
    _pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this._userCoupons != null) {
      data['userCoupons'] = this._userCoupons!.map((v) => v.toJson()).toList();
    }
    if (this._pagination != null) {
      data['pagination'] = this._pagination!.toJson();
    }
    return data;
  }
}

class UserCoupons {
  String? _sId;
  int? _userCouponsID;
  int? _couponID;
  int? _userID;
  int? _usageLeft;
  bool? _isExpired;
  String? _status;
  String? _expiryDate;
  CouponInfo? _couponInfo;

  UserCoupons(
      {String? sId,
        int? userCouponsID,
        int? couponID,
        int? userID,
        int? usageLeft,
        bool? isExpired,
        String? status,
        String? expiryDate,
        CouponInfo? couponInfo}) {
    if (sId != null) {
      this._sId = sId;
    }
    if (userCouponsID != null) {
      this._userCouponsID = userCouponsID;
    }
    if (couponID != null) {
      this._couponID = couponID;
    }
    if (userID != null) {
      this._userID = userID;
    }
    if (usageLeft != null) {
      this._usageLeft = usageLeft;
    }
    if (isExpired != null) {
      this._isExpired = isExpired;
    }
    if (status != null) {
      this._status = status;
    }
    if (expiryDate != null) {
      this._expiryDate = expiryDate;
    }
    if (couponInfo != null) {
      this._couponInfo = couponInfo;
    }
  }

  String? get sId => _sId;
  set sId(String? sId) => _sId = sId;
  int? get userCouponsID => _userCouponsID;
  set userCouponsID(int? userCouponsID) => _userCouponsID = userCouponsID;
  int? get couponID => _couponID;
  set couponID(int? couponID) => _couponID = couponID;
  int? get userID => _userID;
  set userID(int? userID) => _userID = userID;
  int? get usageLeft => _usageLeft;
  set usageLeft(int? usageLeft) => _usageLeft = usageLeft;
  bool? get isExpired => _isExpired;
  set isExpired(bool? isExpired) => _isExpired = isExpired;
  String? get status => _status;
  set status(String? status) => _status = status;
  String? get expiryDate => _expiryDate;
  set expiryDate(String? expiryDate) => _expiryDate = expiryDate;
  CouponInfo? get couponInfo => _couponInfo;
  set couponInfo(CouponInfo? couponInfo) => _couponInfo = couponInfo;

  UserCoupons.fromJson(Map<String, dynamic> json) {
    try {
      print("Parsing UserCoupon: ${json['_id']}"); // Debug print
      _sId = json['_id'];
      _userCouponsID = json['userCouponsID'];
      _couponID = json['couponID'];
      _userID = json['userID'];
      _usageLeft = json['usageLeft'];
      _isExpired = json['isExpired'];
      _status = json['status'];
      _expiryDate = json['expiryDate'];
      if (json['couponInfo'] != null) {
        print("Parsing couponInfo"); // Debug print
        _couponInfo = CouponInfo.fromJson(json['couponInfo']);
      }
    } catch (e) {
      print("Error in UserCoupons.fromJson: $e"); // Debug print
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this._sId;
    data['userCouponsID'] = this._userCouponsID;
    data['couponID'] = this._couponID;
    data['userID'] = this._userID;
    data['usageLeft'] = this._usageLeft;
    data['isExpired'] = this._isExpired;
    data['status'] = this._status;
    data['expiryDate'] = this._expiryDate;
    if (this._couponInfo != null) {
      data['couponInfo'] = this._couponInfo!.toJson();
    }
    return data;
  }
}

class CouponInfo {
  String? _sId;
  int? _couponID;
  String? _code;
  String? _description;
  String? _discountType;
  int? _discountValue;
  int? _minOrderValue;
  int? _maxDiscountAmount;
  String? _startDate;
  String? _endDate;
  int? _usageLimit;
  bool? _isActive;
  String? _couponType;
  int? _minimumQuantity;
  List<AppliedCategories>? _appliedCategories;

  CouponInfo(
      {String? sId,
        int? couponID,
        String? code,
        String? description,
        String? discountType,
        int? discountValue,
        int? minOrderValue,
        int? maxDiscountAmount,
        String? startDate,
        String? endDate,
        int? usageLimit,
        bool? isActive,
        String? couponType,
        int? minimumQuantity,
        List<AppliedCategories>? appliedCategories}) {
    if (sId != null) {
      this._sId = sId;
    }
    if (couponID != null) {
      this._couponID = couponID;
    }
    if (code != null) {
      this._code = code;
    }
    if (description != null) {
      this._description = description;
    }
    if (discountType != null) {
      this._discountType = discountType;
    }
    if (discountValue != null) {
      this._discountValue = discountValue;
    }
    if (minOrderValue != null) {
      this._minOrderValue = minOrderValue;
    }
    if (maxDiscountAmount != null) {
      this._maxDiscountAmount = maxDiscountAmount;
    }
    if (startDate != null) {
      this._startDate = startDate;
    }
    if (endDate != null) {
      this._endDate = endDate;
    }
    if (usageLimit != null) {
      this._usageLimit = usageLimit;
    }
    if (isActive != null) {
      this._isActive = isActive;
    }
    if (couponType != null) {
      this._couponType = couponType;
    }
    if (minimumQuantity != null) {
      this._minimumQuantity = minimumQuantity;
    }
    if (appliedCategories != null) {
      this._appliedCategories = appliedCategories;
    }
  }

  String? get sId => _sId;
  set sId(String? sId) => _sId = sId;
  int? get couponID => _couponID;
  set couponID(int? couponID) => _couponID = couponID;
  String? get code => _code;
  set code(String? code) => _code = code;
  String? get description => _description;
  set description(String? description) => _description = description;
  String? get discountType => _discountType;
  set discountType(String? discountType) => _discountType = discountType;
  int? get discountValue => _discountValue;
  set discountValue(int? discountValue) => _discountValue = discountValue;
  int? get minOrderValue => _minOrderValue;
  set minOrderValue(int? minOrderValue) => _minOrderValue = minOrderValue;
  int? get maxDiscountAmount => _maxDiscountAmount;
  set maxDiscountAmount(int? maxDiscountAmount) =>
      _maxDiscountAmount = maxDiscountAmount;
  String? get startDate => _startDate;
  set startDate(String? startDate) => _startDate = startDate;
  String? get endDate => _endDate;
  set endDate(String? endDate) => _endDate = endDate;
  int? get usageLimit => _usageLimit;
  set usageLimit(int? usageLimit) => _usageLimit = usageLimit;
  bool? get isActive => _isActive;
  set isActive(bool? isActive) => _isActive = isActive;
  String? get couponType => _couponType;
  set couponType(String? couponType) => _couponType = couponType;
  int? get minimumQuantity => _minimumQuantity;
  set minimumQuantity(int? minimumQuantity) =>
      _minimumQuantity = minimumQuantity;
  List<AppliedCategories>? get appliedCategories => _appliedCategories;
  set appliedCategories(List<AppliedCategories>? appliedCategories) =>
      _appliedCategories = appliedCategories;

  CouponInfo.fromJson(Map<String, dynamic> json) {
    _sId = json['_id'];
    _couponID = json['couponID'];
    _code = json['code'];
    _description = json['description'];
    _discountType = json['discountType'];
    _discountValue = json['discountValue'];
    _minOrderValue = json['minOrderValue'];
    _maxDiscountAmount = json['maxDiscountAmount'];
    _startDate = json['startDate'];
    _endDate = json['endDate'];
    _usageLimit = json['usageLimit'];
    _isActive = json['isActive'];
    _couponType = json['couponType'];
    _minimumQuantity = json['minimumQuantity'];
    if (json['appliedCategories'] != null) {
      _appliedCategories = <AppliedCategories>[];
      json['appliedCategories'].forEach((v) {
        _appliedCategories!.add(new AppliedCategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this._sId;
    data['couponID'] = this._couponID;
    data['code'] = this._code;
    data['description'] = this._description;
    data['discountType'] = this._discountType;
    data['discountValue'] = this._discountValue;
    data['minOrderValue'] = this._minOrderValue;
    data['maxDiscountAmount'] = this._maxDiscountAmount;
    data['startDate'] = this._startDate;
    data['endDate'] = this._endDate;
    data['usageLimit'] = this._usageLimit;
    data['isActive'] = this._isActive;
    data['couponType'] = this._couponType;
    data['minimumQuantity'] = this._minimumQuantity;
    if (this._appliedCategories != null) {
      data['appliedCategories'] =
          this._appliedCategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AppliedCategories {
  int? _categoryID;
  String? _name;

  AppliedCategories({int? categoryID, String? name}) {
    if (categoryID != null) {
      this._categoryID = categoryID;
    }
    if (name != null) {
      this._name = name;
    }
  }

  int? get categoryID => _categoryID;
  set categoryID(int? categoryID) => _categoryID = categoryID;
  String? get name => _name;
  set name(String? name) => _name = name;

  AppliedCategories.fromJson(Map<String, dynamic> json) {
    _categoryID = json['categoryID'];
    _name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['categoryID'] = this._categoryID;
    data['name'] = this._name;
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
