import 'package:dio/dio.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/create_background_music.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/create_room_bulletin.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/exist_ticket.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_active_rooms.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_livekit_status.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_room_bulletins.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_room_chats.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_room_info.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_room_members.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_room_player.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_room_token.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_user_background_music.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/update_room_bulletin.dart';
import 'package:quick_share_app/services/user_service.dart';

import 'abstractApiManager.dart';
import 'live_api_dto/delete_room_bulletin.dart';
import 'live_api_dto/get_price_rule.dart';
import 'live_api_dto/get_stickers.dart';

final liveApiManager = LiveApiManager(systemName: "LIVE_SERVER_URL");

class LiveApiManager extends AbstractApiManager {

  LiveApiManager({required String systemName}) : super(systemName: systemName);

  Future<GetActiveRoomsRes> getActiveRooms() async {
    Response response = await handelGet("/live/activeRooms");
    return GetActiveRoomsRes.fromJson(response.data);
  }

  Future<GetRoomInfoRes> getRoomInfo(String roomId) async {
    Response response = await handelGet("/live/room/$roomId");
    return GetRoomInfoRes.fromJson(response.data);
  }

  Future<GetRoomMembersRes> getRoomMembers(String roomId) async {
    Response response = await handelGet("/live/room/members/$roomId");
    return GetRoomMembersRes.fromJson(response.data);
  }

  Future<GetRoomChatsRes> getRoomChats(String roomId) async {
    Response response = await handelGet("/live/room/chats/$roomId");
    return GetRoomChatsRes.fromJson(response.data);
  }

  Future<GetRoomTokenRes> getRoomToken(String roomId, String userId) async {
    Response response = await handelGet("/live/room/token?room=$roomId&userId=$userId");
    return GetRoomTokenRes.fromJson(response.data);
  }

  Future<GetLivekitStatusRes> getLivekitStatus(String roomId) async {
    Response response = await handelGet("/live/room/livekitStatus/$roomId");
    return GetLivekitStatusRes.fromJson(response.data);
  }

  Future<GetRoomBulletins> getRoomBulletins(String roomId) async {
     Response response = await handelGet("/live/room/bulletins/$roomId");
     return GetRoomBulletins.fromJson(response.data);
  }
  
  Future<CreateRoomBulletinRes> createRoomBulletin(String roomId, String title, String content, List<String> imageUrls) async {
    var data = {
      "roomId": roomId,
      "title": title,
      "content": content,
      "imageUrls": imageUrls
    };
    Response response = await handelPostWithUserToken("/live/room/bulletin/create", data);
    return CreateRoomBulletinRes.fromJson(response.data);
  }

  Future<UpdateRoomBulletinRes> updateRoomBulletin(String bulletinId, String title, String content, List<String> imageUrls) async {
    var data = {
      "bulletinId": bulletinId,
      "title": title,
      "content": content,
      "imageUrls": imageUrls
    };
    Response response = await handelPostWithUserToken("/live/room/bulletin/update", data);
    return UpdateRoomBulletinRes.fromJson(response.data);
  }

  Future<DeleteRoomBulletinRes> deleteRoomBulletin(String bulletinId) async {
    var data = {
      "bulletinId": bulletinId,
    };
    Response response = await handelPostWithUserToken("/live/room/bulletin/delete", data);
    return DeleteRoomBulletinRes.fromJson(response.data);
  }

  Future<GetRoomStickersRes> getStickers() async {
    Response response = await handelGet("/live/room/stickers");
    return GetRoomStickersRes.fromJson(response.data);
  }

  Future<GetRoomPlayerRes> getRoomPlayer(String roomId) async {
    Response response = await handelGet("/live/room/player/$roomId");
    return GetRoomPlayerRes.fromJson(response.data);
  }

  Future<CreateBackgroundMusicRes> createBackgroundMusic(String name, String mp3Url, String oggUrl) async {
    var data = {
      "userId": UserService.getUserInfo()!.userId,
      "name": name,
      "mp3Url": mp3Url,
      "oggUrl": oggUrl
    };
    Response response = await handelPostWithUserToken("/live/room/backgroundMusic/create", data);
    return CreateBackgroundMusicRes.fromJson(response.data);
  }

  Future<GetUserBackgroundMusic> getBackgroundMusics() async {
    Response response = await handelGetWithUserToken("/live/room/backgroundMusics");
    return GetUserBackgroundMusic.fromJson(response.data);
  }

  Future<GetPriceRuleRes> getPriceRule(String roomId) async {
    Response response = await handelGet("/live/room/priceRule/$roomId");
    return GetPriceRuleRes.fromJson(response.data);
  }

  Future<ExistTicketRes> existTicket(String roomId, String userId) async {
    var data = {
      "roomId": roomId,
      "userId": userId
    };
    Response response = await handelPost("/live/room/existTicket", data);
    return ExistTicketRes.fromJson(response.data);
  }
}