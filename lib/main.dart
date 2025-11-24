import 'package:actpod_web/api_manager/user_api_manager.dart';
import 'package:actpod_web/api_manager/user_dto/create_login.dart';
import 'package:actpod_web/api_manager/user_dto/get_user_info.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/player_page/player_screen.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/router.dart';
import 'package:actpod_web/services/env_service.dart';
import 'package:actpod_web/utils/cookie_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC98t3s2itcyGLZW1CaZhl_HhblEwwOZBk",
      authDomain: "share-voice-77cc4.firebaseapp.com",
      projectId: "share-voice-77cc4",
      appId: "1:633262239415:web:a015a02dbabf75c523e732",
      messagingSenderId: "633262239415",
    )
  );

  await EnvService.load();
  setUrlStrategy(PathUrlStrategy());
  GoRouter.optionURLReflectsImperativeAPIs = true;

  UserPrefs.cleanUser();
  CookieUtils.deleteCookie("userToken");
  
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  await FirebaseAuth.instance.authStateChanges().first;
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser != null) {
    CreateNewUserRes res = await userApiManager.thirdPartyCreateUserOrLogin(
      await firebaseUser.getIdToken(), 
      firebaseUser.email, 
      firebaseUser.displayName,
    );
    if(res.code != "0000") {
      print(res.message);
    } else {
      CookieUtils.setCookie("userToken", res.data?.userToken?? "", expires: DateTime.now().add(const Duration(hours: 6)));
    }

    GetUserInfoRes userInfoRes = await userApiManager.getUserInfo();
    if(userInfoRes.code != "0000") {
      print(userInfoRes.message);
    } else {
      UserPrefs.setUserInfo(userInfoRes.userInfo);
    }
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (BuildContext context, Widget? child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.white,
              primary: DesignColor.primary50
            ),
            fontFamily: 'NotoSansTC',
          ),
          title: 'ActPod',
          color: Colors.white,
          // routerConfig: myRouter,
          routerDelegate: myRouter.routerDelegate,
          routeInformationParser: myRouter.routeInformationParser,
          routeInformationProvider: myRouter.routeInformationProvider,
        );
      }
    );
  }
}
