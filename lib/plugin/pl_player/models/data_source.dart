import 'dart:io';

/// The way in which the video was originally loaded.
///
/// This has nothing to do with the video's file type. It's just the place
/// from which the video is fetched from.
enum DataSourceType {
  /// The video was included in the app's asset files.
  asset,

  /// The video was downloaded from the internet.
  network,

  /// The video was loaded off of the local filesystem.
  file,

  /// The video is available via contentUri. Android only.
  contentUri,
}

class DataSource {
  File? file;
  String? videoSource;
  String? audioSource;
  String? subFiles;
  DataSourceType type;
  Map<String, String>? httpHeaders; // for headers
  
  // 添加视频信息相关属性
  final String url;
  final int? cid;
  final String? title;
  final String? videoTitle;
  final String? epId;
  final String? seasonId;
  final String? type2;
  final int? quality;
  final String? bvid;
  
  DataSource({
    this.file,
    this.videoSource,
    this.audioSource,
    this.subFiles,
    required this.type,
    this.httpHeaders,
    required this.url,
    this.cid,
    this.title,
    this.videoTitle,
    this.epId,
    this.seasonId,
    this.type2,
    this.quality,
    this.bvid,
  }) : assert((type == DataSourceType.file && file != null) ||
            videoSource != null || url.isNotEmpty);

  DataSource copyWith({
    File? file,
    String? videoSource,
    String? audioSource,
    String? subFiles,
    DataSourceType? type,
    Map<String, String>? httpHeaders,
    String? url,
    int? cid,
    String? title,
    String? videoTitle,
    String? epId,
    String? seasonId,
    String? type2,
    int? quality,
    String? bvid,
  }) {
    return DataSource(
      file: file ?? this.file,
      videoSource: videoSource ?? this.videoSource,
      audioSource: audioSource ?? this.audioSource,
      subFiles: subFiles ?? this.subFiles,
      type: type ?? this.type,
      httpHeaders: httpHeaders ?? this.httpHeaders,
      url: url ?? this.url,
      cid: cid ?? this.cid,
      title: title ?? this.title,
      videoTitle: videoTitle ?? this.videoTitle,
      epId: epId ?? this.epId,
      seasonId: seasonId ?? this.seasonId,
      type2: type2 ?? this.type2,
      quality: quality ?? this.quality,
      bvid: bvid ?? this.bvid,
    );
  }
}
