import 'package:actpod_web/features/personal_page/components/desktop/story_channel_tab_view.dart';
import 'package:actpod_web/features/personal_page/components/desktop/user_info.dart';
import 'package:flutter/material.dart';

class DesktopPersonalScreen extends StatelessWidget {
  final TabController tabController;

  const DesktopPersonalScreen({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 18, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    "assets/images/actpod_logo_web.png",
                    width: 96,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const SizedBox(height: 18),
                const DesktopUserInfo(),
                const SizedBox(height: 20),
                DesktopStoryChannelTabView(tabController),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
