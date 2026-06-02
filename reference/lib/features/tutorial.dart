import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/shared_prefs/tutorial_prefs.dart';

import '../design_system/color.dart';

class Tutorial extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TutorialState();
  }
}

class TutorialState extends State<Tutorial> with TickerProviderStateMixin {
  PageController _pageViewController = PageController();
  TabController? _tabController;
  int _pageIndex = 0;
  final List<String> hintTexts = [
    "留下語音留言後，Podcaster 可以決定是否將您的留言加 Podcast 結尾。",
    "即時留言會在 Podcast 播放到對應時間點時跳出。",
    "無痛擴展新平台！貼上 RSS Feed，原有節目一鍵匯入，後續更新也會自動同步上架。"
  ];

  @override
  void initState() {
    super.initState();
    TutorialPrefs.setTutorialReadStats("read");
    _tabController = TabController(length: 3, vsync: this);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConfigColor.backgroundThird.withOpacity(0.65),
      body: Stack(
        children: [
          content(),
          close(),
          logo(),
          hintText(),
          nextButton()
        ]
      )
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    setState(() {
      _pageIndex = currentPageIndex;
    });
    _tabController!.index = currentPageIndex;
  }

  Widget nextButton() {
    return Positioned(
      right: 0,
      left: 0,
      bottom: 60.h,
      child: Center(
        child: TextButton(
          onPressed: () async {
            if(_pageIndex == 2) {
              Navigator.of(context).pop();
            } else {
              _pageViewController.animateToPage(_pageIndex + 1, duration: Duration(milliseconds: 500), curve: Curves.easeIn);
            }
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.only(bottom: 2.h),
            backgroundColor: DesignColor.actpodPrimary500,
            foregroundColor: DesignColor.actpodPrimary100,
            fixedSize: Size(104.w, 36.h),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.w), // Set the border radius here
            ),
          ),
          child: Text(
            _pageIndex == 2? "開始收聽" : "下一步",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp
            ),
          ),
        )
      )
    );
  }

  Widget hintText() {
    String text = hintTexts[_pageIndex];
    return Positioned(
      left: 0,
      right: 0,
      bottom: 128.h,
      child: Center(
        child: SizedBox(
          width: 340,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.w,
              fontWeight: FontWeight.bold
            ),
          )
        )
      )
    );
  }

  Widget logo() {
    return Positioned(
      right: 10,
      left: 10,
      top: 4.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo_transparent.png',
            width: 48.w,
            height: 48.w,
          ),
          SizedBox(width: 4.w),
          Text(
            "ActPod",
            style: TextStyle(
              fontSize: 24.w,
              fontWeight: FontWeight.bold,
              color: DesignColor.primary50,
            ),
          ),
        ],
      ),
    );
  }

  Widget close() {
    return Positioned(
      right: 12.w,
      top: 12.h,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Icon(
          Icons.close_outlined,
          size: 24.w,
          color: Colors.white,
        )
      )
    );
  }

  Widget content() {
    return Positioned(
      top: 60.h,
      right: 0,
      left: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 460.h,
            child: PageView(
              controller: _pageViewController,
              onPageChanged: _handlePageViewChanged,
              children: [
                Center(
                  child: SizedBox(
                    height: 460.h,
                    width: 300.w,
                    child: SvgPicture.asset(
                      "assets/images/tutorial_1.svg",
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    height: 460.h,
                    width: 300.w,
                    child: SvgPicture.asset(
                      "assets/images/tutorial_2.svg",
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    height: 460.h,
                    width: 300.w,
                    child: SvgPicture.asset(
                      "assets/images/tutorial_3.svg",
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ],
            )
          ),
          PageIndicator(
              tabController: _tabController!
          )
        ]
      )
    );
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    // required this.onUpdateCurrentPageIndex,
  });

  final TabController tabController;
  // final void Function(int) onUpdateCurrentPageIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TabPageSelector(
            indicatorSize: 8.w,
            controller: tabController,
            color: ConfigColor.background,
            selectedColor: ConfigColor.primaryDefault,
          ),
        ],
      ),
    );
  }
}
