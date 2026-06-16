import 'package:actpod_web/dto/package_dto.dart';

class GetPackagesRes {
  String code;
  String message;
  List<PackageInfoItem>? packages;

  GetPackagesRes(this.code, this.message, this.packages);

  factory GetPackagesRes.fromJson(Map<String, dynamic> json) {
    return GetPackagesRes(
      json["code"],
      json["message"],
      json["data"]
          ?.map<PackageInfoItem>((json) => PackageInfoItem.fromJson(json))
          .toList(),
    );
  }
}
