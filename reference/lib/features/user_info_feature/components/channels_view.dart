import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:quick_share_app/dto/channel_dto.dart';
import 'package:quick_share_app/features/user_info_feature/controllers/channel_controller.dart';
import 'package:quick_share_app/features/user_info_feature/providers.dart';
import 'package:quick_share_app/features/user_info_feature/screens/create_channel_screen.dart';
import 'package:quick_share_app/router.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../../config/color.dart';
import '../../../dto/user_info_dto.dart';
import '../../login_feature/login_screen.dart';

class ChannelsView extends ConsumerWidget {
  final ChannelController channelController;

  ChannelsView(this.channelController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelList = ref.watch(selfChannelListProvider);
    final userInfoDto = ref.watch(selfUserInfoProvider);

    return Container(
        color: ConfigColor.background,
        child: channelList == null? emptyView() : channelsView(channelList, userInfoDto)
    );
  }

  Widget emptyView() {
    return Center(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/images/empty_stories.svg",
            width: 100.w,
            height: 100.w,
            fit: BoxFit.fitWidth,
          ),
          SizedBox(height: 20.h,),
          Text(
            "No Stories yet",
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          )
        ],
      )
    );
  }

  Widget channelsView(List<ChannelDto> channelList, UserInfoDto? otherUserInfo) {
    return Column(
        children:[
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 105.w / 105.w,
                crossAxisCount: 3, // Number of columns in the grid
                crossAxisSpacing: 1.w, // Spacing between columns
                mainAxisSpacing: 3.h, // Spacing between rows
              ),
              itemCount: channelList.length + 1,
              itemBuilder: (context, index) {
                if(index == 0) {
                  return createChannel(context);
                }
                return channelList[index - 1].channelImageUrl == ""? channelWithoutImageWidget(channelList[index - 1]) : channelWidget(channelList[index - 1]);
                // return storyWidget(index, storyList[index], storyList, otherUserInfo);
              }
            )
          ),
          SizedBox(height: 64.h,),
        ]
    );
  }

  Widget createChannel(BuildContext context) {
    return InkWell(
      onTap: () {
        if(!UserService.hasLoggedIn()) {
          showDialog(
            context: context,
            builder: (context) {
              return LoginPageScreen();
            }
          );
          return;
        }
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return CreateChannelScreen();
        }));
      },
      child: Container(
        width: 500.w,
        height: 500.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey, Colors.white.withOpacity(0), Colors.grey],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                size: 40.w,
              ),
              Text(
                "創立頻道",
                style: TextStyle(
                  fontSize: 10.w
                ),
              )
            ]
          )
        )
      )
    );
  }

  Widget channelWidget(ChannelDto channel) {
    return GestureDetector(
      onTap: () async {
        await router.push("/channel/${channel.channelId}");
        channelController.getChannels(UserService.getUserInfo()!.userId);
      },
      child: Stack(
        children: [
          Image.network(
            channel.channelImageUrl,
            fit: BoxFit.fill,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            width: 500.w,
            height: 500.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey, Colors.white.withOpacity(0), Colors.grey],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Marquee(
                  animationDuration: const Duration(seconds: 10),
                  directionMarguee: DirectionMarguee.oneDirection,
                  child: Text(
                    channel.channelName,
                    style: TextStyle(
                      color: ConfigColor.textColorDefault,
                      fontSize: 16.w
                    )
                  )
                ),
              ],
            ),
          )
        ]
      )
    );
  }

  Widget channelWithoutImageWidget(ChannelDto channel) {
    return GestureDetector(
      onTap: () async {
        await router.push("/channel/${channel.channelId}");
        channelController.getChannels(UserService.getUserInfo()!.userId);
      },
      child:Stack(
        children: [
          Center(
            child: Text(
              channel.channelName[0],
              style: TextStyle(
                fontSize: 50.w
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            width: 500.w,
            height: 500.w,
            decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey, Colors.white.withOpacity(0), Colors.grey],
              stops: [0.0, 0.5, 1.0],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Marquee(
                animationDuration: const Duration(seconds: 10),
                directionMarguee: DirectionMarguee.oneDirection,
                child: Text(
                  channel.channelName,
                  style: TextStyle(
                    color: ConfigColor.textColorDefault,
                    fontSize: 16.w
                  )
                )
              ),
            ],
            ),
          )
        ]
      )
    );
  }
}