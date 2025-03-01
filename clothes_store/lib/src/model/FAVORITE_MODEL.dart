class FAVORITE_MODEL {
  int? favoriteID;
  String? sKU;
  int? productID;
  String? name;
  int? price;
  String? thumbnail;
  String? colorName;
  String? size;
  Promotion? promotion;
  String? note;

  FAVORITE_MODEL({
    this.favoriteID,
    this.sKU,
    this.productID,
    this.name,
    this.price,
    this.thumbnail,
    this.colorName,
    this.size,
    this.promotion,
    this.note,
  });

  FAVORITE_MODEL.fromJson(Map<String, dynamic> json) {
    favoriteID = json['favoriteID'];
    sKU = json['SKU'];
    productID = json['productID'];
    name = json['name'];
    price = json['price'];
    thumbnail = json['thumbnail'];
    colorName = json['colorName'];
    size = json['size'];
    promotion = json['promotion'] != null ? Promotion.fromJson(json['promotion']) : null;
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['favoriteID'] = favoriteID;
    data['SKU'] = sKU;
    data['productID'] = productID;
    data['name'] = name;
    data['price'] = price;
    data['thumbnail'] = thumbnail;
    data['colorName'] = colorName;
    data['size'] = size;
    if (promotion != null) {
      data['promotion'] = promotion!.toJson();
    }
    data['note'] = note;
    return data;
  }
}

class Promotion {
  String? name;
  int? discountPercent;
  String? discountedPrice;
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
    discountedPrice = json['discountedPrice'];
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
