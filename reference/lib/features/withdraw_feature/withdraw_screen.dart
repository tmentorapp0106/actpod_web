import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/design_system/design.dart';
import 'package:quick_share_app/features/withdraw_feature/components/withdraw/tooltip.dart';
import 'package:quick_share_app/features/withdraw_feature/controllers/withdraw_controller.dart';
import 'package:quick_share_app/features/withdraw_feature/providers.dart';
import 'package:quick_share_app/features/withdraw_feature/tab_views/history.dart';
import 'package:quick_share_app/features/withdraw_feature/tab_views/withdraw.dart';
import 'package:quick_share_app/providers.dart';

import 'components/withdraw/agreement.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  WithdrawScreen();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return WithdrawScreenState();
  }
}

class WithdrawScreenState extends ConsumerState<WithdrawScreen> with TickerProviderStateMixin {
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  TabController? _tabController;
  WithdrawController? _withdrawController;

  @override
  void initState() {
    super.initState();
    _withdrawController = WithdrawController(ref);
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance
        .addPostFrameCallback((_) async {
      _withdrawController!.getWithdraws();
      initProviders();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initProviders() {
    ref.watch(withdrawAgreementProvider.notifier).state = false;
    ref.watch(withdrawReadProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "提領 Podcash",
          style: TextStyle(
            fontSize: 20.w
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          TabBar(
            indicator: UnderlineTabIndicator(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: DesignSystem.primary,
                width: 4
              ),
              insets: EdgeInsets.symmetric(horizontal:15.0)
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            controller: _tabController,
            tabs: [
              Tab(
                child: Text(
                  "Podcash",
                  style: TextStyle(
                    fontSize: 16.w,
                    color: ConfigColor.textColorDefault
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "提領紀錄",
                  style: TextStyle(
                    fontSize: 16.w,
                    color: ConfigColor.textColorDefault
                  ),
                ),
              )
            ],
          ),
          Expanded(
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              controller: _tabController,
              children: [
                WithdrawTabView(
                  ref.watch(userPodCashProvider),
                  _emailEditingController,
                  _phoneEditingController,
                  _withdrawController!,
                  _tabController!
                ),
                WithdrawHistoryTabView(
                  _emailEditingController,
                  _phoneEditingController,
                  _withdrawController!
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}