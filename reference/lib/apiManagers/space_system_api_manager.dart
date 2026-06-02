import 'dart:io';

import 'package:dio/dio.dart';
import 'package:quick_share_app/apiManagers/space_api_dto/get_active_boards_res.dart';
import 'package:quick_share_app/apiManagers/space_api_dto/get_board_stories_res.dart';

import 'abstractApiManager.dart';

final spaceApiManager = SpaceApiManager(systemName: "SPACE_SERVER_URL");

class SpaceApiManager extends AbstractApiManager {

  SpaceApiManager({required String systemName}) : super(systemName: systemName);

  Future<GetActiveSpacesRes> getActiveSpaces() async {
    Response response = await handelGet("");
    return GetActiveSpacesRes.fromJson(response.data);
  }
  
  Future<GetSpaceStoriesRes> getSpaceStories(String spaceId) async {
    Response response = await handelGet("/spaceStories/$spaceId");
    return GetSpaceStoriesRes.fromJson(response.data);
  }

  // Future<SpaceApplicationRes> sendBoardApplication(File imageFile, String name, String description) async {
  //   var formData = FormData.fromMap({
  //     "boardImage": await MultipartFile.fromFile(imageFile.path),
  //     "boardName": name,
  //     "boardDescription": description
  //   });
  //
  //   Response response = await handelPostWithUserToken("/boardApplication/create", formData);
  //   return SpaceApplicationRes.fromJson(response.data);
  // }
}