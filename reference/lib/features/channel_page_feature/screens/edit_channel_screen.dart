import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/channel_page_feature/components/edit_channel/channel_co_owners.dart';
import 'package:quick_share_app/features/channel_page_feature/components/edit_channel/complete_btn.dart';
import 'package:quick_share_app/features/channel_page_feature/components/edit_channel/delete_btn.dart';
import 'package:quick_share_app/features/channel_page_feature/controllers/channel_controller.dart';
import 'package:quick_share_app/features/channel_page_feature/provider.dart';

import '../../../components/whole_page_loading.dart';
import '../../../config/color.dart';
import '../../../providers.dart';
import '../components/edit_channel/channel_description.dart';
import '../components/edit_channel/channel_image.dart';
import '../components/edit_channel/channel_name.dart';

class EditChannelScreen extends ConsumerWidget {
  final ChannelController channelController;
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  EditChannelScreen(this.channelController, this.nameController, this.descriptionController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WholePageLoading(
      provider: loadingProvider,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: ConfigColor.background,
            surfaceTintColor: ConfigColor.background,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
              ),
            ),
            title: Text(
              "編輯頻道"
            ),
          ),
          backgroundColor: ConfigColor.background,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ChannelImage(),
                          SizedBox(height: 20.h,),
                          Text(
                            "頻道名稱",
                            style: TextStyle(
                              color: ConfigColor.textColorDefault,
                              fontSize: 16.w,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 5.h,),
                          ChannelName(nameController),
                          SizedBox(height: 20.h,),
                          Text(
                            "頻道敘述",
                            style: TextStyle(
                                color: ConfigColor.textColorDefault,
                                fontSize: 16.w,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 5.h,),
                          ChannelDescription(descriptionController),
                          SizedBox(height: 20.h,),
                          ChannelCoOwners(channelController: channelController,),
                          SizedBox(height: 20.h,),
                          CompleteChannelBtn(
                            channelController,
                            nameController,
                            descriptionController
                          ),
                          DeleteBtn(channelController, ref.watch(channelInfoProvider)!.channelId),
                          SizedBox(height: 160.h,),
                        ],
                      )
                  )
                ),
              ]
            )
          )
        )
      )
    );
  }
}