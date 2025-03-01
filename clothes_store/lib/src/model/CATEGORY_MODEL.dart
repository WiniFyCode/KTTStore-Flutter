

class CATEGORY_MODEL {
  int? _categoryID;
  String? _name;
  String? _imageURL;
  bool _isSelected = false;

  CATEGORY_MODEL({int? categoryID, String? name, String? imageURL}) {
    if (categoryID != null) {
      this._categoryID = categoryID;
    }
    if (name != null) {
      this._name = name;
    }
    if (imageURL != null) {
      this._imageURL = imageURL;
    }
  }

  int? get categoryID => _categoryID;
  set categoryID(int? categoryID) => _categoryID = categoryID;
  String? get name => _name;
  set name(String? name) => _name = name;
  String? get imageURL => _imageURL;
  set imageURL(String? imageURL) => _imageURL = imageURL;
  bool get isSelected => _isSelected;
  set isSelected(bool isSelected) => _isSelected = isSelected;

  CATEGORY_MODEL.fromJson(Map<String, dynamic> json) {
    _categoryID = json['categoryID'];
    _name = json['name'];
    _imageURL = json['imageURL'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['categoryID'] = this._categoryID;
    data['name'] = this._name;
    data['imageURL'] = this._imageURL;
    return data;
  }
}
