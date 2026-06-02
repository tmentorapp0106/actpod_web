import 'package:dio/dio.dart';
import 'package:quick_share_app/apiManagers/comment_api_dto/delete_comment_res.dart';
import 'package:quick_share_app/apiManagers/comment_api_dto/increase_like_res.dart';
import 'package:quick_share_app/apiManagers/comment_api_dto/get_stickers_res.dart';
import 'package:quick_share_app/apiManagers/comment_api_dto/inseret_comment_res.dart';
import 'package:quick_share_app/services/user_service.dart';

import 'abstractApiManager.dart';
import 'comment_api_dto/check_exist_res.dart';
import 'comment_api_dto/create_reply_res.dart';
import 'comment_api_dto/decrease_likes_res.dart';
import 'comment_api_dto/get_comment_list_res.dart';
import 'comment_api_dto/get_reply_by_comment_res.dart';
import 'comment_api_dto/get_story_stat_res.dart';

final commentApiManager = CommentApiManager(systemName: "COMMENT_SERVER_URL");

class CommentApiManager extends AbstractApiManager {

  CommentApiManager({required String systemName}) : super(systemName: systemName);

  Future<CreateCommentRes> createComment(String storyId, String content, int sendTiming) async {
    var postData = {
      "storyId": storyId,
      "content": content,
      "sendTiming": sendTiming
    };

    Response response = await handelPostWithUserToken("/comment", postData);
    return CreateCommentRes.fromJson(response.data);
  }

  Future<CreateCommentRes> createInstantComment(String storyId, String content, int sendSecond, int podcoins) async {
    var postData = {
      "storyId": storyId,
      "content": content,
      "sendSecond": sendSecond,
      "podcoins": podcoins
    };

    Response response = await handelPostWithUserToken("/comment/instant", postData);
    return CreateCommentRes.fromJson(response.data);
  }

  Future<CreateCommentRes> createSuperComment(String storyId, String content, int sendTiming, int podCoins) async {
    var postData = {
      "storyId": storyId,
      "content": content,
      "sendTiming": sendTiming,
      "podCoins": podCoins
    };

    Response response = await handelPostWithUserToken("/comment/super", postData);
    return CreateCommentRes.fromJson(response.data);
  }

  Future<GetCommentListRes> getCommentList(String storyId) async {
    Response response = await handelGet("/comment/story/$storyId");
    return GetCommentListRes.fromJson(response.data);
  }

  Future<GetInstantCommentListRes> getInstantCommentList(String storyId) async {
    Response response = await handelGet("/comment/instant/$storyId");
    return GetInstantCommentListRes.fromJson(response.data);
  }

  Future<CreateReplyRes> createReply(String storyId, String commentId, String userId, String replyType, String content) async {
    var postData = {
      "storyId": storyId,
      "commentId": commentId,
      "replyType": replyType,
      "content": content
    };

    Response response = await handelPostWithUserToken("/comment/reply", postData);
    return CreateReplyRes.fromJson(response.data);
  }

  Future<CreateInstantReplyRes> createInstantReply(String commentId, String content) async {
    var postData = {
      "commentId": commentId,
      "content": content
    };

    Response response = await handelPostWithUserToken("/comment/instant/reply", postData);
    return CreateInstantReplyRes.fromJson(response.data);
  }

  Future<GetReplyByCommentRes> getReplyListByComment(String commentId) async {
    Response response = await handelGet("/comment/reply/$commentId");
    return GetReplyByCommentRes.fromJson(response.data);
  }

  Future<GetInstantReplyByCommentRes> getInstantReplyList(String commentId) async {
    Response response = await handelGet("/comment/instant/reply/$commentId");
    return GetInstantReplyByCommentRes.fromJson(response.data);
  }

  Future<GetStoryStatRes> getStoryStat(String storyId) async {
    Response response = await handelGet("/comment/storyStat/story/$storyId");
    return GetStoryStatRes.fromJson(response.data);
  }

  Future<CheckExistRes> checkLikeExist(String storyId, String userId) async {
    Response response = await handelGetWithUserToken("/like/story/$storyId/user/$userId/exist");
    return CheckExistRes.fromJson(response.data);
  }

  Future<IncreaseLikeRes> increaseLikes(String storyId, String userId, String storyOwnerId) async {
    var postData = {
      "storyId": storyId,
      "userId": userId,
      "storyOwnerId": storyOwnerId
    };

    Response response = await handelPostWithUserToken("/like/increase", postData);
    return IncreaseLikeRes.fromJson(response.data);
  }

  Future<DecreaseLikesRes> decreaseLikes(String storyId, String userId) async {
    var postData = {
      "storyId": storyId,
      "userId": userId
    };

    Response response = await handelPostWithUserToken("/like/decrease", postData);
    return DecreaseLikesRes.fromJson(response.data);
  }
  
  Future<DeleteCommentRes> deleteComment(String commentId) async {
    var data = {
      "commentId": commentId
    };
    
    Response response = await handelPostWithUserToken("/comment/delete", data);
    return DeleteCommentRes.fromJson(response.data);
  }

  Future<DeleteCommentRes> deleteInstantComment(String storyId, String commentId) async {
    var data = {
      "storyId": storyId,
      "commentId": commentId
    };

    Response response = await handelPostWithUserToken("/comment/instant/delete", data);
    return DeleteCommentRes.fromJson(response.data);
  }

  Future<DeleteCommentRes> deleteInstantReply(String commentId, String replyId) async {
    var data = {
      "replyId": replyId,
      "commentId": commentId
    };

    Response response = await handelPostWithUserToken("/comment/instant/reply/delete", data);
    return DeleteCommentRes.fromJson(response.data);
  }

  Future<GetStickersRes> getStickers() async {
    Response response = await handelGet("/sticker/list");
    return GetStickersRes.fromJson(response.data);
  }
}