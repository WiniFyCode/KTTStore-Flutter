class STOCK_MODEL {
  String? _sKU;
  String? _size;
  int? _stock;

  STOCK_MODEL({String? sKU, String? size, int? stock}) {
    if (sKU != null) {
      this._sKU = sKU;
    }
    if (size != null) {
      this._size = size;
    }
    if (stock != null) {
      this._stock = stock;
    }
  }

  String? get sKU => _sKU;
  set sKU(String? sKU) => _sKU = sKU;
  String? get size => _size;
  set size(String? size) => _size = size;
  int? get stock => _stock;
  set stock(int? stock) => _stock = stock;

  STOCK_MODEL.fromJson(Map<String, dynamic> json) {
    _sKU = json['SKU'];
    _size = json['size'];
    _stock = json['stock'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SKU'] = this._sKU;
    data['size'] = this._size;
    data['stock'] = this._stock;
    return data;
  }
}
