import 'dart:typed_data';

import 'package:GiliGili/http/init.dart';
import 'package:GiliGili/utils/extension.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:live_photo_maker/live_photo_maker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'dart:io';

class DownloadUtils {
  // 获取存储权限
  static Future<bool> requestStoragePer(BuildContext context) async {
    await Permission.storage.request();
    PermissionStatus status = await Permission.storage.status;
    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      if (!context.mounted) return false;
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('提示'),
            content: const Text('存储权限未授权'),
            actions: [
              TextButton(
                onPressed: () async {
                  openAppSettings();
                },
                child: const Text('去授权'),
              )
            ],
          );
        },
      );
      return false;
    } else {
      return true;
    }
  }

  // 获取相册权限
  static Future<bool> requestPhotoPer() async {
    await Permission.photos.request();
    PermissionStatus status = await Permission.photos.status;
    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      // SmartDialog.show(
      //   useSystem: true,
      //   animationType: SmartAnimationType.centerFade_otherSlide,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: const Text('提示'),
      //       content: const Text('相册权限未授权'),
      //       actions: [
      //         TextButton(
      //           onPressed: () async {
      //             openAppSettings();
      //           },
      //           child: const Text('去授权'),
      //         )
      //       ],
      //     );
      //   },
      // );
      return false;
    } else {
      return true;
    }
  }

  static Future<bool> checkPermissionDependOnSdkInt(
      BuildContext context) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        if (!context.mounted) return false;
        return await requestStoragePer(context);
      } else {
        return await requestPhotoPer();
      }
    }
    return await requestStoragePer(context);
  }

  static Future downloadLivePhoto({
    required BuildContext context,
    required String url,
    required String liveUrl,
    required int width,
    required int height,
  }) async {
    try {
      if (!await checkPermissionDependOnSdkInt(context)) {
        return;
      }
      SmartDialog.showLoading(msg: '正在下载');

      String tmpPath = (await getTemporaryDirectory()).path;
      String time = DateTime.now()
          .toString()
          .replaceAll(' ', '_')
          .replaceAll(':', '-')
          .split('.')
          .first;
      late String imageName =
          "cover_$time.${url.split('.').lastOrNull ?? 'jpg'}";
      late String imagePath = '$tmpPath/$imageName';
      String videoName =
          "video_$time.${liveUrl.split('.').lastOrNull ?? 'mp4'}";
      String videoPath = '$tmpPath/$videoName';

      await Request.dio.download(liveUrl, videoPath);

      if (Platform.isIOS) {
        await Request.dio.download(url, imagePath);
        SmartDialog.showLoading(msg: '正在保存');
        bool success = await LivePhotoMaker.create(
          coverImage: imagePath,
          imagePath: null,
          voicePath: videoPath,
          width: width,
          height: height,
        );
        SmartDialog.dismiss();
        if (success) {
          SmartDialog.showToast(' Live Photo 已保存 ');
        } else {
          SmartDialog.showToast('保存失败');
        }
      } else {
        SmartDialog.showLoading(msg: '正在保存');
        final SaveResult result = await SaverGallery.saveFile(
          filePath: videoPath,
          fileName: videoName,
          androidRelativePath: "Pictures/PiliPlus",
          skipIfExists: false,
        );
        SmartDialog.dismiss();
        if (result.isSuccess) {
          SmartDialog.showToast(' 已保存 ');
        } else {
          SmartDialog.showToast('保存失败，${result.errorMessage}');
        }
      }

      return true;
    } catch (err) {
      SmartDialog.dismiss();
      SmartDialog.showToast(err.toString());
      return false;
    }
  }

  static Future downloadImg(
    BuildContext context,
    List<String> imgList, {
    String imgType = 'cover',
  }) async {
    try {
      if (!await checkPermissionDependOnSdkInt(context)) {
        return;
      }
      bool dispose = false;
      for (int i = 0; i < imgList.length; i++) {
        SmartDialog.showLoading(
          msg:
              '正在下载原图${imgList.length > 1 ? '${i + 1}/${imgList.length}' : ''}',
          clickMaskDismiss: true,
          onDismiss: () {
            dispose = true;
            if (i != imgList.length - 1) {
              SmartDialog.showToast('已取消下载剩余图片');
            }
          },
        );
        var response = await Request().get(
          imgList[i].http2https,
          options: Options(responseType: ResponseType.bytes),
        );
        String picName =
            "${imgType}_${DateTime.now().toString().replaceAll(' ', '_').replaceAll(':', '-').split('.').first}";
        final SaveResult result = await SaverGallery.saveImage(
          Uint8List.fromList(response.data),
          quality: 100,
          fileName: picName,
          // 保存到 PiliPlus文件夹
          androidRelativePath: "Pictures/PiliPlus",
          skipIfExists: false,
        );
        // SmartDialog.dismiss();
        // SmartDialog.showLoading(msg: '正在保存图片至图库');
        if (i == imgList.length - 1) {
          SmartDialog.dismiss();
        }
        if (result.isSuccess) {
          SmartDialog.showToast('「$picName」已保存 ');
        } else {
          SmartDialog.showToast('保存失败，${result.errorMessage}');
        }
        if (dispose) {
          break;
        }
      }
      return true;
    } catch (err) {
      SmartDialog.dismiss();
      SmartDialog.showToast(err.toString());
      return false;
    }
  }
}
