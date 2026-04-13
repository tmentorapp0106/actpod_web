import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/live_page/controllers/room_controller.dart';
import 'package:actpod_web/features/live_page/providers/room.dart';
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/features/player_page/components/launch_deep_link_dialog.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class ListenOnlyScreen extends ConsumerStatefulWidget {
  final String roomId;

  const ListenOnlyScreen({required this.roomId});

  @override
  _ListenOnlyScreenState createState() => _ListenOnlyScreenState();
}

class _ListenOnlyScreenState extends ConsumerState<ListenOnlyScreen> {
  RoomController? roomController;

  @override
  void initState() {
    super.initState();
    roomController = RoomController(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      initProviders();
      roomController!.getRoomInfo(widget.roomId);
      await checkLogin();
      checkOpenDeepLink();
    });
  }

  Future<void> checkLogin() async {
    while (ref.read(userInfoProvider) == null) {
      final bool? loggedIn = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // prevent tap outside to close
        builder: (context) {
          return LoginScreen();
        },
      );

      // If dialog somehow closes without success, keep showing it
      if (loggedIn == true && ref.read(userInfoProvider) != null) {
        break;
      }
    }
  }

  Future<void> checkOpenDeepLink() async {
    String url;
    if(kIsWeb) {
      bool? goto = await showDialog<bool>(
        context: context,
        builder: (context) => LaunchDeepLinkDialog(),
      );
      if(goto != null && goto) {
        await Future.delayed(const Duration(microseconds: 500));
        url = "https://actpod-488af.web.app/story/link/${widget.roomId}?openExternalBrowser=1";
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          debugPrint("Could not launch $url");
        }
      }
    }
  }

  void initProviders() {
    ref.watch(userInfoProvider.notifier).state = UserPrefs.getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    bool isPhone = MediaQuery.of(context).size.width < 600;
    Widget body;
    final roomInfo = ref.watch(roomInfoProvider);
    if(roomInfo == null) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    } else if(roomInfo.roomId.isEmpty) {
      body = Center(
        child: Text(
          "找不到房間",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.w,
            fontWeight: FontWeight.bold
          ),
        ),
      );
    } else {
      body = isPhone? mobileScreen() : Center(
        child: Text("此頁面僅支援手機瀏覽器觀看"),
      );
    }
    return Scaffold(
      backgroundColor: DesignColor.background,
      body: SafeArea(
        child: SizedBox(
          height: ScreenUtil().screenHeight,
          child: body
        )
      ),
    );
  }

  Widget mobileScreen() {
    return Stack(
      children: [    
      ],
    );
  }
}