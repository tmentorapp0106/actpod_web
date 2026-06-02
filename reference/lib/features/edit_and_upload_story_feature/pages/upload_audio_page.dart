import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/back_button.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/list_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/upload_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/load_file_service.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:path/path.dart' as path;

class UploadAudioPage extends ConsumerWidget {
  final UploadController _uploadController;
  final ListController _listController;
  final String uploadType;
  final TextEditingController _textEditingController = TextEditingController();

  UploadAudioPage(this._uploadController, this._listController, this.uploadType);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WholePageLoading(
      provider: loadingProvider,
      child: Scaffold(
        appBar: AppBar(
          title: title(),
          centerTitle: true,
          leading: ActPodBackButton(),  // Back button
          backgroundColor: Colors.white
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 8.h,),
                audioName(),
                SizedBox(height: 32.h,),
                ref.watch(uploadAudioFilePathProvider) == null? chooseAudio(ref) : fileName(ref),
                SizedBox(height: 32.h,),
                clause(),
                SizedBox(height: 32.h,),
                upload(context, ref)
              ],
            )
          )
        )
      )
    );
  }

  Widget clause() {
    String termsText = '''
為確保您與 ActPod 及其他用戶的權益，請務必詳閱並同意以下條款：

1. 用戶責任：
您保證上傳之音檔皆為原創或已取得合法授權，絕無侵犯他人著作權、商標權、專利權或其他智慧財產權之情事。
您同意對上傳音檔之內容負完全責任，若因您的音檔引發任何版權爭議或法律糾紛，概與 ActPod 無關。
您不得上傳任何違反法律、善良風俗或含有歧視、暴力、色情等不當內容之音檔。

2. ActPod 免責聲明：
ActPod 僅提供音檔上傳平台，不對用戶上傳之音檔內容進行審查或保證其合法性。
若因用戶上傳之音檔涉及版權爭議或侵權行為，ActPod 將配合相關單位進行調查，並有權移除爭議音檔或終止用戶帳戶。
ActPod 不對因用戶上傳音檔所造成之任何損失或損害承擔責任。

3. 智慧財產權：
您上傳之音檔之智慧財產權仍歸您所有。
您同意授權 ActPod 在提供服務之必要範圍內，使用、儲存、複製、修改或公開展示您上傳之音檔。

4. 條款變更：
ActPod 有權隨時修改本免責聲明，並於 app 內公告。
您有義務定期查閱本免責聲明，若您於條款變更後繼續使用本服務，即視為同意接受變更後之條款。

5. 準據法與管轄權：
本免責聲明之解釋與適用，皆依中華民國法律為準據法。
若因本免責聲明產生任何爭議，雙方同意以台灣桃園地方法院為第一審管轄法院。

6. 點擊同意：
您點擊「上傳」按鈕，即表示您已閱讀、理解並同意本《用戶上傳音檔免責聲明》之所有條款。

若您對本免責聲明有任何疑問，請透過客服管道與我們聯繫。
    ''';
    return SizedBox(
      height: 360.h, // Fixed height for scrollable terms
      width: 320.w,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Text(
              termsText,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget title() {
    return Text(
      "上傳音檔",
      style: TextStyle(
        fontSize: 24.w,
        fontWeight: FontWeight.bold
      ),
    );
  }

  Widget audioName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "音檔名稱",
          style: TextStyle(
            fontSize: 16.w,
            color: ConfigColor.textColorDefault,
            fontWeight: FontWeight.bold
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.w),
            border: Border.all(),
          ),
          width: 350.w,
          child: TextField(
            controller: _textEditingController,
            maxLines: 1,
            style: TextStyle(
              color: ConfigColor.textColorDefault,
              fontSize: 16.w
            ),
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              hintText: "輸入音檔名稱",
              hintStyle: const TextStyle(
                color: Colors.grey
              )
            ),
          )
        )
      ]
    );
  }

  Widget chooseAudio(WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        ref.watch(loadingProvider.notifier).state = true;
        File? file = await LoadFileService.loadAudioFile(
          progressFunction: (progress){}
        );
        if(file == null) {
          ref.watch(uploadAudioFilePathProvider.notifier).state = null;
          ref.watch(loadingProvider.notifier).state = false;
          return;
        }
        ref.watch(uploadAudioFilePathProvider.notifier).state = file.path;
        ref.watch(loadingProvider.notifier).state = false;
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(12.w)
        ),
        child: Text(
          "選擇音檔(.m4a)",
          style: TextStyle(
            fontSize: 16.w,
            color: Colors.black
          ),
        ),
      )
    );
  }

  Widget fileName(WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        ref.watch(loadingProvider.notifier).state = true;
        File? file = await LoadFileService.loadAudioFile(
          progressFunction: (progress){}
        );
        if(file == null) {
          ref.watch(uploadAudioFilePathProvider.notifier).state = null;
          ref.watch(loadingProvider.notifier).state = false;
          return;
        }
        ref.watch(uploadAudioFilePathProvider.notifier).state = file.path;
        ref.watch(loadingProvider.notifier).state = false;
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Text(
          path.basename(ref.watch(uploadAudioFilePathProvider)!),
          style: TextStyle(
              fontSize: 16.w,
              color: Colors.black
          ),
        ),
      )
    );
  }

  Widget upload(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        ref.watch(loadingProvider.notifier).state = true;
        final filePath = ref.watch(uploadAudioFilePathProvider);
        if(filePath == null) {
          ToastService.showNoticeToast("請選擇檔案");
          ref.watch(loadingProvider.notifier).state = false;
          return;
        }
        if(_textEditingController.text == "") {
          ToastService.showNoticeToast("請輸入音樂名稱");
          ref.watch(loadingProvider.notifier).state = false;
          return;
        }

        await _uploadController.uploadPersonalAudio(File(filePath), _textEditingController.text, uploadType);

        if(uploadType == "sound") {
          await _listController.getPersonalSoundAudios();
        } else {
          await _listController.getPersonalMusicAudios();
        }
        ToastService.showSuccessToast("上傳成功");
        ref.watch(loadingProvider.notifier).state = false;
        Navigator.of(context).pop();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: ConfigColor.primaryDefault,
          borderRadius: BorderRadius.circular(12.w)
        ),
        child: Text(
          "開始上傳",
          style: TextStyle(
            fontSize: 16.w,
            color: Colors.black
          ),
        ),
      )
    );
  }
}