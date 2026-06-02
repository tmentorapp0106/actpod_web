import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/user_info_feature/components/create_channel/channel_name.dart';
import 'package:quick_share_app/features/user_info_feature/controllers/create_channel_controller.dart';

import '../../../components/whole_page_loading.dart';
import '../../../config/color.dart';
import '../../../providers.dart';
import '../components/create_channel/channel_co_owners.dart';
import '../components/create_channel/channel_description.dart';
import '../components/create_channel/channel_image.dart';
import '../components/create_channel/create_btn.dart';
import '../components/other_user_info/back_button.dart';

class CreateChannelScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return CreateChannelScreenState();
  }
}

class CreateChannelScreenState extends ConsumerState<CreateChannelScreen>{
  CreateChannelController? createChannelController;

  @override
  void initState() {
    super.initState();
    createChannelController = CreateChannelController(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) async {

    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WholePageLoading(
      provider: loadingProvider,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          backgroundColor: ConfigColor.background,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10.h,),
                        Text(
                          "創建頻道",
                          style: TextStyle(
                            color: ConfigColor.textColorDefault,
                            fontWeight: FontWeight.bold,
                            fontSize: 24.w
                          ),
                        ),
                        SizedBox(height: 20.h,),
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
                        ChannelName(),
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
                        ChannelDescription(),
                        SizedBox(height: 20.h,),
                        ChannelCoOwners(createChannelController: createChannelController!),
                        SizedBox(height: 20.h,),
                        CreateChannelBtn(createChannelController!),
                        SizedBox(height: 160.h,), 
                      ],
                    )
                  )
                ),
                Positioned(
                  top: 10.w,
                  left: 10.w,
                  child: UserInfoBackButton()
                )
              ]
            )
          )
        )
      )
    );
  }
}