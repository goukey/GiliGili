import 'package:GiliGili/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:GiliGili/utils/extension.dart';
import '../constants.dart';

class NetworkImgLayer extends StatelessWidget {
  const NetworkImgLayer({
    super.key,
    this.src,
    required this.width,
    required this.height,
    this.type,
    this.fadeOutDuration,
    this.fadeInDuration,
    // 图片质量 默认1%
    this.quality,
    this.semanticsLabel,
    this.ignoreHeight,
    this.radius,
    this.imageBuilder,
    this.isLongPic,
    this.callback,
    this.getPlaceHolder,
  });

  final String? src;
  final double width;
  final double height;
  final String? type;
  final Duration? fadeOutDuration;
  final Duration? fadeInDuration;
  final int? quality;
  final String? semanticsLabel;
  final bool? ignoreHeight;
  final double? radius;
  final ImageWidgetBuilder? imageBuilder;
  final Function? isLongPic;
  final Function? callback;
  final Function? getPlaceHolder;

  @override
  Widget build(BuildContext context) {
    return src.isNullOrEmpty.not
        ? type == 'avatar'
            ? ClipOval(child: _buildImage(context))
            : radius == 0 || type == 'emote'
                ? _buildImage(context)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(
                      radius ?? StyleString.imgRadius.x,
                    ),
                    child: _buildImage(context),
                  )
        : getPlaceHolder?.call() ?? placeholder(context);
  }

  Widget _buildImage(context) {
    int? memCacheWidth, memCacheHeight;
    if (callback?.call() == true || width <= height) {
      memCacheWidth = width.cacheSize(context);
    } else {
      memCacheHeight = height.cacheSize(context);
    }
    return CachedNetworkImage(
      imageUrl: Utils.thumbnailImgUrl(src, quality),
      width: width,
      height: ignoreHeight == null || ignoreHeight == false ? height : null,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      fit: BoxFit.cover,
      alignment:
          isLongPic?.call() == true ? Alignment.topCenter : Alignment.center,
      fadeOutDuration: fadeOutDuration ?? const Duration(milliseconds: 120),
      fadeInDuration: fadeInDuration ?? const Duration(milliseconds: 120),
      filterQuality: FilterQuality.low,
      placeholder: (BuildContext context, String url) =>
          getPlaceHolder?.call() ?? placeholder(context),
      imageBuilder: imageBuilder,
    );
  }

  Widget placeholder(BuildContext context) {
    int cacheWidth = width.cacheSize(context);
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: type == 'avatar' ? BoxShape.circle : BoxShape.rectangle,
        color: Theme.of(context).colorScheme.onInverseSurface.withOpacity(0.4),
        borderRadius: type == 'avatar' || type == 'emote' || radius == 0
            ? null
            : BorderRadius.circular(
                radius ?? StyleString.imgRadius.x,
              ),
      ),
      child: type == 'bg'
          ? const SizedBox()
          : Center(
              child: Image.asset(
                type == 'avatar'
                    ? 'assets/images/noface.jpeg'
                    : 'assets/images/loading.png',
                width: width,
                height: height,
                cacheWidth: cacheWidth == 0 ? null : cacheWidth,
                // cacheHeight: height.cacheSize(context),
              ),
            ),
    );
  }
}
