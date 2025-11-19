import 'package:actpod_web/api_manager/comment_dto/create_comment_res.dart';
import 'package:actpod_web/api_manager/comment_dto/create_reply_res.dart';
import 'package:actpod_web/api_manager/comment_dto/delete_comment_res.dart';
import 'package:actpod_web/api_manager/comment_dto/get_comment_list_res.dart';
import 'package:actpod_web/api_manager/comment_dto/get_reply_list_res.dart';
import 'package:actpod_web/api_manager/comment_dto/get_story_stat_res.dart';
import 'package:dio/dio.dart';

import 'abstractApiManager.dart';

final commentApiManager = CommentApiManager(systemName: "COMMENT_SERVER_URL");

class CommentApiManager extends AbstractApiManager {

  CommentApiManager({required String systemName}) : super(systemName: systemName);

  Future<GetStoryStatRes> getStoryStat(String storyId) async {
    Response response = await handelGet("/comment/storyStat/story/$storyId");
    return GetStoryStatRes.fromJson(response.data);
  }

  Future<GetCommentListRes> getCommentList(String storyId) async {
    Response response = await handelGet("/comment/story/$storyId");
    return GetCommentListRes.fromJson(response.data);
  }

  Future<CreateCommentRes> createComment(String storyId, String content, int sendTiming) async {
    var postData = {
      "storyId": storyId,
      "content": content,
      "sendTiming": sendTiming
    };
    Response response;
    response = await handelPostWithUserToken("/comment", postData);
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

  Future<GetReplyByCommentRes> getReplyListByComment(String commentId) async {
    Response response = await handelGet("/comment/reply/$commentId");
    return GetReplyByCommentRes.fromJson(response.data);
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

  Future<GetInstantCommentListRes> getInstantCommentList(String storyId) async {
    Response response = await handelGet("/comment/instant/$storyId");
    return GetInstantCommentListRes.fromJson(response.data);
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
}