class NOTIFICATION_MODEL {
  String? _sId;
  int? _notificationID;
  String? _title;
  String? _type;
  String? _message;
  int? _readCount;
  String? _scheduledFor;
  String? _expiresAt;
  String? _createdAt;
  String? _createdBy;
  bool? _isRead;
  DateTime? _readAt;
  int? _userNotificationID;

  NOTIFICATION_MODEL(
      {String? sId,
        int? notificationID,
        String? title,
        String? type,
        String? message,
        int? readCount,
        String? scheduledFor,
        String? expiresAt,
        String? createdAt,
        String? createdBy,
        bool? isRead,
        DateTime? readAt,
        int? userNotificationID}) {
    if (sId != null) {
      this._sId = sId;
    }
    if (notificationID != null) {
      this._notificationID = notificationID;
    }
    if (title != null) {
      this._title = title;
    }
    if (type != null) {
      this._type = type;
    }
    if (message != null) {
      this._message = message;
    }
    if (readCount != null) {
      this._readCount = readCount;
    }
    if (scheduledFor != null) {
      this._scheduledFor = scheduledFor;
    }
    if (expiresAt != null) {
      this._expiresAt = expiresAt;
    }
    if (createdAt != null) {
      this._createdAt = createdAt;
    }
    if (createdBy != null) {
      this._createdBy = createdBy;
    }
    if (isRead != null) {
      this._isRead = isRead;
    }
    if (readAt != null) {
      this._readAt = readAt;
    }
    if (userNotificationID != null) {
      this._userNotificationID = userNotificationID;
    }
  }

  String? get sId => _sId;
  set sId(String? sId) => _sId = sId;
  int? get notificationID => _notificationID;
  set notificationID(int? notificationID) => _notificationID = notificationID;
  String? get title => _title;
  set title(String? title) => _title = title;
  String? get type => _type;
  set type(String? type) => _type = type;
  String? get message => _message;
  set message(String? message) => _message = message;
  int? get readCount => _readCount;
  set readCount(int? readCount) => _readCount = readCount;
  String? get scheduledFor => _scheduledFor;
  set scheduledFor(String? scheduledFor) => _scheduledFor = scheduledFor;
  String? get expiresAt => _expiresAt;
  set expiresAt(String? expiresAt) => _expiresAt = expiresAt;
  String? get createdAt => _createdAt;
  set createdAt(String? createdAt) => _createdAt = createdAt;
  String? get createdBy => _createdBy;
  set createdBy(String? createdBy) => _createdBy = createdBy;
  bool? get isRead => _isRead;
  set isRead(bool? isRead) => _isRead = isRead;
  DateTime? get readAt => _readAt;
  set readAt(DateTime? readAt) => _readAt = readAt;
  int? get userNotificationID => _userNotificationID;
  set userNotificationID(int? userNotificationID) =>
      _userNotificationID = userNotificationID;

  NOTIFICATION_MODEL.fromJson(Map<String, dynamic> json) {
    _sId = json['_id'];
    _notificationID = json['notificationID'];
    _title = json['title'];
    _type = json['type'];
    _message = json['message'];
    _readCount = json['readCount'];
    _scheduledFor = json['scheduledFor'];
    _expiresAt = json['expiresAt'];
    _createdAt = json['createdAt'];
    _createdBy = json['createdBy'];
    _isRead = json['isRead'];
    _readAt = json['readAt'] != null ? DateTime.parse(json['readAt']) : null; // Parse the date-time string
    _userNotificationID = json['userNotificationID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this._sId;
    data['notificationID'] = this._notificationID;
    data['title'] = this._title;
    data['type'] = this._type;
    data['message'] = this._message;
    data['readCount'] = this._readCount;
    data['scheduledFor'] = this._scheduledFor;
    data['expiresAt'] = this._expiresAt;
    data['createdAt'] = this._createdAt;
    data['createdBy'] = this._createdBy;
    data['isRead'] = this._isRead;
    data['readAt'] = this.readAt?.toIso8601String(); // Convert DateTime to string
    data['userNotificationID'] = this._userNotificationID;
    return data;
  }
}
