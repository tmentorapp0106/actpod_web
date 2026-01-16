import 'package:actpod_web/const.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/dto/channel_dto.dart';
import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:actpod_web/features/personal_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marquee_widget/marquee_widget.dart';

class ChannelsView extends ConsumerWidget {

  ChannelsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelList = ref.watch(channelListProvider);
    final userInfoDto = ref.watch(userInfoProvider);

    return Container(
        color: DesignColor.background,
        child: channelList == null || channelList.isEmpty? emptyView() : channelsView(channelList, userInfoDto)
    );
  }

  Widget emptyView() {
    return Center(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/images/empty_collections.svg",
            color: Colors.grey,
            width: 100.w,
            height: 100.w,
            fit: BoxFit.fitWidth,
          ),
          SizedBox(height: 20.h,),
          Text(
            "尚無頻道",
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
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
          SizedBox(height: 15.h,),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 105.w / 105.w,
                crossAxisCount: 3, // Number of columns in the grid
                crossAxisSpacing: 1.w, // Spacing between columns
                mainAxisSpacing: 3.h, // Spacing between rows
              ),
              itemCount: channelList.length,
              itemBuilder: (context, index) {
                return channelList[index].channelImageUrl == ""? channelWithoutImageWidget(channelList[index]) : channelWidget(channelList[index]);
                // return storyWidget(index, storyList[index], storyList, otherUserInfo);
              }
            )
          ),
        ]
    );
  }

  Widget channelWidget(ChannelDto channel) {
    return GestureDetector(
      onTap: () {
      },
      child: Stack(
        children: [
          Image.network(
            imgProxy + channel.channelImageUrl,
            fit: BoxFit.cover,
            // customLoadingBuilder: (context, child, event) {
            //   return const Center(
            //     child: CircularProgressIndicator(
            //       strokeWidth: 2,
            //       color: DesignColor.primary50,
            //     ),
            //   );
            // },
          ),
          Container(
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
                      color: Colors.black,
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
    return Stack(
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
                  color: Colors.black,
                  fontSize: 16.w
                )
              )
            ),
          ],
          ),
        )
      ]
    );
  }
}