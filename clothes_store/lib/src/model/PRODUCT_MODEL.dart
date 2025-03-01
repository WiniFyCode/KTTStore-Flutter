class PRODUCT_MODEL {
  String? sId;
  int? productID;
  String? name;
  int? targetID;
  String? description;
  int? price;
  int? categoryID;
  String? createdAt;
  String? updatedAt;
  String? thumbnail;
  bool? isActivated;
  List<Colors_Model>? colors;
  int? totalStock;
  String? category;
  String? target;
  bool? inStock;
  bool? isFavorite;
  Promotion? promotion;

  PRODUCT_MODEL({
    this.sId,
    this.productID,
    this.name,
    this.targetID,
    this.description,
    this.price,
    this.categoryID,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
    this.isActivated,
    this.colors,
    this.totalStock,
    this.category,
    this.target,
    this.inStock,
    this.isFavorite,
    this.promotion,
  });

  PRODUCT_MODEL.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    productID = json['productID'];
    name = json['name'];
    targetID = json['targetID'];
    description = json['description'];
    price = json['price'];
    categoryID = json['categoryID'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    thumbnail = json['thumbnail'];
    isActivated = json['isActivated'];
    if (json['colors'] != null) {
      colors = <Colors_Model>[];
      json['colors'].forEach((v) {
        colors!.add(Colors_Model.fromJson(v));
      });
    }
    totalStock = json['totalStock'];
    category = json['category'];
    target = json['target'];
    inStock = json['inStock'];
    isFavorite = json['isFavorite'];
    promotion = json['promotion'] != null ? Promotion.fromJson(json['promotion']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['productID'] = this.productID;
    data['name'] = this.name;
    data['targetID'] = this.targetID;
    data['description'] = this.description;
    data['price'] = this.price;
    data['categoryID'] = this.categoryID;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['thumbnail'] = this.thumbnail;
    data['isActivated'] = this.isActivated;
    if (this.colors != null) {
      data['colors'] = this.colors!.map((v) => v.toJson()).toList();
    }
    data['totalStock'] = this.totalStock;
    data['category'] = this.category;
    data['target'] = this.target;
    data['inStock'] = this.inStock;
    data['isFavorite'] = this.isFavorite;
    if (this.promotion != null) {
      data['promotion'] = this.promotion!.toJson();
    }
    return data;
  }
}

class Colors_Model {
  String? sId;
  int? colorID;
  int? productID;
  String? colorName;
  List<String>? images;
  List<Sizes>? sizes;

  Colors_Model(
      {this.sId,
        this.colorID,
        this.productID,
        this.colorName,
        this.images,
        this.sizes});

  Colors_Model.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    colorID = json['colorID'];
    productID = json['productID'];
    colorName = json['colorName'];
    images = json['images'].cast<String>();
    if (json['sizes'] != null) {
      sizes = <Sizes>[];
      json['sizes'].forEach((v) {
        sizes!.add(new Sizes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['colorID'] = this.colorID;
    data['productID'] = this.productID;
    data['colorName'] = this.colorName;
    data['images'] = this.images;
    if (this.sizes != null) {
      data['sizes'] = this.sizes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Sizes {
  String? sId;
  int? colorID;
  String? size;
  int? stock;
  String? sKU;

  Sizes({this.sId, this.colorID, this.size, this.stock, this.sKU});

  Sizes.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    colorID = json['colorID'];
    size = json['size'];
    stock = json['stock'];
    sKU = json['SKU'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['colorID'] = this.colorID;
    data['size'] = this.size;
    data['stock'] = this.stock;
    data['SKU'] = this.sKU;
    return data;
  }
}

class Promotion {
  String? name;
  int? discountPercent;
  double? discountedPrice;
  String? endDate;

  Promotion({
    this.name,
    this.discountPercent,
    this.discountedPrice,
    this.endDate,
  });

  Promotion.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    discountPercent = json['discountPercent'];
    discountedPrice = json['discountedPrice'] !=null ?(json['discountedPrice'] as num).toDouble(): -1;
    endDate = json['endDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['discountPercent'] = discountPercent;
    data['discountedPrice'] = discountedPrice;
    data['endDate'] = endDate;
    return data;
  }
}
