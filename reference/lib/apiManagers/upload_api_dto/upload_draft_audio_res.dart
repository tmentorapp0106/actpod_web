class UploadDraftAudioRes {
  String code;
  String message;
  DraftAudioInfo? audioInfo;

  UploadDraftAudioRes({
    required this.code,
    required this.message,
    this.audioInfo,
  });

  /// Convert JSON to Dart object
  factory UploadDraftAudioRes.fromJson(Map<String, dynamic> json) {
    return UploadDraftAudioRes(
      code: json["code"],
      message: json["message"],
      audioInfo: json["data"] != null ? DraftAudioInfo.fromJson(json["data"]) : null,
    );
  }

  /// Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      "code": code,
      "message": message,
      "data": audioInfo?.toJson(), // Convert only if not null
    };
  }
}

class DraftAudioInfo {
  String publicUrl;
  String signedUrl;
  String draftId;

  DraftAudioInfo({
    required this.publicUrl,
    required this.signedUrl,
    required this.draftId,
  });

  /// Convert JSON to Dart object
  factory DraftAudioInfo.fromJson(Map<String, dynamic> json) {
    return DraftAudioInfo(
      publicUrl: json["publicUrl"],
      signedUrl: json["signedUrl"],
      draftId: json["draftId"],
    );
  }

  /// Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      "publicUrl": publicUrl,
      "signedUrl": signedUrl,
      "draftId": draftId,
    };
  }
}