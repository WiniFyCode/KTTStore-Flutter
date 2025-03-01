class CART_MODEL {
  int? _cartID;
  String? _SKU;
  Product? _product;
  String? _size;
  String? _colorName;
  int? _quantity;
  double? _subtotal;
  int? _stock;

  bool _isSelected = false;

  CART_MODEL(
      {int? cartID,
        String? SKU,
        Product? product,
        String? size,
        String? colorName,
        int? quantity,
        double? subtotal,
        int? stock}) {
    if (cartID != null) {
      this._cartID = cartID;
    }
    if (SKU != null) {
      this._SKU = SKU;
    }
    if (product != null) {
      this._product = product;
    }
    if (size != null) {
      this._size = size;
    }
    if (colorName != null) {
      this._colorName = colorName;
    }
    if (quantity != null) {
      this._quantity = quantity;
    }
    if (subtotal != null) {
      this._subtotal = subtotal;
    }
    if (stock != null) {
      this._stock = stock;
    }
  }

  int? get cartID => _cartID;
  set cartID(int? cartID) => _cartID = cartID;
  Product? get product => _product;
  set product(Product? product) => _product = product;
  String? get size => _size;
  set size(String? size) => _size = size;
  String? get colorName => _colorName;
  set colorName(String? colorName) => _colorName = colorName;
  int? get quantity => _quantity;
  set quantity(int? quantity) => _quantity = quantity;
  double? get subtotal => _subtotal;
  set subtotal(double? subtotal) => _subtotal = subtotal;
  int? get stock => _stock;
  set stock(int? stock) => _stock = stock;
  String? get SKU => _SKU;
  set SKU(String? SKU) => _SKU = SKU;
  bool get isSelected => _isSelected;
  set isSelected(bool value) {
    _isSelected = value;
  }

  CART_MODEL.fromJson(Map<String, dynamic> json) {
    _cartID = json['cartID'];
    _SKU = json['SKU'];
    _product =
    json['product'] != null ? new Product.fromJson(json['product']) : null;
    _size = json['size'];
    _colorName = json['colorName'];
    _quantity = json['quantity'];
    _subtotal =  (json['subtotal'] as num).toDouble();
    _stock = json['stock'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cartID'] = this._cartID;
    if (this._product != null) {
      data['product'] = this._product!.toJson();
    }
    data['size'] = this._size;
    data['colorName'] = this._colorName;
    data['quantity'] = this._quantity;
    data['subtotal'] = this._subtotal;
    data['stock'] = this._stock;
    return data;
  }
}

class Product {
  int? _productID;
  String? _name;
  double? _price;
  double? _discountPrice;
  String? _thumbnail;
  int? _categoryID;

  double? discountedPriceByCoupon;


  Product({int? productID, String? name, double? price, double? discountPrice, String? thumbnail, int? categoryID}) {
    if (productID != null) {
      this._productID = productID;
    }
    if (name != null) {
      this._name = name;
    }
    if (price != null) {
      this._price = price;
    }
    if (discountPrice != null) {
      this._discountPrice = discountPrice;
    }
    if (thumbnail != null) {
      this._thumbnail = thumbnail;
    }
    if (categoryID != null) {
      this._categoryID = categoryID;
    }
  }

  int? get productID => _productID;
  set productID(int? productID) => _productID = productID;
  String? get name => _name;
  set name(String? name) => _name = name;
  double? get price => _price;
  set price(double? price) => _price = price;
  double? get discountPrice => _discountPrice;
  set discountPrice(double? discountPrice) => _discountPrice = discountPrice;
  String? get thumbnail => _thumbnail;
  set thumbnail(String? thumbnail) => _thumbnail = thumbnail;
  int? get categoryID => _categoryID;
  set categoryID(int? categoryID) => _categoryID = categoryID;

  Product.fromJson(Map<String, dynamic> json) {
    _productID = json['productID'];
    _name = json['name'];
    _price = (json['price'] as num).toDouble();
    _discountPrice = (json['discountPrice'] as num).toDouble();
    _thumbnail = json['thumbnail'];
    _categoryID = json['categoryID'];

    print("discount price: $_discountPrice");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productID'] = this._productID;
    data['name'] = this._name;
    data['price'] = this._price;
    data['discountPrice'] = this._discountPrice;
    data['thumbnail'] = this._thumbnail;
    data['categoryID'] = this._categoryID;

    return data;
  }
}
