class GetStickersRes {
  String code;
  String message;
  List<GetStickersResItem> stickerList;

  GetStickersRes(this.code, this.message, this.stickerList);

  factory GetStickersRes.fromJson(Map<String, dynamic> json) {
    return GetStickersRes(
      json["code"],
      json["message"],
      json["data"] == null? [] : json["data"]?.map<GetStickersResItem>((json) => GetStickersResItem.fromJson(json)).toList()
    );
  }
}

class GetStickersResItem {
  String name;
  String stickerUrl;
  int podCoins;

  GetStickersResItem(this.name, this.stickerUrl, this.podCoins);

  factory GetStickersResItem.fromJson(Map<String, dynamic> json) {
    return GetStickersResItem(
      json["name"],
      json["stickerUrl"],
      json["podCoins"]
    );
  }
}