import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/providers.dart';
import '../../../../design_system/color.dart';

class SpaceDropDown extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "空間選擇：",
          style: TextStyle(
            fontSize: 12.w
          ),
        ),
        const SizedBox(height: 4,),
        DropdownButtonFormField2<String>(
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 8.h),
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
          hint: const Text(
            '選擇同步空間',
            style: TextStyle(fontSize: 14),
          ),
          value: ref.watch(spaceSelectionProvider),
          items: ref.watch(spaceListProvider).map((item) => DropdownMenuItem<String>(
            value: item.name,
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          )).toList(),
          validator: (value) {
            if (value == null) {
              return '請選擇同步空間';
            }
            return null;
          },
          onChanged: (value) {
            ref.watch(spaceSelectionProvider.notifier).state = value;
          },
          onSaved: (value) {
            // selectedValue = value.toString();
          },
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.only(right: 8),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.arrow_drop_down,
              color: DesignColor.neutral300,
            ),
            iconSize: 24,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
        )
      ],
    );
  }
}