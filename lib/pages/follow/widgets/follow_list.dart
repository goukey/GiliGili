import 'package:GiliGili/common/widgets/loading_widget.dart';
import 'package:GiliGili/common/widgets/refresh_indicator.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:GiliGili/models/follow/result.dart';
import 'package:GiliGili/pages/follow/index.dart';

import 'follow_item.dart';

class FollowList extends StatefulWidget {
  final FollowController ctr;
  const FollowList({
    super.key,
    required this.ctr,
  });

  @override
  State<FollowList> createState() => _FollowListState();
}

class _FollowListState extends State<FollowList> {
  late Future _futureBuilderFuture;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = widget.ctr.queryFollowings('init');
    scrollController.addListener(listener);
  }

  void listener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      EasyThrottle.throttle('follow', const Duration(seconds: 1), () {
        widget.ctr.queryFollowings('onLoad');
      });
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(listener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return refreshIndicator(
      onRefresh: () async => await widget.ctr.queryFollowings('init'),
      child: FutureBuilder(
        future: _futureBuilderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var data = snapshot.data;
            if (data['status']) {
              List<FollowItemModel> list = widget.ctr.followList;
              return Obx(
                () => list.isNotEmpty
                    ? ListView.builder(
                        controller: scrollController,
                        itemCount: list.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == list.length) {
                            return Container(
                              height:
                                  MediaQuery.of(context).padding.bottom + 80,
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).padding.bottom),
                              child: Center(
                                child: Obx(
                                  () => Text(
                                    widget.ctr.loadingText.value,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        fontSize: 13),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return FollowItem(
                              item: list[index],
                              ctr: widget.ctr,
                            );
                          }
                        },
                      )
                    : errorWidget(
                        callback: () => widget.ctr.queryFollowings('init'),
                      ),
              );
            } else {
              return errorWidget(
                errMsg: data['msg'],
                callback: () => widget.ctr.queryFollowings('init'),
              );
            }
          } else {
            // 骨架屏
            return const SizedBox();
          }
        },
      ),
    );
  }
}
