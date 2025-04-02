import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChannelImage extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double size;
  final double fontSize;

  ChannelImage(this.imageUrl, this.name, this.size, this.fontSize);

  @override
  Widget build(BuildContext context) {
    if(imageUrl == "") {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(5.w)
        ),
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: Center(
            child: Text(
              name[0],
              style: TextStyle(
                fontSize: fontSize
              ),
            ),
          )
        )
      );
    }

    return SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Image.network(
                  imageUrl,
                )
            )
        )
    );
  }
}