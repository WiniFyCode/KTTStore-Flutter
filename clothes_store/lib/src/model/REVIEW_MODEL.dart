class REVIEW_MODEL {
  int? _reviewID;
  int? _rating;
  String? _comment;
  String? _createdAt;
  UserInfo? _userInfo;

  REVIEW_MODEL(
      {int? reviewID,
        int? rating,
        String? comment,
        String? createdAt,
        UserInfo? userInfo}) {
    if (reviewID != null) {
      this._reviewID = reviewID;
    }
    if (rating != null) {
      this._rating = rating;
    }
    if (comment != null) {
      this._comment = comment;
    }
    if (createdAt != null) {
      this._createdAt = createdAt;
    }
    if (userInfo != null) {
      this._userInfo = userInfo;
    }
  }

  int? get reviewID => _reviewID;
  set reviewID(int? reviewID) => _reviewID = reviewID;
  int? get rating => _rating;
  set rating(int? rating) => _rating = rating;
  String? get comment => _comment;
  set comment(String? comment) => _comment = comment;
  String? get createdAt => _createdAt;
  set createdAt(String? createdAt) => _createdAt = createdAt;
  UserInfo? get userInfo => _userInfo;
  set userInfo(UserInfo? userInfo) => _userInfo = userInfo;

  REVIEW_MODEL.fromJson(Map<String, dynamic> json) {
    _reviewID = json['reviewID'];
    _rating = json['rating'];
    _comment = json['comment'];
    _createdAt = json['createdAt'];
    _userInfo = json['userInfo'] != null
        ? new UserInfo.fromJson(json['userInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['reviewID'] = this._reviewID;
    data['rating'] = this._rating;
    data['comment'] = this._comment;
    data['createdAt'] = this._createdAt;
    if (this._userInfo != null) {
      data['userInfo'] = this._userInfo!.toJson();
    }
    return data;
  }
}

class UserInfo {
  int? _userID;
  String? _fullName;

  UserInfo({int? userID, String? fullName}) {
    if (userID != null) {
      this._userID = userID;
    }
    if (fullName != null) {
      this._fullName = fullName;
    }
  }

  int? get userID => _userID;
  set userID(int? userID) => _userID = userID;
  String? get fullName => _fullName;
  set fullName(String? fullName) => _fullName = fullName;

  UserInfo.fromJson(Map<String, dynamic> json) {
    _userID = json['userID'];
    _fullName = json['fullName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userID'] = this._userID;
    data['fullName'] = this._fullName;
    return data;
  }
}
