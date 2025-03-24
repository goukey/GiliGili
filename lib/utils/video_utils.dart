import 'package:GiliGili/models/video/play/CDN.dart';
import 'package:GiliGili/models/video/play/url.dart';
import 'package:GiliGili/utils/extension.dart';
import 'package:GiliGili/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:GiliGili/main.dart';
import 'package:GiliGili/models/common/sponsor_block/skip_type.dart';
import 'package:GiliGili/models/video/play/quality.dart';
import 'package:GiliGili/utils/utils.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/live/room_info.dart';

class VideoUtils {
  static String getCdnUrl(dynamic item, [defaultCDNService]) {
    String? backupUrl;
    String? videoUrl;
    defaultCDNService ??= GStorage.setting
        .get(SettingBoxKey.CDNService, defaultValue: CDNService.backupUrl.code);
    if (item is AudioItem) {
      if (GStorage.setting
          .get(SettingBoxKey.disableAudioCDN, defaultValue: true)) {
        return item.backupUrl.isNullOrEmpty.not
            ? item.backupUrl!
            : item.baseUrl ?? "";
      }
    }
    if (defaultCDNService == CDNService.baseUrl.code) {
      return (item.baseUrl as String?).isNullOrEmpty.not
          ? item.baseUrl
          : item.backupUrl ?? "";
    }
    if (item is CodecItem) {
      backupUrl = (item.urlInfo?.first.host)! +
          item.baseUrl! +
          item.urlInfo!.first.extra!;
    } else {
      backupUrl = item.backupUrl;
    }
    if (defaultCDNService == CDNService.backupUrl.code) {
      return backupUrl.isNullOrEmpty.not ? backupUrl : item.baseUrl ?? "";
    }
    videoUrl = backupUrl.isNullOrEmpty ? item.baseUrl : backupUrl;

    if (videoUrl.isNullOrEmpty) {
      return "";
    }
    debugPrint("videoUrl:$videoUrl");

    String defaultCDNHost = CDNServiceCode.fromCode(defaultCDNService)!.host;
    debugPrint("defaultCDNHost:$defaultCDNHost");
    if (videoUrl!.contains("szbdyd.com")) {
      String hostname =
          Uri.parse(videoUrl).queryParameters['xy_usource'] ?? defaultCDNHost;
      videoUrl =
          Uri.parse(videoUrl).replace(host: hostname, port: 443).toString();
    } else if (videoUrl.contains(".mcdn.bilivideo")) {
      videoUrl = Uri.parse(videoUrl)
          .replace(host: defaultCDNHost, port: 443)
          .toString();
      // videoUrl =
      //     'https://proxy-tf-all-ws.bilivideo.com/?url=${Uri.encodeComponent(videoUrl)}';
    } else if (videoUrl.contains("/upgcxcode/")) {
      videoUrl = Uri.parse(videoUrl)
          .replace(host: defaultCDNHost, port: 443)
          .toString();
    }
    debugPrint("videoUrl:$videoUrl");

    // /// 先获取backupUrl 一般是upgcxcode地址 播放更稳定
    // if (item is VideoItem) {
    //   backupUrl = item.backupUrl ?? "";
    //   videoUrl = backupUrl.contains("http") ? backupUrl : (item.baseUrl ?? "");
    // } else if (item is AudioItem) {
    //   backupUrl = item.backupUrl ?? "";
    //   videoUrl = backupUrl.contains("http") ? backupUrl : (item.baseUrl ?? "");
    // } else if (item is CodecItem) {
    //   backupUrl = (item.urlInfo?.first.host)! +
    //       item.baseUrl! +
    //       item.urlInfo!.first.extra!;
    //   videoUrl = backupUrl.contains("http") ? backupUrl : (item.baseUrl ?? "");
    // } else {
    //   return "";
    // }
    //
    // /// issues #70
    // if (videoUrl.contains(".mcdn.bilivideo")) {
    //   videoUrl =
    //       'https://proxy-tf-all-ws.bilivideo.com/?url=${Uri.encodeComponent(videoUrl)}';
    // } else if (videoUrl.contains("/upgcxcode/")) {
    //   //CDN列表
    //   var cdnList = {
    //     'ali': 'upos-sz-mirrorali.bilivideo.com',
    //     'cos': 'upos-sz-mirrorcos.bilivideo.com',
    //     'hw': 'upos-sz-mirrorhw.bilivideo.com',
    //   };
    //   //取一个CDN
    //   var cdn = cdnList['cos'] ?? "";
    //   var reg = RegExp(r'(http|https)://(.*?)/upgcxcode/');
    //   videoUrl = videoUrl.replaceAll(reg, "https://$cdn/upgcxcode/");
    // }

    return videoUrl;
  }

  // 获取视频清晰度Map
  static Map<String, String> getQualityMap() {
    return {
      "127": "8K 超高清",
      "126": "杜比视界",
      "125": "HDR 真彩",
      "120": "4K 超清",
      "116": "1080P 60帧",
      "112": "1080P 高码率",
      "80": "1080P 高清",
      "74": "720P 60帧",
      "64": "720P 高清",
      "32": "480P 清晰",
      "16": "360P 流畅",
      "6": "240P 极速",
      "0": "自动",
    };
  }

  // 根据清晰度id获取清晰度描述
  static String getQualityDesc(int qn) {
    return getQualityMap()[qn.toString()] ?? "未知";
  }

  // 根据清晰度id获取清晰度项
  static QualityItem getQualityItem(int qn, bool needVip) {
    return QualityItem(
      id: qn,
      quality: getQualityDesc(qn),
      desc: getQualityDesc(qn),
      needVip: needVip,
    );
  }
  
  // 将接口返回的清晰度数据转换为QualityItem列表
  static List<QualityItem> convertToQualityItems(List<Accept> acceptList) {
    return acceptList.map((accept) => 
      QualityItem(
        id: accept.quality,
        quality: getQualityDesc(accept.quality),
        desc: getQualityDesc(accept.quality),
        needVip: false, // 根据实际需要调整
      )
    ).toList();
  }
  
  // 检查是否应在TV模式下直接打开播放器
  static bool shouldDirectPlayInTv(String? bvid, int? cid) {
    if (kIsAndroidTv && bvid != null && cid != null) {
      // 直接调用openVideoDirectly方法打开视频
      Utils.openVideoDirectly(bvid, cid);
      return true;
    }
    return false;
  }
}
