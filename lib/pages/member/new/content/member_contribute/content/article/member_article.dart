import 'package:GiliGili/common/constants.dart';
import 'package:GiliGili/common/widgets/loading_widget.dart';
import 'package:GiliGili/common/widgets/refresh_indicator.dart';
import 'package:GiliGili/common/widgets/network_img_layer.dart';
import 'package:GiliGili/http/loading_state.dart';
import 'package:GiliGili/models/space_article/item.dart';
import 'package:GiliGili/pages/member/new/content/member_contribute/content/article/member_article_ctr.dart';
import 'package:GiliGili/utils/app_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberArticle extends StatefulWidget {
  const MemberArticle({
    super.key,
    required this.heroTag,
    required this.mid,
  });

  final String? heroTag;
  final int mid;

  @override
  State<MemberArticle> createState() => _MemberArticleState();
}

class _MemberArticleState extends State<MemberArticle>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final _controller = Get.put(
    MemberArticleCtr(mid: widget.mid),
    tag: widget.heroTag,
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() => _buildBody(_controller.loadingState.value));
  }

  _buildBody(LoadingState loadingState) {
    return switch (loadingState) {
      Loading() => loadingWidget,
      Success() => (loadingState.response as List?)?.isNotEmpty == true
          ? MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: refreshIndicator(
                onRefresh: () async {
                  await _controller.onRefresh();
                },
                child: ListView.separated(
                  itemCount: loadingState.response.length,
                  itemBuilder: (context, index) {
                    if (index == loadingState.response.length - 1) {
                      _controller.onLoadMore();
                    }
                    Item item = loadingState.response[index];
                    return ListTile(
                      dense: true,
                      onTap: () {
                        PiliScheme.routePushFromUrl(item.uri ?? '');
                      },
                      leading: item.originImageUrls?.isNotEmpty == true
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return NetworkImgLayer(
                                    radius: 6,
                                    src: item.originImageUrls!.first,
                                    width: constraints.maxHeight *
                                        StyleString.aspectRatio,
                                    height: constraints.maxHeight,
                                  );
                                },
                              ),
                            )
                          : null,
                      title: Text(
                        item.title ?? '',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      subtitle: item.summary?.isNotEmpty == true
                          ? Text(
                              item.summary!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            )
                          : null,
                    );
                  },
                  separatorBuilder: (context, index) => Divider(height: 1),
                ),
              ),
            )
          : scrollErrorWidget(
              callback: _controller.onReload,
            ),
      Error() => scrollErrorWidget(
          errMsg: loadingState.errMsg,
          callback: _controller.onReload,
        ),
      LoadingState() => throw UnimplementedError(),
    };
  }
}
