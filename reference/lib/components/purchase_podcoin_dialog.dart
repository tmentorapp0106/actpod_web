import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/errors.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';
import 'package:quick_share_app/design_system/components/podcoin.dart';

import '../apiManagers/purchase_system_api_manager.dart';
import '../providers.dart';
import '../services/toast_service.dart';

class PurchasePodcoinDialog {
  Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const DonateDialog(),
    );
  }
}

class DonateDialog extends ConsumerStatefulWidget {
  const DonateDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _DonateDialogState();
  }
}

class _DonateDialogState extends ConsumerState<DonateDialog> {
  int? selectedCoin = 30;
  List<Offering> podCoinList = [];
  bool isLoading = false;


  Future<void> polling(WidgetRef ref) async {
    final originCoins = ref.watch(userPodCoinsProvider);
    int attempts = 0;
    const maxAttempts = 4;
    const delayBetweenAttempts = Duration(seconds: 2);
    bool isSuccess = false;
    int finalPodcoins = 0;

    while (attempts < maxAttempts) {
      await Future.delayed(delayBetweenAttempts);
      attempts++;

      try {
        final response = await purchaseApiManager.getUserPurses();
        finalPodcoins = response.purses?.coinsPurse.podCoins ?? 0;
        // 💡 Replace this logic with your actual check
        if (originCoins != finalPodcoins && finalPodcoins > originCoins) {
          ref.watch(userPodCoinsProvider.notifier).state = finalPodcoins;
          isSuccess = true;
          break;
        }
      } catch (e) {
        print("Error checking PodCoin status: $e");
      }
    }
    setState(() {
      isLoading = false;
    });
    if(isSuccess) {
      ref.watch(userPodCoinsProvider.notifier).state = finalPodcoins;
      ToastService.showSuccessToast("購買成功");
    } else {
      ToastService.showNoticeToast("Podcoins 轉換失敗！請稍後查看或是聯絡客服人員！");
    }
  }

  Future<void> getCoinList(WidgetRef ref) async {
    List<Offering> offers = await PurchaseSystemApi.fetchPodCoins();
    offers.sort((offerA, offerB) {
      int a = offerA.metadata["ntdDollar"] as int;
      int b = offerB.metadata["ntdDollar"] as int;
      if(a > b) {
        return 1;
      } else if(a == b) {
        return 0;
      } else {
        return -1;
      }
    });
    setState(() {
      podCoinList = offers;
    });
    ref.watch(podCoinsListProvider.notifier).state = offers;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      getCoinList(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        width: 340,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "選擇 Podcoin 儲值方案",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFFB3B3B3),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildCoinOptions(),
            const SizedBox(height: 16),
            _buildRemainCoin(),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE6E6E6)),
            const SizedBox(height: 18),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "儲值方案",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).pop(),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.close,
              size: 28,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoinOptions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: podCoinList.map((coinOffer) {
          final bool isSelected = selectedCoin == int.parse(coinOffer.metadata["coins"] as String);
          return Padding(
            padding: EdgeInsets.only(
              right: coinOffer != ref.read(podCoinsListProvider).last ? 10 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCoin = int.parse(coinOffer.metadata["coins"] as String);
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFC107) : Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFFC107)
                        : const Color(0xFFD0D0D0),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PodCoin(size: 20),
                    const SizedBox(width: 4),
                    Text(
                      coinOffer.metadata["coins"] as String,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      )
    );
  }

  Widget _buildRemainCoin() {
    return Row(
      children: [
        PodCoin(size: 20),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
            children: [
              const TextSpan(text: "剩餘 Podcoin："),
              TextSpan(
                text: "${ref.read(userPodCoinsProvider)}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
          if (selectedCoin == null) {
            return;
          }

          final offering = podCoinList.where((coinOffer) => int.parse(coinOffer.metadata["coins"] as String) == selectedCoin).first;

          setState(() {
            isLoading = true;
          });

          try {
            await purchaseApiManager.purchasePodCoins(
              offering.availablePackages[0],
              offering,
            );
          } on PlatformException catch (e) {
            final errorCode = PurchasesErrorHelper.getErrorCode(e);

            if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
              setState(() {
                isLoading = false;
              });
              return;
            }

            debugPrint("purchase error code: ${e.code}");
            debugPrint("purchase error details: ${e.details}");

            ToastService.showNoticeToast("購買失敗");
            setState(() {
              isLoading = false;
            });
            return;
          } catch (e) {
            ToastService.showNoticeToast("購買失敗");
            setState(() {
              isLoading = false;
            });
            return;
          }
          await polling(ref);

          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC107),
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.black,
          ),
        )
            : const Text(
          "儲值",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
