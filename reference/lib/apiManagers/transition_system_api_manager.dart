import 'package:dio/dio.dart';
import 'package:quick_share_app/apiManagers/transition_api_dto/create_transition_res.dart';
import 'package:quick_share_app/apiManagers/transition_api_dto/delete_transition_res.dart';
import 'package:quick_share_app/apiManagers/transition_api_dto/get_transitions_res.dart';
import 'package:quick_share_app/services/user_service.dart';

import 'abstractApiManager.dart';

final transitionApiManager = TransitionApiManager(systemName: "TRANSITION_SERVER_URL");

class TransitionApiManager extends AbstractApiManager {

  TransitionApiManager({required String systemName}) : super(systemName: systemName);

  Future<CreateTransitionRes> createTransition(String name, String url, int length) async {
    var data = {
      "name": name,
      "url": url,
      "length": length
    };

    Response response = await handelPostWithUserToken("", data);
    return CreateTransitionRes.fromJson(response.data);
  }

  Future<DeleteTransitionRes> deleteTransition(String transitionId) async {
    var data = {
      "transitionId": transitionId
    };

    Response response = await handelPostWithUserToken("", data);
    return DeleteTransitionRes.fromJson(response.data);
  }

  Future<GetTransitionListRes> getTransitionList() async {
    Response response = await handelGetWithUserToken("");
    return GetTransitionListRes.fromJson(response.data);
  }
}