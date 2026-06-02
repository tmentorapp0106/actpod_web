import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quick_share_app/services/upgrade_service.dart';

import '../apiManagers/story_api_dto/get_one_story_res.dart';
import '../apiManagers/story_system_api_manager.dart';
import '../dto/player_item_dto.dart';
import '../router.dart';
import 'app_service.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  var payloadData = message.data;
  await AppReady.instance.waitUntilReady(); // handle initial app case
  if(payloadData["type"] == "story") {
    router.go("/");
    await Future.delayed(const Duration(seconds: 1));
    if(needUpgrade) return;
    if(payloadData["story_id"] == null || payloadData["story_id"] == "") {
      return;
    }
    GetOneStoryRes storyRes = await storyApiManager.getOneStory(payloadData["story_id"]);
    if(storyRes.code != "0000") {
      return;
    }
    PlayerItemDto playItem = PlayerItemDto.fromGetOneStoryResItem(storyRes.story!);
    List<PlayerItemDto> playList = [playItem];
    router.push("/story/multiple", extra: {"playerItemList": playList, "index": 0});
  } else if(payloadData["type"] == "voice_message") {
    router.go("/");
    await Future.delayed(const Duration(seconds: 1));
    if(needUpgrade) return;
    String collaboratorIdParam = payloadData["collaborator_id"] == ""? "null" : payloadData["collaborator_id"];
    router.push("/voiceMessage/story/${payloadData["story_id"]}/owner/${payloadData["story_owner_id"]}/collaborator/$collaboratorIdParam");
  } else if(payloadData["type"] == "live") {
    router.go("/");
    await Future.delayed(const Duration(seconds: 1));
    if(needUpgrade) return;
    String liveType = payloadData["live_type"] == ""? "null" : payloadData["live_type"];
    String roomId = payloadData["room_id"] == ""? "null" : payloadData["room_id"];
    String storyId = payloadData["story_id"] == ""? "null" : payloadData["story_id"];
    router.push("/live/$liveType/audience/$roomId/$storyId");
  }
}

Future<void> onSelectNotification(NotificationResponse notificationResponse) async {
  var payloadData = jsonDecode(notificationResponse.payload!);
  await AppReady.instance.waitUntilReady();// handle initial app case
  if(payloadData["type"] == "story") {
    if(payloadData["story_id"] == null || payloadData["story_id"] == "") {
      return;
    }
    router.go("/");
    await Future.delayed(const Duration(seconds: 1));
    if(needUpgrade) return;
    GetOneStoryRes storyRes = await storyApiManager.getOneStory(payloadData["story_id"]);
    if(storyRes.code != "0000") {
      return;
    }
    PlayerItemDto playItem = PlayerItemDto.fromGetOneStoryResItem(storyRes.story!);
    List<PlayerItemDto> playList = [playItem];
    router.push("/story/multiple", extra: {"playerItemList": playList, "index": 0});
  } else if(payloadData["type"] == "voice_message") {
    router.go("/");
    await Future.delayed(const Duration(seconds: 1));
    if(needUpgrade) return;
    String collaboratorIdParam = payloadData["collaborator_id"] == ""? "null" : payloadData["collaborator_id"];
    router.push("/voiceMessage/story/${payloadData["story_id"]}/owner/${payloadData["story_owner_id"]}/collaborator/$collaboratorIdParam");
  } else if(payloadData["type"] == "live") {
    router.go("/");
    await Future.delayed(const Duration(seconds: 1));
    if(needUpgrade) return;
    String liveType = payloadData["live_type"] == ""? "null" : payloadData["live_type"];
    String roomId = payloadData["room_id"] == ""? "null" : payloadData["room_id"];
    String storyId = payloadData["story_id"] == ""? "null" : payloadData["story_id"];
    router.push("/live/$liveType/audience/$roomId/$storyId");
  }
}

class FCMService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = const AndroidNotificationChannel(
    "actpod_high_importance_channel",
    "actpod_high_importance_channel",
    description: "actpod_high_importance_channel",
    importance: Importance.max,
  );
  final _localNotification = FlutterLocalNotificationsPlugin();

  Future<void> handleMessage(RemoteMessage? message) async {
    if(message == null) {
      return;
    }
    await AppReady.instance.waitUntilReady();// handle initial app case
    var payloadData = message.data;
    if(payloadData["type"] == "story") {
      if(payloadData["story_id"] == null || payloadData["story_id"] == "") {
        return;
      }
      router.go("/");
      await Future.delayed(const Duration(seconds: 1));
      if(needUpgrade) return;
      GetOneStoryRes storyRes = await storyApiManager.getOneStory(payloadData["story_id"]);
      if(storyRes.code != "0000") {
        return;
      }
      PlayerItemDto playItem = PlayerItemDto.fromGetOneStoryResItem(storyRes.story!);
      List<PlayerItemDto> playList = [playItem];
      router.push("/story/multiple", extra: {"playerItemList": playList, "index": 0});
    } else if(payloadData["type"] == "voice_message") {
      router.go("/");
      await Future.delayed(const Duration(seconds: 1));
      if(needUpgrade) return;
      String collaboratorIdParam = payloadData["collaborator_id"] == ""? "null" : payloadData["collaborator_id"];
      router.push("/voiceMessage/story/${payloadData["story_id"]}/owner/${payloadData["story_owner_id"]}/collaborator/$collaboratorIdParam");
    } else if(payloadData["type"] == "live") {
      router.go("/");
      await Future.delayed(const Duration(seconds: 1));
      if(needUpgrade) return;
      String liveType = payloadData["live_type"] == ""? "null" : payloadData["live_type"];
      String roomId = payloadData["room_id"] == ""? "null" : payloadData["room_id"];
      String storyId = payloadData["story_id"] == ""? "null" : payloadData["story_id"];
      router.push("/live/$liveType/audience/$roomId/$storyId");
    }
  }

  void handleForegroundMessage(RemoteMessage message) {
    if(Platform.isAndroid) {
      _localNotification.show(
          id: message.notification.hashCode,
          title: message.notification?.title,
          body: message.notification?.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
                _androidChannel.id,
                _androidChannel.name,
                channelDescription: _androidChannel.description,
                icon: '@drawable/ic_stat_actpod',
                importance: Importance.max,
                priority: Priority.max
            ),
          ),
          payload: jsonEncode(message.data)
      );
    }
  }

  Future<void> initPushNotifications() async {
    _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true
    );
    _firebaseMessaging.getInitialMessage().then(handleMessage); // when resumed from background
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage); // when resumed form terminated
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen(handleForegroundMessage);
  }

  Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings("@drawable/ic_stat_actpod");
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotification.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: onSelectNotification,
      onDidReceiveBackgroundNotificationResponse: onSelectNotification
    );

    final androidPlugin = _localNotification
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_androidChannel);
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    initLocalNotifications();
    initPushNotifications();
  }
}