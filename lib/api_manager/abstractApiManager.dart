import 'dart:core';
import 'dart:developer' as developer;

import 'package:actpod_web/exceptions/exceptions.dart';
import 'package:actpod_web/utils/cookie_utils.dart';
import 'package:dio/dio.dart' as pdio;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AbstractApiManager {
  late String systemName;
  AbstractApiManager({required this.systemName});

  Future<dynamic> handelGet(String path) async {
    pdio.Dio newDio = new pdio.Dio();

    try {
      return await newDio.get(dotenv.env[systemName]! + path);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<dynamic> handelGetWithUserToken(String path) async {
    pdio.Dio dio = new pdio.Dio();
    if(CookieUtils.getCookie("userToken") == null || CookieUtils.getCookie("userToken") == "") {
      throw TokenMissedException("User Token Missed");
    }
    dio.options.headers["userToken"] = CookieUtils.getCookie("userToken");

    pdio.Response res;
    try {
      res = await dio.get(dotenv.env[systemName]! + path);
    } on DioError catch (e) {
      if (e.response != null) {
        // Specific handling for 401 status code
        if (e.response?.statusCode == 401) {
          throw TokenExpiredException("User Token Expired");
        }
      }
      print(e);
      rethrow;
    } catch (e) {
      print(e);
      throw e;
    }

    return res;
  }

  Future<dynamic> handelPost(String path, dynamic body) async  {
    pdio.Dio dio = new pdio.Dio();

    try {
      return await dio.post(dotenv.env[systemName]! + path, data: body);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<dynamic> handelPostWithUserToken(String path, dynamic body) async  {
    pdio.Dio dio = new pdio.Dio();
    if(CookieUtils.getCookie("userToken") == null || CookieUtils.getCookie("userToken") == "") {
      throw TokenMissedException("User Token Missed");
    }
    dio.options.headers["userToken"] = CookieUtils.getCookie("userToken");

    pdio.Response res;
    try {
      res = await dio.post(dotenv.env[systemName]! + path, data: body);
    } on DioError catch (e) {
      if (e.response != null) {
        // Specific handling for 401 status code
        if (e.response?.statusCode == 401) {
          throw TokenExpiredException("User Token Expired");
        }
      }
      print(e);
      rethrow;
    } catch (e) {
      print(e);
      throw e;
    }

    if(res.data["code"] == "0005") {
      throw TokenExpiredException("User Token Expired");
    }
    return res;
  }

  // Future<dynamic> handelPatchWithUserToken(String path, dynamic body) async  {
  //   pdio.Dio dio = new pdio.Dio();
  //   if(UserService.getUserToken() == null || UserService.getUserToken() == "") {
  //     throw TokenMissedException("User Token Missed");
  //   }
  //   dio.options.headers["userToken"] = UserService.getUserToken();

  //   pdio.Response res;
  //   try {
  //     res = await dio.patch(dotenv.env[systemName]! + path, data: body);
  //   } on DioError catch (e) {
  //     if (e.response != null) {
  //       // Specific handling for 401 status code
  //       if (e.response?.statusCode == 401) {
  //         if(await refreshUserToken()) {
  //           if(body is FormData) {
  //             FormData formData = FormData();
  //             formData.fields.addAll(body.fields);
  //             for (MapEntry mapFile in body.files) {
  //               formData.files.add(MapEntry(
  //                   mapFile.key,
  //                   MultipartFile.fromFileSync(mapFile.value.filePath,
  //                       filename: mapFile.value.filename)));
  //             }
  //             return await handelPostWithUserToken(path, formData);
  //           } else {
  //             return await handelPostWithUserToken(path, body);
  //           }
  //         }
  //       }
  //     }
  //     print(e);
  //     rethrow;
  //   } catch (e) {
  //     print(e);
  //     throw e;
  //   }

  //   if(res.data["code"] == "0005") {
  //     if(await refreshUserToken()) {
  //       if(body is FormData) {
  //         FormData formData = FormData();
  //         formData.fields.addAll(body.fields);
  //         for (MapEntry mapFile in body.files) {
  //           formData.files.add(MapEntry(
  //               mapFile.key,
  //               MultipartFile.fromFileSync(mapFile.value.filePath,
  //                   filename: mapFile.value.filename)));
  //         }
  //         return await handelPostWithUserToken(path, formData);
  //       } else {
  //         return await handelPostWithUserToken(path, body);
  //       }
  //     }
  //   }
  //   return res;
  // }

  // Future<bool> refreshUserToken() async {
  //   String? userRefreshToken = UserPrefs.getRefreshToken();

  //   dynamic postData = {
  //     "refreshToken": userRefreshToken
  //   };

  //   // can't use specific apiUrl, so use env directly here
  //   pdio.Dio dio = new pdio.Dio();
  //   pdio.Response? res = await dio.post("${dotenv.env["USER_SERVER_URL"]!}/token/refresh", data: postData);

  //   if(res.data["code"] != "0000") {
  //     await UserService.logoutUser();
  //     if(finishInitMounted) {
  //       showDialog(
  //         context: rootNavigatorKey.currentContext!,
  //         builder: (context) {
  //           return LoginPageScreen();
  //         }
  //       );
  //     }
  //     return false;
  //   }

  //   await UserPrefs.setUserToken(res.data["data"]["userToken"]);
  //   await UserPrefs.setRefreshToken(res.data["data"]["refreshToken"]);
  //   return true;
  // }
}
