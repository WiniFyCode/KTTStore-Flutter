class ORDER_MODEL {
  String? _sId;
  int? _orderID;
  int? _userID;
  String? _fullname;
  String? _phone;
  String? _address;
  double? _totalPrice;
  int? _userCouponsID;
  double? _paymentPrice;
  String? _orderStatus;
  String? _shippingStatus;
  bool? _isPayed;
  String? _createdAt;
  String? _updatedAt;
  int? _iV;
  List<OrderDetails>? _orderDetails;

  ORDER_MODEL(
      {String? sId,
        int? orderID,
        int? userID,
        String? fullname,
        String? phone,
        String? address,
        double? totalPrice,
        int? userCouponsID,
        double? paymentPrice,
        String? orderStatus,
        String? shippingStatus,
        bool? isPayed,
        String? createdAt,
        String? updatedAt,
        int? iV,
        List<OrderDetails>? orderDetails}) {
    if (sId != null) {
      this._sId = sId;
    }
    if (orderID != null) {
      this._orderID = orderID;
    }
    if (userID != null) {
      this._userID = userID;
    }
    if (fullname != null) {
      this._fullname = fullname;
    }
    if (phone != null) {
      this._phone = phone;
    }
    if (address != null) {
      this._address = address;
    }
    if (totalPrice != null) {
      this._totalPrice = totalPrice;
    }
    if (userCouponsID != null) {
      this._userCouponsID = userCouponsID;
    }
    if (paymentPrice != null) {
      this._paymentPrice = paymentPrice;
    }
    if (orderStatus != null) {
      this._orderStatus = orderStatus;
    }
    if (shippingStatus != null) {
      this._shippingStatus = shippingStatus;
    }
    if (isPayed != null) {
      this._isPayed = isPayed;
    }
    if (createdAt != null) {
      this._createdAt = createdAt;
    }
    if (updatedAt != null) {
      this._updatedAt = updatedAt;
    }
    if (iV != null) {
      this._iV = iV;
    }
    if (orderDetails != null) {
      this._orderDetails = orderDetails;
    }
  }

  String? get sId => _sId;
  set sId(String? sId) => _sId = sId;
  int? get orderID => _orderID;
  set orderID(int? orderID) => _orderID = orderID;
  int? get userID => _userID;
  set userID(int? userID) => _userID = userID;
  String? get fullname => _fullname;
  set fullname(String? fullname) => _fullname = fullname;
  String? get phone => _phone;
  set phone(String? phone) => _phone = phone;
  String? get address => _address;
  set address(String? address) => _address = address;
  double? get totalPrice => _totalPrice;
  set totalPrice(double? totalPrice) => _totalPrice = totalPrice;
  int? get userCouponsID => _userCouponsID;
  set userCouponsID(int? userCouponsID) => _userCouponsID = userCouponsID;
  double? get paymentPrice => _paymentPrice;
  set paymentPrice(double? paymentPrice) => _paymentPrice = paymentPrice;
  String? get orderStatus => _orderStatus;
  set orderStatus(String? orderStatus) => _orderStatus = orderStatus;
  String? get shippingStatus => _shippingStatus;
  set shippingStatus(String? shippingStatus) =>
      _shippingStatus = shippingStatus;
  bool? get isPayed => _isPayed;
  set isPayed(bool? isPayed) => _isPayed = isPayed;
  String? get createdAt => _createdAt;
  set createdAt(String? createdAt) => _createdAt = createdAt;
  String? get updatedAt => _updatedAt;
  set updatedAt(String? updatedAt) => _updatedAt = updatedAt;
  int? get iV => _iV;
  set iV(int? iV) => _iV = iV;
  List<OrderDetails>? get orderDetails => _orderDetails;
  set orderDetails(List<OrderDetails>? orderDetails) =>
      _orderDetails = orderDetails;

  ORDER_MODEL.fromJson(Map<String, dynamic> json) {
    _sId = json['_id'];
    _orderID = json['orderID'];
    _userID = json['userID'];
    _fullname = json['fullname'];
    _phone = json['phone'];
    _address = json['address'];
    _totalPrice = (json['totalPrice'] as num).toDouble();
    _userCouponsID = json['userCouponsID'];
    _paymentPrice = (json['paymentPrice'] as num).toDouble();
    _orderStatus = json['orderStatus'];
    _shippingStatus = json['shippingStatus'];
    _isPayed = json['isPayed'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _iV = json['__v'];
    if (json['orderDetails'] != null) {
      _orderDetails = <OrderDetails>[];
      json['orderDetails'].forEach((v) {
        _orderDetails!.add(new OrderDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this._sId;
    data['orderID'] = this._orderID;
    data['userID'] = this._userID;
    data['fullname'] = this._fullname;
    data['phone'] = this._phone;
    data['address'] = this._address;
    data['totalPrice'] = this._totalPrice;
    data['userCouponsID'] = this._userCouponsID;
    data['paymentPrice'] = this._paymentPrice;
    data['orderStatus'] = this._orderStatus;
    data['shippingStatus'] = this._shippingStatus;
    data['isPayed'] = this._isPayed;
    data['createdAt'] = this._createdAt;
    data['updatedAt'] = this._updatedAt;
    data['__v'] = this._iV;
    if (this._orderDetails != null) {
      data['orderDetails'] =
          this._orderDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderDetails {
  int? _orderDetailID;
  int? _quantity;
  String? _sKU;
  String? _size;
  int? _stock;
  Product? _product;

  OrderDetails(
      {int? orderDetailID,
        int? quantity,
        String? sKU,
        String? size,
        int? stock,
        Product? product}) {
    if (orderDetailID != null) {
      this._orderDetailID = orderDetailID;
    }
    if (quantity != null) {
      this._quantity = quantity;
    }
    if (sKU != null) {
      this._sKU = sKU;
    }
    if (size != null) {
      this._size = size;
    }
    if (stock != null) {
      this._stock = stock;
    }
    if (product != null) {
      this._product = product;
    }
  }

  int? get orderDetailID => _orderDetailID;
  set orderDetailID(int? orderDetailID) => _orderDetailID = orderDetailID;
  int? get quantity => _quantity;
  set quantity(int? quantity) => _quantity = quantity;
  String? get sKU => _sKU;
  set sKU(String? sKU) => _sKU = sKU;
  String? get size => _size;
  set size(String? size) => _size = size;
  int? get stock => _stock;
  set stock(int? stock) => _stock = stock;
  Product? get product => _product;
  set product(Product? product) => _product = product;

  OrderDetails.fromJson(Map<String, dynamic> json) {
    _orderDetailID = json['orderDetailID'];
    _quantity = json['quantity'];
    _sKU = json['SKU'];
    _size = json['size'];
    _stock = json['stock'];
    _product =
    json['product'] != null ? new Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderDetailID'] = this._orderDetailID;
    data['quantity'] = this._quantity;
    data['SKU'] = this._sKU;
    data['size'] = this._size;
    data['stock'] = this._stock;
    if (this._product != null) {
      data['product'] = this._product!.toJson();
    }
    return data;
  }
}

class Product {
  int? _productID;
  String? _name;
  double? _price;
  String? _colorName;
  String? _image;

  Product(
      {int? productID,
        String? name,
        double? price,
        String? colorName,
        String? image}) {
    if (productID != null) {
      this._productID = productID;
    }
    if (name != null) {
      this._name = name;
    }
    if (price != null) {
      this._price = price;
    }
    if (colorName != null) {
      this._colorName = colorName;
    }
    if (image != null) {
      this._image = image;
    }
  }

  int? get productID => _productID;
  set productID(int? productID) => _productID = productID;
  String? get name => _name;
  set name(String? name) => _name = name;
  double? get price => _price;
  set price(double? price) => _price = price;
  String? get colorName => _colorName;
  set colorName(String? colorName) => _colorName = colorName;
  String? get image => _image;
  set image(String? image) => _image = image;

  Product.fromJson(Map<String, dynamic> json) {
    _productID = json['productID'];
    _name = json['name'];
    _price = (json['price'] as num).toDouble();
    _colorName = json['colorName'];
    _image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productID'] = this._productID;
    data['name'] = this._name;
    data['price'] = this._price;
    data['colorName'] = this._colorName;
    data['image'] = this._image;
    return data;
  }
}
