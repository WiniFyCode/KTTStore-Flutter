class ADDRESS_MODEL {
  String? _sId;
  int? _addressID;
  int? _userID;
  String? _address;
  bool? _isDefault;
  bool? _isDelete;
  String? _createdAt;
  String? _updatedAt;
  int? _iV;

  ADDRESS_MODEL(
      {String? sId,
        int? addressID,
        int? userID,
        String? address,
        bool? isDefault,
        bool? isDelete,
        String? createdAt,
        String? updatedAt,
        int? iV}) {
    if (sId != null) {
      this._sId = sId;
    }
    if (addressID != null) {
      this._addressID = addressID;
    }
    if (userID != null) {
      this._userID = userID;
    }
    if (address != null) {
      this._address = address;
    }
    if (isDefault != null) {
      this._isDefault = isDefault;
    }
    if (isDelete != null) {
      this._isDelete = isDelete;
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
  }

  String? get sId => _sId;
  set sId(String? sId) => _sId = sId;
  int? get addressID => _addressID;
  set addressID(int? addressID) => _addressID = addressID;
  int? get userID => _userID;
  set userID(int? userID) => _userID = userID;
  String? get address => _address;
  set address(String? address) => _address = address;
  bool? get isDefault => _isDefault;
  set isDefault(bool? isDefault) => _isDefault = isDefault;
  bool? get isDelete => _isDelete;
  set isDelete(bool? isDelete) => _isDelete = isDelete;
  String? get createdAt => _createdAt;
  set createdAt(String? createdAt) => _createdAt = createdAt;
  String? get updatedAt => _updatedAt;
  set updatedAt(String? updatedAt) => _updatedAt = updatedAt;
  int? get iV => _iV;
  set iV(int? iV) => _iV = iV;

  ADDRESS_MODEL.fromJson(Map<String, dynamic> json) {
    _sId = json['_id'];
    _addressID = json['addressID'];
    _userID = json['userID'];
    _address = json['address'];
    _isDefault = json['isDefault'];
    _isDelete = json['isDelete'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this._sId;
    data['addressID'] = this._addressID;
    data['userID'] = this._userID;
    data['address'] = this._address;
    data['isDefault'] = this._isDefault;
    data['isDelete'] = this._isDelete;
    data['createdAt'] = this._createdAt;
    data['updatedAt'] = this._updatedAt;
    data['__v'] = this._iV;
    return data;
  }
}
