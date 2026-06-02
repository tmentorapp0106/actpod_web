import 'package:flutter/material.dart';

class UploadMethodBottomModel extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child:Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16,),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('從儲存裝置中上傳'),
            onTap: () {
              Navigator.of(context).pop("device");
            },
          ),
          ListTile(
            leading: const Icon(Icons.rss_feed),
            title: const Text('讀取 RSS Feed'),
            onTap: () {
              Navigator.of(context).pop("rss");
            },
          ),
          const SizedBox(height: 28,)
        ],
      )
    );
  }
}