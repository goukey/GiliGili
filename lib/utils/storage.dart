import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:GiliGili/common/widgets/pair.dart';
import 'package:GiliGili/common/widgets/refresh_indicator.dart'
    show kDragContainerExtentPercentage, displacement;
import 'package:GiliGili/http/constants.dart';
import 'package:GiliGili/http/index.dart';
import 'package:GiliGili/models/common/dynamic_badge_mode.dart';
import 'package:GiliGili/models/common/sponsor_block/segment_type.dart';
import 'package:GiliGili/models/common/sponsor_block/skip_type.dart';
import 'package:GiliGili/models/common/tab_type.dart';
import 'package:GiliGili/models/common/theme_type.dart';
import 'package:GiliGili/models/common/up_panel_position.dart';
import 'package:GiliGili/models/user/danmaku_rule.dart';
import 'package:GiliGili/models/user/danmaku_rule_adapter.dart';
import 'package:GiliGili/models/video/play/CDN.dart';
import 'package:GiliGili/models/video/play/quality.dart';
import 'package:GiliGili/models/video/play/subtitle.dart';
import 'package:GiliGili/pages/member/new/controller.dart' show MemberTabType;
import 'package:GiliGili/pages/mine/index.dart';
import 'package:GiliGili/plugin/pl_player/models/bottom_progress_behavior.dart';
import 'package:GiliGili/plugin/pl_player/models/fullscreen_mode.dart';
import 'package:GiliGili/utils/accounts/account.dart';
import 'package:GiliGili/utils/accounts/account_adapter.dart';
import 'package:GiliGili/utils/accounts/cookie_jar_adapter.dart';
import 'package:GiliGili/utils/accounts/account_type_adapter.dart';
import 'package:GiliGili/utils/login.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:GiliGili/models/model_owner.dart';
import 'package:GiliGili/models/search/hot.dart';
import 'package:GiliGili/models/user/info.dart';
import 'global_data.dart';
import 'package:uuid/uuid.dart';

class GStorage {
  static late final Box<dynamic> userInfo;
  static late final Box<dynamic> historyWord;
  static late final Box<dynamic> localCache;
  static late final Box<dynamic> setting;
  static late final Box<dynamic> video;

  // static bool get isLogin => userInfo.get('userInfoCache') != null;

  // static get ownerMid => userInfo.get('userInfoCache')?.mid;

  static List<double> get speedList => List<double>.from(
        video.get(
          VideoBoxKey.speedsList,
          defaultValue: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 3.0],
        ),
      );

  static List<String> get tabbarSort =>
      List<String>.from(setting.get(SettingBoxKey.tabbarSort,
          defaultValue: TabType.values.map((item) => item.name).toList()));

  static List<Pair<SegmentType, SkipType>> get blockSettings {
    List<int> list = List<int>.from(setting.get(
      SettingBoxKey.blockSettings,
      defaultValue: List.generate(SegmentType.values.length, (_) => 1),
    ));
    return SegmentType.values
        .map((item) => Pair<SegmentType, SkipType>(
              first: item,
              second: SkipType.values[list[item.index]],
            ))
        .toList();
  }

  static List<Color> get blockColor {
    List<String> list = List<String>.from(setting.get(
      SettingBoxKey.blockColor,
      defaultValue: List.generate(SegmentType.values.length, (_) => ''),
    ));
    return SegmentType.values
        .map((item) => list[item.index].isNotEmpty
            ? Color(
                int.tryParse('FF${list[item.index]}', radix: 16) ?? 0xFF000000)
            : item.color)
        .toList();
  }

  static bool get hiddenSettingUnlocked =>
      setting.get(SettingBoxKey.hiddenSettingUnlocked, defaultValue: false);

  static bool get feedBackEnable =>
      setting.get(SettingBoxKey.feedBackEnable, defaultValue: false);

  static double get toastOpacity =>
      setting.get(SettingBoxKey.defaultToastOp, defaultValue: 1.0);

  static int get picQuality =>
      setting.get(SettingBoxKey.defaultPicQa, defaultValue: 10);

  static ThemeType get themeType => ThemeType.values[GStorage.themeTypeInt];

  static DynamicBadgeMode get dynamicBadgeType =>
      DynamicBadgeMode.values[setting.get(
        SettingBoxKey.dynamicBadgeMode,
        defaultValue: DynamicBadgeMode.number.index,
      )];

  static DynamicBadgeMode get msgBadgeMode =>
      DynamicBadgeMode.values[setting.get(
        SettingBoxKey.msgBadgeMode,
        defaultValue: DynamicBadgeMode.number.index,
      )];

  static List<MsgUnReadType> get msgUnReadTypeV2 => List<int>.from(setting.get(
        SettingBoxKey.msgUnReadTypeV2,
        defaultValue:
            List<int>.generate(MsgUnReadType.values.length, (index) => index),
      )).map((index) => MsgUnReadType.values[index]).toList();

  static int get defaultHomePage =>
      setting.get(SettingBoxKey.defaultHomePage, defaultValue: 0);

  static int get previewQ =>
      setting.get(SettingBoxKey.previewQuality, defaultValue: 100);

  static double get mediumCardWidth =>
      setting.get(SettingBoxKey.mediumCardWidth, defaultValue: 280.0);

  static double get smallCardWidth =>
      setting.get(SettingBoxKey.smallCardWidth, defaultValue: 240.0);

  static UpPanelPosition get upPanelPosition =>
      UpPanelPosition.values[setting.get(SettingBoxKey.upPanelPosition,
          defaultValue: UpPanelPosition.leftFixed.index)];

  static int get defaultFullScreenMode =>
      setting.get(SettingBoxKey.fullScreenMode,
          defaultValue: FullScreenMode.values.first.code);

  static int get defaultBtmProgressBehavior =>
      setting.get(SettingBoxKey.btmProgressBehavior,
          defaultValue: BtmProgressBehavior.values.first.code);

  static String get defaultSubtitlePreference =>
      setting.get(SettingBoxKey.subtitlePreference,
          defaultValue: SubtitlePreference.values.first.code);

  static int get defaultVideoQa => setting.get(
        SettingBoxKey.defaultVideoQa,
        defaultValue: VideoQuality.values.last.code,
      );

  static int get defaultVideoQaCellular => setting.get(
        SettingBoxKey.defaultVideoQaCellular,
        defaultValue: VideoQuality.high1080.code,
      );

  static int get defaultAudioQa => setting.get(
        SettingBoxKey.defaultAudioQa,
        defaultValue: AudioQuality.values.last.code,
      );

  static int get defaultAudioQaCellular => setting.get(
        SettingBoxKey.defaultAudioQaCellular,
        defaultValue: AudioQuality.k192.code,
      );

  static String get defaultDecode => setting.get(
        SettingBoxKey.defaultDecode,
        defaultValue: VideoDecodeFormats.values.last.code,
      );

  static String get secondDecode => setting.get(
        SettingBoxKey.secondDecode,
        defaultValue: VideoDecodeFormats.values[1].code,
      );

  static String get hardwareDecoding =>
      setting.get(SettingBoxKey.hardwareDecoding, defaultValue: 'auto');

  static String get videoSync => setting.get(
        SettingBoxKey.videoSync,
        defaultValue: 'display-resample',
      );

  static String get defaultCDNService => setting.get(
        SettingBoxKey.CDNService,
        defaultValue: CDNService.backupUrl.code,
      );

  static int get minDurationForRcmd =>
      setting.get(SettingBoxKey.minDurationForRcmd, defaultValue: 0);

  static String get banWordForRecommend =>
      setting.get(SettingBoxKey.banWordForRecommend, defaultValue: '');

  static String get banWordForReply =>
      setting.get(SettingBoxKey.banWordForReply, defaultValue: '');

  static String get banWordForZone =>
      setting.get(SettingBoxKey.banWordForZone, defaultValue: '');

  static int get minLikeRatioForRecommend =>
      setting.get(SettingBoxKey.minLikeRatioForRecommend, defaultValue: 0);

  static bool get appRcmd =>
      setting.get(SettingBoxKey.appRcmd, defaultValue: true);

  static String get defaultSystemProxyHost =>
      setting.get(SettingBoxKey.systemProxyHost, defaultValue: '');

  static String get defaultSystemProxyPort =>
      setting.get(SettingBoxKey.systemProxyPort, defaultValue: '');

  static int get defaultReplySort =>
      setting.get(SettingBoxKey.replySortType, defaultValue: 1);

  static int get defaultDynamicType =>
      setting.get(SettingBoxKey.defaultDynamicType, defaultValue: 0);

  static double get blockLimit =>
      setting.get(SettingBoxKey.blockLimit, defaultValue: 0.0);

  static double get refreshDragPercentage =>
      setting.get(SettingBoxKey.refreshDragPercentage, defaultValue: 0.25);

  static double get refreshDisplacement =>
      setting.get(SettingBoxKey.refreshDisplacement, defaultValue: 20.0);

  static String get blockUserID {
    String blockUserID =
        setting.get(SettingBoxKey.blockUserID, defaultValue: '');
    if (blockUserID.isEmpty) {
      blockUserID = Uuid().v4().replaceAll('-', '');
      setting.put(SettingBoxKey.blockUserID, blockUserID);
    }
    return blockUserID;
  }

  static bool get blockToast =>
      setting.get(SettingBoxKey.blockToast, defaultValue: true);

  static String get blockServer => setting.get(SettingBoxKey.blockServer,
      defaultValue: HttpString.sponsorBlockBaseUrl);

  static bool get blockTrack =>
      setting.get(SettingBoxKey.blockTrack, defaultValue: true);

  static bool get checkDynamic =>
      setting.get(SettingBoxKey.checkDynamic, defaultValue: true);

  static int get dynamicPeriod =>
      setting.get(SettingBoxKey.dynamicPeriod, defaultValue: 5);

  static int get schemeVariant =>
      setting.get(SettingBoxKey.schemeVariant, defaultValue: 10);

  static double get danmakuFontScaleFS =>
      setting.get(SettingBoxKey.danmakuFontScaleFS, defaultValue: 1.2);

  static bool get danmakuMassiveMode =>
      setting.get(SettingBoxKey.danmakuMassiveMode, defaultValue: false);

  static double get subtitleFontScale =>
      setting.get(SettingBoxKey.subtitleFontScale, defaultValue: 1.0);

  static double get subtitleFontScaleFS =>
      setting.get(SettingBoxKey.subtitleFontScaleFS, defaultValue: 1.5);

  static bool get grpcReply =>
      setting.get(SettingBoxKey.grpcReply, defaultValue: true);

  static bool get showViewPoints =>
      setting.get(SettingBoxKey.showViewPoints, defaultValue: true);

  static bool get showRelatedVideo =>
      setting.get(SettingBoxKey.showRelatedVideo, defaultValue: true);

  static bool get showVideoReply =>
      setting.get(SettingBoxKey.showVideoReply, defaultValue: true);

  static bool get showBangumiReply =>
      setting.get(SettingBoxKey.showBangumiReply, defaultValue: true);

  static bool get alwaysExapndIntroPanel =>
      setting.get(SettingBoxKey.alwaysExapndIntroPanel, defaultValue: false);

  static bool get exapndIntroPanelH =>
      setting.get(SettingBoxKey.exapndIntroPanelH, defaultValue: false);

  static bool get horizontalSeasonPanel =>
      setting.get(SettingBoxKey.horizontalSeasonPanel, defaultValue: false);

  static bool get horizontalMemberPage =>
      setting.get(SettingBoxKey.horizontalMemberPage, defaultValue: false);

  static int get replyLengthLimit =>
      setting.get(SettingBoxKey.replyLengthLimit, defaultValue: 6);

  static int get defaultPicQa =>
      setting.get(SettingBoxKey.defaultPicQa, defaultValue: 10);

  static double get danmakuLineHeight =>
      setting.get(SettingBoxKey.danmakuLineHeight, defaultValue: 1.6);

  static bool get showArgueMsg =>
      setting.get(SettingBoxKey.showArgueMsg, defaultValue: true);

  static bool get reverseFromFirst =>
      setting.get(SettingBoxKey.reverseFromFirst, defaultValue: true);

  static int get subtitlePaddingH =>
      setting.get(SettingBoxKey.subtitlePaddingH, defaultValue: 24);

  static int get subtitlePaddingB =>
      setting.get(SettingBoxKey.subtitlePaddingB, defaultValue: 24);

  static double get subtitleBgOpaticy =>
      setting.get(SettingBoxKey.subtitleBgOpaticy, defaultValue: 0.67);

  static double get subtitleStrokeWidth =>
      setting.get(SettingBoxKey.subtitleStrokeWidth, defaultValue: 2.0);

  static int get subtitleFontWeight =>
      setting.get(SettingBoxKey.subtitleFontWeight, defaultValue: 5);

  static bool get badCertificateCallback =>
      setting.get(SettingBoxKey.badCertificateCallback, defaultValue: false);

  static bool get continuePlayingPart =>
      setting.get(SettingBoxKey.continuePlayingPart, defaultValue: true);

  static bool get cdnSpeedTest =>
      setting.get(SettingBoxKey.cdnSpeedTest, defaultValue: true);

  static bool get autoUpdate =>
      GStorage.setting.get(SettingBoxKey.autoUpdate, defaultValue: true);

  static bool get horizontalPreview => GStorage.setting
      .get(SettingBoxKey.horizontalPreview, defaultValue: false);

  static bool get openInBrowser =>
      GStorage.setting.get(SettingBoxKey.openInBrowser, defaultValue: false);

  static bool get savedRcmdTip =>
      GStorage.setting.get(SettingBoxKey.savedRcmdTip, defaultValue: true);

  static bool get showVipDanmaku =>
      GStorage.setting.get(SettingBoxKey.showVipDanmaku, defaultValue: true);

  static bool get mergeDanmaku =>
      GStorage.setting.get(SettingBoxKey.mergeDanmaku, defaultValue: false);

  static bool get showHotRcmd =>
      GStorage.setting.get(SettingBoxKey.showHotRcmd, defaultValue: false);

  static String get audioNormalization =>
      GStorage.setting.get(SettingBoxKey.audioNormalization, defaultValue: '0');

  static int get superResolutionType =>
      GStorage.setting.get(SettingBoxKey.superResolutionType, defaultValue: 0);

  static bool get preInitPlayer =>
      GStorage.setting.get(SettingBoxKey.preInitPlayer, defaultValue: false);

  static bool get mainTabBarView =>
      GStorage.setting.get(SettingBoxKey.mainTabBarView, defaultValue: false);

  static bool get searchSuggestion =>
      GStorage.setting.get(SettingBoxKey.searchSuggestion, defaultValue: true);

  static bool get showDynDecorate =>
      GStorage.setting.get(SettingBoxKey.showDynDecorate, defaultValue: true);

  static bool get enableLivePhoto =>
      GStorage.setting.get(SettingBoxKey.enableLivePhoto, defaultValue: true);

  static bool get showSeekPreview =>
      GStorage.setting.get(SettingBoxKey.showSeekPreview, defaultValue: true);

  static bool get showDmChart =>
      GStorage.setting.get(SettingBoxKey.showDmChart, defaultValue: false);

  static bool get enableCommAntifraud => GStorage.setting
      .get(SettingBoxKey.enableCommAntifraud, defaultValue: false);

  static bool get biliSendCommAntifraud => GStorage.setting
      .get(SettingBoxKey.biliSendCommAntifraud, defaultValue: false);

  static bool get enableCreateDynAntifraud => GStorage.setting
      .get(SettingBoxKey.enableCreateDynAntifraud, defaultValue: false);

  static bool get coinWithLike =>
      GStorage.setting.get(SettingBoxKey.coinWithLike, defaultValue: false);

  static bool get isPureBlackTheme =>
      GStorage.setting.get(SettingBoxKey.isPureBlackTheme, defaultValue: false);

  static bool antiGoodsDyn =
      GStorage.setting.get(SettingBoxKey.antiGoodsDyn, defaultValue: false);

  static bool get antiGoodsReply =>
      GStorage.setting.get(SettingBoxKey.antiGoodsReply, defaultValue: false);

  static bool get expandDynLivePanel => GStorage.setting
      .get(SettingBoxKey.expandDynLivePanel, defaultValue: false);

  static bool collapsibleVideoPage = GStorage.setting
      .get(SettingBoxKey.collapsibleVideoPage, defaultValue: true);

  static bool slideDismissReplyPage = GStorage.setting
      .get(SettingBoxKey.slideDismissReplyPage, defaultValue: Platform.isIOS);

  static bool get showFSActionItem =>
      GStorage.setting.get(SettingBoxKey.showFSActionItem, defaultValue: true);

  static bool get enableShrinkVideoSize => GStorage.setting
      .get(SettingBoxKey.enableShrinkVideoSize, defaultValue: true);

  static bool get showDynActionBar =>
      GStorage.setting.get(SettingBoxKey.showDynActionBar, defaultValue: true);

  static bool get darkVideoPage =>
      GStorage.setting.get(SettingBoxKey.darkVideoPage, defaultValue: false);

  static bool get enableSlideVolumeBrightness => GStorage.setting
      .get(SettingBoxKey.enableSlideVolumeBrightness, defaultValue: true);

  static int get retryCount =>
      GStorage.setting.get(SettingBoxKey.retryCount, defaultValue: 0);

  static int get retryDelay =>
      GStorage.setting.get(SettingBoxKey.retryDelay, defaultValue: 500);

  static List<double> get dynamicDetailRatio => List<double>.from(setting
      .get(SettingBoxKey.dynamicDetailRatio, defaultValue: [60.0, 40.0]));

  static List<int> get blackMidsList => List<int>.from(GStorage.localCache
      .get(LocalCacheKey.blackMidsList, defaultValue: <int>[]));

  static RuleFilter get danmakuFilterRule => GStorage.localCache
      .get(LocalCacheKey.danmakuFilterRules, defaultValue: RuleFilter.empty());

  static void setBlackMidsList(blackMidsList) {
    if (blackMidsList is! List<int>) return;
    GStorage.localCache.put(LocalCacheKey.blackMidsList, blackMidsList);
  }

  static MemberTabType get memberTab => MemberTabType
      .values[setting.get(SettingBoxKey.memberTab, defaultValue: 0)];

  static int get themeTypeInt =>
      setting.get(SettingBoxKey.themeMode, defaultValue: ThemeType.system.code);

  static ThemeMode get themeMode {
    return switch (themeTypeInt) {
      0 => ThemeMode.light,
      1 => ThemeMode.dark,
      _ => ThemeMode.system
    };
  }

  // static final SpringDescription _kDefaultSpring = SpringDescription.withDampingRatio(
  // mass: 0.5,
  // stiffness: 100.0,
  // ratio: 1.1,
  // );
  // damping = ratio * 2.0 * math.sqrt(mass * stiffness)
  static final List<double> springDescription = List<double>.from(
    setting.get(
      SettingBoxKey.springDescription, // [mass, stiffness, damping]
      defaultValue: [0.5, 100.0, 2.2 * sqrt(50)],
    ),
  );

  // static Brightness get brightness {
  //   return switch (_themeMode) {
  //     0 => Brightness.light,
  //     1 => Brightness.dark,
  //     _ => PlatformDispatcher.instance.platformBrightness
  //   };
  // }

  static Future<void> init() async {
    final Directory dir = await getApplicationSupportDirectory();
    final String path = dir.path;
    await Hive.initFlutter('$path/hive');
    regAdapter();
    // 登录用户信息
    userInfo = await Hive.openBox(
      'userInfo',
      compactionStrategy: (int entries, int deletedEntries) {
        return deletedEntries > 2;
      },
    );
    // 本地缓存
    localCache = await Hive.openBox(
      'localCache',
      compactionStrategy: (int entries, int deletedEntries) {
        return deletedEntries > 4;
      },
    );
    // 设置
    setting = await Hive.openBox('setting');
    // 搜索历史
    historyWord = await Hive.openBox(
      'historyWord',
      compactionStrategy: (int entries, int deletedEntries) {
        return deletedEntries > 10;
      },
    );
    // 视频设置
    video = await Hive.openBox('video');
    displacement = GStorage.refreshDisplacement;
    kDragContainerExtentPercentage = GStorage.refreshDragPercentage;

    await Accounts.init();

    // 设置全局变量
    GlobalData()
      ..imgQuality = defaultPicQa
      ..grpcReply = grpcReply
      ..replyLengthLimit = replyLengthLimit;
  }

  static Future<String> exportAllSettings() async {
    return jsonEncode({
      setting.name: setting.toMap(),
      video.name: video.toMap(),
    });
  }

  static Future<void> importAllSettings(String data) async {
    final Map<String, dynamic> map = jsonDecode(data);
    await setting.clear();
    await video.clear();
    await setting.putAll(map[setting.name]);
    await video.putAll(map[video.name]);
  }

  static void regAdapter() {
    Hive.registerAdapter(OwnerAdapter());
    Hive.registerAdapter(UserInfoDataAdapter());
    Hive.registerAdapter(LevelInfoAdapter());
    Hive.registerAdapter(HotSearchModelAdapter());
    Hive.registerAdapter(HotSearchItemAdapter());
    Hive.registerAdapter(BiliCookieJarAdapter());
    Hive.registerAdapter(LoginAccountAdapter());
    Hive.registerAdapter(AccountTypeAdapter());
    Hive.registerAdapter(RuleFilterAdapter());
  }

  static Future<void> close() async {
    // user.compact();
    // user.close();
    userInfo.compact();
    userInfo.close();
    historyWord.compact();
    historyWord.close();
    localCache.compact();
    localCache.close();
    setting.compact();
    setting.close();
    video.compact();
    video.close();
    Accounts.close();
  }
}

class SettingBoxKey {
  /// 播放器
  static const String btmProgressBehavior = 'btmProgressBehavior',
      defaultVideoSpeed = 'defaultVideoSpeed',
      autoUpgradeEnable = 'autoUpgradeEnable',
      feedBackEnable = 'feedBackEnable',
      defaultVideoQa = 'defaultVideoQa',
      defaultVideoQaCellular = 'defaultVideoQaCellular',
      defaultAudioQa = 'defaultAudioQa',
      defaultAudioQaCellular = 'defaultAudioQaCellular',
      autoPlayEnable = 'autoPlayEnable',
      fullScreenMode = 'fullScreenMode',
      defaultDecode = 'defaultDecode',
      secondDecode = 'secondDecode',
      danmakuEnable = 'danmakuEnable',
      defaultToastOp = 'defaultToastOp',
      defaultPicQa = 'defaultPicQa',
      enableHA = 'enableHA',
      useOpenSLES = 'useOpenSLES',
      expandBuffer = 'expandBuffer',
      hardwareDecoding = 'hardwareDecoding',
      videoSync = 'videoSync',
      enableVerticalExpand = 'enableVerticalExpand',
      enableOnlineTotal = 'enableOnlineTotal',
      enableAutoBrightness = 'enableAutoBrightness',
      enableAutoEnter = 'enableAutoEnter',
      enableAutoExit = 'enableAutoExit',
      enableLongShowControl = 'enableLongShowControl',
      allowRotateScreen = 'allowRotateScreen',
      horizontalScreen = 'horizontalScreen',
      p1080 = 'p1080',
      // ignore: constant_identifier_names
      CDNService = 'CDNService',
      disableAudioCDN = 'disableAudioCDN',
      // enableCDN = 'enableCDN',
      autoPiP = 'autoPiP',
      pipNoDanmaku = 'pipNoDanmaku',
      enableAutoLongPressSpeed = 'enableAutoLongPressSpeed',
      subtitlePreference = 'subtitlePreference',
      defaultQn = 'defaultQn',
      defaultVolume = 'defaultVolume',

      // youtube 双击快进快退
      enableQuickDouble = 'enableQuickDouble',
      fullScreenGestureReverse = 'fullScreenGestureReverse',
      enableShowDanmaku = 'enableShowDanmaku',
      enableBackgroundPlay = 'enableBackgroundPlay',
      continuePlayInBackground = 'continuePlayInBackground',

      /// 隐私
      // anonymity = 'anonymity',

      /// 推荐
      enableRcmdDynamic = 'enableRcmdDynamic',
      appRcmd = 'appRcmd',
      enableSaveLastData = 'enableSaveLastData',
      minDurationForRcmd = 'minDurationForRcmd',
      minLikeRatioForRecommend = 'minLikeRatioForRecommend',
      exemptFilterForFollowed = 'exemptFilterForFollowed',
      banWordForRecommend = 'banWordForRecommend',
      //filterUnfollowedRatio = 'filterUnfollowedRatio',
      applyFilterToRelatedVideos = 'applyFilterToRelatedVideos',

      /// 其他
      autoUpdate = 'autoUpdate',
      autoClearCache = 'autoClearCache',
      defaultShowComment = 'defaultShowComment',
      replySortType = 'replySortType',
      defaultDynamicType = 'defaultDynamicType',
      enableHotKey = 'enableHotKey',
      enableQuickFav = 'enableQuickFav',
      enableWordRe = 'enableWordRe',
      enableSearchWord = 'enableSearchWord',
      enableSystemProxy = 'enableSystemProxy',
      enableAi = 'enableAi',
      disableLikeMsg = 'disableLikeMsg',
      defaultHomePage = 'defaultHomePage',
      previewQuality = 'previewQuality',
      checkDynamic = 'checkDynamic',
      dynamicPeriod = 'dynamicPeriod',
      schemeVariant = 'schemeVariant',
      grpcReply = 'grpcReply',
      showViewPoints = 'showViewPoints',
      showRelatedVideo = 'showRelatedVideo',
      showVideoReply = 'showVideoReply',
      showBangumiReply = 'showBangumiReply',
      alwaysExapndIntroPanel = 'alwaysExapndIntroPanel',
      exapndIntroPanelH = 'exapndIntroPanelH',
      horizontalSeasonPanel = 'horizontalSeasonPanel',
      horizontalMemberPage = 'horizontalMemberPage',
      replyLengthLimit = 'replyLengthLimit',
      showArgueMsg = 'showArgueMsg',
      reverseFromFirst = 'reverseFromFirst',
      subtitlePaddingH = 'subtitlePaddingH',
      subtitlePaddingB = 'subtitlePaddingB',
      subtitleBgOpaticy = 'subtitleBgOpaticy',
      subtitleStrokeWidth = 'subtitleStrokeWidth',
      subtitleFontScale = 'subtitleFontScale',
      subtitleFontScaleFS = 'subtitleFontScaleFS',
      subtitleFontWeight = 'subtitleFontWeight',
      badCertificateCallback = 'badCertificateCallback',
      continuePlayingPart = 'continuePlayingPart',
      cdnSpeedTest = 'cdnSpeedTest',
      horizontalPreview = 'horizontalPreview',
      banWordForReply = 'banWordForReply',
      banWordForZone = 'banWordForZone',
      savedRcmdTip = 'savedRcmdTip',
      openInBrowser = 'openInBrowser',
      refreshDragPercentage = 'refreshDragPercentage',
      refreshDisplacement = 'refreshDisplacement',
      showVipDanmaku = 'showVipDanmaku',
      mergeDanmaku = 'mergeDanmaku',
      showHotRcmd = 'showHotRcmd',
      audioNormalization = 'audioNormalization',
      superResolutionType = 'superResolutionType',
      preInitPlayer = 'preInitPlayer',
      mainTabBarView = 'mainTabBarView',
      searchSuggestion = 'searchSuggestion',
      showDynDecorate = 'showDynDecorate',
      enableLivePhoto = 'enableLivePhoto',
      showSeekPreview = 'showSeekPreview',
      showDmChart = 'showDmChart',
      enableCommAntifraud = 'enableCommAntifraud',
      biliSendCommAntifraud = 'biliSendCommAntifraud',
      enableCreateDynAntifraud = 'enableCreateDynAntifraud',
      coinWithLike = 'coinWithLike',
      isPureBlackTheme = 'isPureBlackTheme',
      antiGoodsDyn = 'antiGoodsDyn',
      antiGoodsReply = 'antiGoodsReply',
      expandDynLivePanel = 'expandDynLivePanel',
      springDescription = 'springDescription',
      collapsibleVideoPage = 'collapsibleVideoPage',
      enableHttp2 = 'enableHttp2',
      slideDismissReplyPage = 'slideDismissReplyPage',
      showFSActionItem = 'showFSActionItem',
      enableShrinkVideoSize = 'enableShrinkVideoSize',
      showDynActionBar = 'showDynActionBar',
      darkVideoPage = 'darkVideoPage',
      enableSlideVolumeBrightness = 'enableSlideVolumeBrightness',
      retryCount = 'retryCount',
      retryDelay = 'retryDelay',

      // Sponsor Block
      enableSponsorBlock = 'enableSponsorBlock',
      blockSettings = 'blockSettings',
      blockLimit = 'blockLimit',
      blockColor = 'blockColor',
      blockUserID = 'blockUserID',
      blockToast = 'blockToast',
      blockServer = 'blockServer',
      blockTrack = 'blockTrack',

      // 弹幕相关设置 权重（云屏蔽） 屏蔽类型 显示区域 透明度 字体大小 弹幕时间 描边粗细 字体粗细
      danmakuWeight = 'danmakuWeight',
      danmakuBlockType = 'danmakuBlockType',
      danmakuShowArea = 'danmakuShowArea',
      danmakuOpacity = 'danmakuOpacity',
      danmakuFontScale = 'danmakuFontScale',
      danmakuFontScaleFS = 'danmakuFontScaleFS',
      danmakuDuration = 'danmakuDuration',
      danmakuMassiveMode = 'danmakuMassiveMode',
      danmakuLineHeight = 'danmakuLineHeight',
      strokeWidth = 'strokeWidth',
      fontWeight = 'fontWeight',
      memberTab = 'memberTab',
      dynamicDetailRatio = 'dynamicDetailRatio',

      // 代理host port
      systemProxyHost = 'systemProxyHost',
      systemProxyPort = 'systemProxyPort';

  /// 外观
  static const String themeMode = 'themeMode',
      defaultTextScale = 'textScale',
      dynamicColor = 'dynamicColor', // bool
      customColor = 'customColor', // 自定义主题色
      enableSingleRow = 'enableSingleRow', // 首页单列
      displayMode = 'displayMode',
      mediumCardWidth = 'mediumCardWidth', // 首页列最大宽度（dp）
      smallCardWidth = 'smallCardWidth',
      videoPlayerRemoveSafeArea = 'videoPlayerRemoveSafeArea', // 视频播放器移除安全边距
      // videoPlayerShowStatusBarBackgroundColor =
      //     'videoPlayerShowStatusBarBackgroundColor', // 播放页状态栏显示为背景色
      dynamicsWaterfallFlow = 'dynamicsWaterfallFlow', // 动态瀑布流
      upPanelPosition = 'upPanelPosition', // up主面板位置
      dynamicsShowAllFollowedUp = 'dynamicsShowAllFollowedUp', // 动态显示全部关注up
      useSideBar = 'useSideBar',
      enableMYBar = 'enableMYBar',
      hideSearchBar = 'hideSearchBar', // 收起顶栏
      hideTabBar = 'hideTabBar', // 收起底栏
      tabbarSort = 'tabbarSort', // 首页tabbar
      dynamicBadgeMode = 'dynamicBadgeMode',
      msgBadgeMode = 'msgBadgeMode',
      // msgUnReadType = 'msgUnReadType',
      msgUnReadTypeV2 = 'msgUnReadTypeV2',
      hiddenSettingUnlocked = 'hiddenSettingUnlocked',
      enableGradientBg = 'enableGradientBg',
      navBarSort = 'navBarSort';
}

class LocalCacheKey {
  // 历史记录暂停状态 默认false 记录
  static const String historyPause = 'historyPause',

      // 隐私设置-黑名单管理
      blackMidsList = 'blackMidsList',
      // 弹幕屏蔽规则
      danmakuFilterRules = 'danmakuFilterRules',
      // // access_key
      // accessKey = 'accessKey',

      //
      mixinKey = 'mixinKey',
      timeStamp = 'timeStamp';
}

class VideoBoxKey {
  // 视频比例
  static const String videoFit = 'videoFit',
      // 亮度
      videoBrightness = 'videoBrightness',
      // 倍速
      videoSpeed = 'videoSpeed',
      // 播放顺序
      playRepeat = 'playRepeat',
      // 默认倍速
      playSpeedDefault = 'playSpeedDefault',
      // 默认长按倍速
      longPressSpeedDefault = 'longPressSpeedDefault',
      // 倍速集合
      speedsList = 'speedsList',
      // 画面填充比例
      cacheVideoFit = 'cacheVideoFit';
}

class Accounts {
  static late final Box<LoginAccount> account;
  static final Map<AccountType, Account> accountMode = {};
  static Account get main => accountMode[AccountType.main]!;
  // static set main(Account account) => set(AccountType.main, account);

  static Future<void> init() async {
    account = await Hive.openBox('account',
        compactionStrategy: (int entries, int deletedEntries) {
      return deletedEntries > 2;
    });
    await _migrate();
  }

  static Future<void> _migrate() async {
    final Directory tempDir = await getApplicationSupportDirectory();
    final String tempPath = "${tempDir.path}/.plpl/";
    final Directory dir = Directory(tempPath);
    if (await dir.exists()) {
      debugPrint('migrating...');
      final cookieJar =
          PersistCookieJar(ignoreExpires: true, storage: FileStorage(tempPath));
      await cookieJar.forceInit();
      final cookies = DefaultCookieJar(ignoreExpires: true)
        ..domainCookies.addAll(cookieJar.domainCookies);
      final localAccessKey =
          GStorage.localCache.get('accessKey', defaultValue: {});

      final isLogin =
          cookies.domainCookies['bilibili.com']?['/']?['SESSDATA'] != null;

      await Future.wait([
        GStorage.localCache.delete('accessKey'),
        GStorage.localCache.delete('danmakuFilterRule'),
        dir.delete(recursive: true),
        if (isLogin)
          LoginAccount(cookies, localAccessKey['value'],
                  localAccessKey['refresh'], AccountType.values.toSet())
              .onChange()
      ]);
      debugPrint('migrated successfully');
    }
  }

  static Future<void> refresh() async {
    for (var a in account.values) {
      for (var t in a.type) {
        accountMode[t] = a;
      }
    }
    for (var type in AccountType.values) {
      accountMode[type] ??= AnonymousAccount();
    }
    await Future.wait((accountMode.values.toSet()
          ..retainWhere((i) => !i.activited))
        .map((i) => Request.buvidActive(i)));
  }

  static Future<void> clear() async {
    await account.clear();
    for (var i in AccountType.values) {
      accountMode[i] = AnonymousAccount();
    }
    await AnonymousAccount().delete();
    Request.buvidActive(AnonymousAccount());
  }

  static Future<void> close() async {
    account.compact();
    account.close();
  }

  static Future<void> deleteAll(Set<Account> accounts) async {
    var isloginMain = Accounts.main.isLogin;
    Accounts.accountMode
        .updateAll((_, a) => accounts.contains(a) ? AnonymousAccount() : a);
    await Future.wait(accounts.map((i) => i.delete()));
    if (isloginMain && !Accounts.main.isLogin) {
      await LoginUtils.onLogoutMain();
    }
  }

  static Future<void> set(AccountType key, Account account) async {
    await (accountMode[key]?..type.remove(key))?.onChange();
    accountMode[key] = account..type.add(key);
    await account.onChange();
    if (!account.activited) await Request.buvidActive(account);
    switch (key) {
      case AccountType.main:
        await (account.isLogin
            ? LoginUtils.onLoginMain()
            : LoginUtils.onLogoutMain());
        break;
      case AccountType.heartbeat:
        MineController.anonymity.value = !account.isLogin;
        break;
      default:
        break;
    }
  }

  static Account get(AccountType key) {
    return accountMode[key]!;
  }
}

enum AccountType {
  main,
  heartbeat,
  recommend,
  video,
}

extension AccountTypeExt on AccountType {
  String get title => const ['主账号', '记录观看', '推荐', '视频取流'][index];
}
