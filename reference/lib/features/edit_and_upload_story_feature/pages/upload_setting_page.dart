import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/avatar.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/upload_setting_page/search_user_bottom_sheet.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/list_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers.dart';
import 'package:quick_share_app/features/user_info_feature/providers.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:quick_share_app/utils/string_utils.dart';
import 'package:quick_share_app/utils/time_utils.dart';
import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';

import '../../../config/color.dart';
import '../../../design_system/color.dart';
import '../components/stepper_nav.dart';

class PremiumSettingPage extends ConsumerWidget {
  final ListController listController;
  final List<String> priceOptions = [
    '免費',
    '10',
    '20',
    '30',
    '50',
    '100',
    '150',
    '200',
    '500',
  ];
  final Map<String, int> priceMap = {
    '免費': 0,
    '10': 10,
    '20': 20,
    '30': 30,
    '50': 50,
    '100': 100,
    '150': 150,
    '200': 200,
    '500': 500,
  };

  PremiumSettingPage(this.listController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(selfMembershipProvider);
    final isLocked = membership?.customerLevel == 'Free' || membership?.customerLevel == 'Pro';
    final coins = ref.watch(podcoinSettingProvider);
    final String currentLabel = isLocked
        ? '免費'
        : priceMap.entries
        .firstWhere((e) => e.value == coins, orElse: () => const MapEntry('免費', 0))
        .key;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 8.h,),
                  const StepperNav(currentStep: 2),
                  SizedBox(height: 20.h,),
                  price(ref, isLocked, currentLabel),
                  SizedBox(height: 20.h,),
                  schedule(context, ref),
                  SizedBox(height: 16.h,),
                  collaborator(context, ref)
                ],
              )
            ),
          ]
        )
      )
    );
  }

  Widget schedule(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "發布時間",
              style: TextStyle(
                  color: ConfigColor.textColorDefault,
                  fontSize: 16.w,
                  fontWeight: FontWeight.bold
              )
            ),
            const Spacer(),
            SizedBox( // <-- bounded width, so Expanded below is OK
              width: 180,
              child: Row(
                children: [
                  Expanded(child: _buildBox(context, "即時", !ref.watch(scheduledProvider), () {
                    ref.watch(scheduledProvider.notifier).state = false;
                  })),
                  const SizedBox(width: 8),
                  Expanded(child: _buildBox(context, "排程", ref.watch(scheduledProvider), () {
                    ref.watch(scheduledProvider.notifier).state = true;
                  })),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h,),
        Visibility(
          visible: ref.watch(scheduledProvider),
          child: TimePickerSpinnerPopUp(
            mode: CupertinoDatePickerMode.dateAndTime,
            initTime: TimeUtils.roundUpToNext30(DateTime.now().add(Duration(hours: 8)).toLocal()),
            minTime: TimeUtils.roundUpToNext30(DateTime.now().subtract(Duration(hours: 1)).toLocal()),
            maxTime: DateTime.now().add(const Duration(days: 100)).toLocal(),
            barrierColor: Colors.black12, //Barrier Color when pop up show
            minuteInterval: 30,
            padding : EdgeInsets.fromLTRB(16.w, 8, 16.w, 8),
            cancelText : '取消',
            confirmText : '確認',
            pressType: PressType.singlePress,
            timeFormat: 'yyyy/MM/dd      HH:mm',
            textStyle: TextStyle(
              fontSize: 14.w
            ),
            locale: Locale('zh'),
            onChange: (dateTime) {
              ref.watch(scheduleTimeProvider.notifier).state = dateTime;
            },
          )
        )
      ]
    );
  }

  Widget _buildBox(BuildContext context, String text, bool selected, VoidCallback onTap) {
    final brand = DesignColor.primary50;

    return Material(
      color: selected ? brand.withOpacity(0.15) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? brand : Colors.black26,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.black : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget collaborator(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "合作創作者",
              style: TextStyle(
                color: ConfigColor.textColorDefault,
                fontSize: 16.w,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(width: 8.w,),
            Visibility(
              visible: ref.watch(collaboratorProvider) == null,
              child: GestureDetector(
                onTap: () async {
                  UserInfoDto? selected = await SearchUserBottomSheet(context, listController).show();
                  if(selected != null) {
                    ref.watch(collaboratorProvider.notifier).state = selected;
                  }
                },
                child: Icon(
                  Icons.add_circle_outline_rounded,
                  size: 20.w,
                  color: Colors.black,
                )
              )
            )
          ]
        ),
        Row(
          children: [
            Text(
              "此創作者也可回覆聽眾留言",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.w,
                  fontWeight: FontWeight.bold
              ),
            ),
          ]
        ),
        SizedBox(height: 8.h,),
        ref.watch(collaboratorProvider) == null? const SizedBox.shrink() : Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey
            ),
            borderRadius: BorderRadius.circular(8)
          ),
          child: Row(
            children: [
              Avatar(
                ref.watch(collaboratorProvider)!.userId,
                ref.watch(collaboratorProvider)!.avatarUrl,
                20.w
              ),
              SizedBox(width: 8.w,),
              Text(
                StringUtils.shorten(ref.watch(collaboratorProvider)!.nickname, 15),
                style: TextStyle(
                  fontSize: 14.w,
                  color: Colors.black
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  ref.watch(collaboratorProvider.notifier).state = null;
                },
                child: Icon(
                  Icons.close,
                  size: 20.w,
                  color: Colors.black
                )
              )
            ],
          ),
        )
      ],
    );
  }

  Widget price(WidgetRef ref, bool isLocked, String currentLabel) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "金額(Podcoin)",
              style: TextStyle(
                  color: ConfigColor.textColorDefault,
                  fontSize: 16.w,
                  fontWeight: FontWeight.bold
              ),
            ),
          ]
        ),
        SizedBox(height: 8.h,),
        DropdownButtonFormField2<String>(
          isExpanded: true,
          value: currentLabel, // '免費' when locked
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: DesignColor.neutral300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: DesignColor.neutral300, width: 1),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            isDense: true,
          ),
          hint: const Text('選擇Podcoin', style: TextStyle(fontSize: 14)),
          items: priceOptions.map((item) => DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: const TextStyle(fontSize: 14)),
          )).toList(),
          validator: (v) => v == null ? '' : null,
          // disable changing when locked; otherwise update coins
          onChanged: isLocked
              ? null  // disables the dropdown
              : (v) {
            ref.read(podcoinSettingProvider.notifier).state = priceMap[v] ?? 0;
          },
          buttonStyleData: const ButtonStyleData(padding: EdgeInsets.only(right: 8)),
          iconStyleData: const IconStyleData(
            icon: Icon(Icons.arrow_drop_down, color: Colors.black45),
            iconSize: 24,
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        SizedBox(height: 4.h,),
        Visibility(
            visible: isLocked,
            child: Row(
              children: [
                Text(
                    "需成為 Studio 會員才可解鎖上架付費內容功能"
                )
              ],
            )
        )
      ],
    );
  }
}