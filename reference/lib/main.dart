import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_meta_sdk/flutter_meta_sdk.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quick_share_app/apiManagers/purchase_system_api_manager.dart';
import 'package:quick_share_app/objectbox.g.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/router.dart';
import 'package:quick_share_app/services/announcement_service.dart';
import 'package:quick_share_app/services/app_service.dart';
import 'package:quick_share_app/services/audio_service.dart';
import 'package:quick_share_app/services/cache_service.dart';
import 'package:quick_share_app/services/env_service.dart';
import 'package:quick_share_app/services/fcm_service.dart';
import 'package:quick_share_app/services/language_service.dart';
import 'package:quick_share_app/services/link_service.dart';
import 'package:quick_share_app/services/remote_config_service.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:quick_share_app/shared_prefs/agreement_prefs.dart';
import 'package:quick_share_app/shared_prefs/announcement_prefs.dart';
import 'package:quick_share_app/shared_prefs/dislike_story_prefs.dart';
import 'package:quick_share_app/shared_prefs/hide_prefs.dart';
import 'package:quick_share_app/shared_prefs/rating_prefs.dart';
import 'package:quick_share_app/shared_prefs/record_backup_prefs.dart';
import 'package:quick_share_app/shared_prefs/server_prefs.dart';
import 'package:quick_share_app/shared_prefs/tutorial_prefs.dart';
import 'package:quick_share_app/shared_prefs/user_prefs.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './l10n/app_localizations.dart';

import 'apiManagers/notification_system_api_manager.dart';
import 'apiManagers/user_api_dto/create_new_user_res.dart';

ActPodAudioHandler? actPodAudioHandler;

final GoogleSignIn googleSignIn = GoogleSignIn();

late final Store store;
CreateNewUserResData? loginInfo;

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // only upright portrait
  ]);

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark
    ),
  );

  await FlutterDownloader.initialize(
      // debug: true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl: true // option: set to false to disable working with http links (default: false)
  );

  await Firebase.initializeApp();
  await RemoteConfigService.instance.init();

  store = await openStore();
  LinkService.initUniLinks();
  FCMService().initNotifications();
  await AnnouncementPrefs.init();
  await UserPrefs.init();
  await AgreementPrefs.init();
  await DislikeStoryPrefs.init();
  await ServerPrefs.init();
  await TutorialPrefs.init();
  await RecordBackupPrefs.init();
  await HidePrefs.init();
  await RatingPrefs.init();
  await EnvService.load();
  PurchaseSystemApi.init();
  AnnouncementService.loadAnnouncements();

  FlutterMetaSdk().setAdvertiserTracking(enabled: true);

  User? firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser != null) {
    try {
      String? idToken = await firebaseUser.getIdToken();
      await UserService.thirdPartyCreateUserOrLogin(idToken?? "", firebaseUser.email, "");
      await UserService.loadUserInfo(null);
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      notificationApiManager.insertToken(UserService.getUserInfo()!.userId, fcmToken);
      PurchaseSystemApi.login(UserService.getUserInfo()!.userId);
    } catch (e) {
      UserService.logoutUser(null);
      print("Error: $e");
    }
  }
  else {
    UserService.logoutUser(null);
  }

  await CacheService.cleanAudioCache();

  actPodAudioHandler = await initAudioService();

  FlutterNativeSplash.remove();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppReady.instance.markReady();
      ref.watch(localeProvider.notifier).state = LanguageService.loadLanguage();
    });
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (BuildContext context, Widget? child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          ),
          title: 'ActPod',
          color: Colors.white,
          supportedLocales: const [
            Locale('en', ''),      // English
            Locale('zh', 'TW'),    // Traditional Chinese
          ],
          locale: ref.watch(localeProvider),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          routerConfig: router
        );
      },
    );
  }
}
