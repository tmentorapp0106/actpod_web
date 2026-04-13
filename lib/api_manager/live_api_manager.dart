import 'package:actpod_web/api_manager/abstractApiManager.dart';
import 'package:actpod_web/api_manager/live_dto/get_bulletins.dart';
import 'package:actpod_web/api_manager/live_dto/get_chats.dart';
import 'package:actpod_web/api_manager/live_dto/get_livekit_status.dart';
import 'package:actpod_web/api_manager/live_dto/get_members.dart';
import 'package:actpod_web/api_manager/live_dto/get_player.dart';
import 'package:actpod_web/api_manager/live_dto/get_room_info.dart';
import 'package:actpod_web/api_manager/live_dto/get_stickers.dart';
import 'package:actpod_web/api_manager/live_dto/get_token.dart';
import 'package:dio/dio.dart';

final liveApiManager = LiveApiManager(systemName: "LIVE_SERVER_URL");

class LiveApiManager extends AbstractApiManager {

  LiveApiManager({required String systemName}) : super(systemName: systemName);

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

  Future<GetRoomStickersRes> getStickers() async {
    Response response = await handelGet("/live/room/stickers");
    return GetRoomStickersRes.fromJson(response.data);
  }

  Future<GetRoomPlayerRes> getRoomPlayer(String roomId) async {
    Response response = await handelGet("/live/room/player/$roomId");
    return GetRoomPlayerRes.fromJson(response.data);
  }
}