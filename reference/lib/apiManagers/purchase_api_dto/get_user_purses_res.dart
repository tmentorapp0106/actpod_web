class GetUserPursesRes {
  String code;
  String message;
  GetUserPursesItem? purses;

  GetUserPursesRes(this.code, this.message, this.purses);

  factory GetUserPursesRes.fromJson(Map<String, dynamic> json) {
    return GetUserPursesRes(
      json["code"] as String,
      json["message"] as String,
      json["data"] != null ? GetUserPursesItem.fromJson(json["data"]) : null, // Handle null case
    );
  }
}

class GetUserPursesItem {
  PodCoinsPurse coinsPurse;
  PodCashPurse cashPurse;

  GetUserPursesItem(this.coinsPurse, this.cashPurse);

  factory GetUserPursesItem.fromJson(Map<String, dynamic> json) {
    return GetUserPursesItem(
      PodCoinsPurse.fromJson(json["coinsPurse"]),
      PodCashPurse.fromJson(json["cashPurse"]),
    );
  }
}

class PodCoinsPurse {
  String userId;
  int podCoins;
  DateTime updateTime;

  PodCoinsPurse(this.userId, this.podCoins, this.updateTime);

  factory PodCoinsPurse.fromJson(Map<String, dynamic> json) {
    return PodCoinsPurse(
      json["userId"] as String,
      json["podCoins"] as int,
      DateTime.parse(json["updateTime"]),
    );
  }
}

class PodCashPurse {
  String userId;
  int podCash;
  DateTime updateTime;

  PodCashPurse(this.userId, this.podCash, this.updateTime);

  factory PodCashPurse.fromJson(Map<String, dynamic> json) {
    return PodCashPurse(
      json["userId"] as String,
      json["podCash"] as int,
      DateTime.parse(json["updateTime"]),
    );
  }
}
