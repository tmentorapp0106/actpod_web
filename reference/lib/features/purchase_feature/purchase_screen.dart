import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/config/color.dart';
import '../../l10n/app_localizations.dart';
import 'package:quick_share_app/features/purchase_feature/components/coin_list.dart';
import 'package:quick_share_app/features/purchase_feature/components/pod_coins.dart';
import 'package:quick_share_app/features/purchase_feature/controllers/pod_coin_controller.dart';
import 'package:quick_share_app/providers.dart';

import 'components/buy_coins_text.dart';
import 'components/notice.dart';

class PurchaseScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return PurchaseScreenState();
  }
}

class PurchaseScreenState extends ConsumerState<PurchaseScreen> {
  PodCoinController? podCoinController;

  @override
  void initState() {
    super.initState();
    podCoinController = PodCoinController(ref);
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      podCoinController!.getCoinList();
      podCoinController!.getUserPurses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WholePageLoading(
      provider: loadingProvider,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ConfigColor.background,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios), // Apple's chevron-style back icon
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            AppLocalizations.of(context)!.purchase
          )
        ),
        backgroundColor: ConfigColor.background,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PodCoins(),
              BuyCoinsText(),
              SizedBox(
                height: 264.h,
                child: CoinList(podCoinController!)
              ),
              PodcoinUsageNotice()
            ],
          ),
        ),
      )
    );
  }
}