import 'audio_handler.dart';
import 'audio_session.dart';
import 'package:PiliPlus/services/remote_focus_service.dart';
import 'package:PiliPlus/services/remote_navigation_service.dart';
import 'package:PiliPlus/utils/tv_mode_detector.dart';
import 'package:get/get.dart';

late VideoPlayerServiceHandler videoPlayerServiceHandler;
late AudioSessionHandler audioSessionHandler;

Future<void> setupServiceLocator() async {
  final audio = await initAudioService();
  videoPlayerServiceHandler = audio;
  audioSessionHandler = AudioSessionHandler();
  
  // 注册TV模式相关服务
  if (TVModeDetector().isTVMode.value) {
    await Get.putAsync(() async => RemoteFocusService());
    await Get.putAsync(() async => RemoteNavigationService());
  }
}
