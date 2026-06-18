import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/router.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:actpod_web/services/env_service.dart';
import 'package:actpod_web/services/meta_tracking_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MetaTrackingService.instance.init();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: "AIzaSyC98t3s2itcyGLZW1CaZhl_HhblEwwOZBk",
    authDomain: _firebaseAuthDomain(),
    projectId: "share-voice-77cc4",
    appId: "1:633262239415:web:a015a02dbabf75c523e732",
    messagingSenderId: "633262239415",
  ));

  await EnvService.load();
  setUrlStrategy(PathUrlStrategy());
  GoRouter.optionURLReflectsImperativeAPIs = true;
  await AuthService.prepareFirebaseAuth();

  runApp(const ProviderScope(child: MyApp()));
}

String _firebaseAuthDomain() {
  final host = Uri.base.host;
  if (host == "web.actpodapp.com" ||
      host.endsWith(".web.app") ||
      host.endsWith(".firebaseapp.com")) {
    return host;
  }
  return "web.actpodapp.com";
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
                seedColor: Colors.white, primary: DesignColor.primary50),
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
