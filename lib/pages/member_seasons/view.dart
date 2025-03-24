import 'package:GiliGili/common/widgets/http_error.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:GiliGili/common/constants.dart';
import '../../utils/grid.dart';
import 'controller.dart';
import 'widgets/item.dart';

class MemberSeasonsPage extends StatefulWidget {
  const MemberSeasonsPage({super.key});

  @override
  State<MemberSeasonsPage> createState() => _MemberSeasonsPageState();
}

class _MemberSeasonsPageState extends State<MemberSeasonsPage> {
  final MemberSeasonsController _memberSeasonsController =
      Get.put(MemberSeasonsController());
  late Future _futureBuilderFuture;

  @override
  void dispose() {
    _memberSeasonsController.scrollController.removeListener(listener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture =
        _memberSeasonsController.getSeasonDetail('onRefresh');
    _memberSeasonsController.scrollController.addListener(listener);
  }

  void listener() {
    if (_memberSeasonsController.scrollController.position.pixels >=
        _memberSeasonsController.scrollController.position.maxScrollExtent -
            200) {
      EasyThrottle.throttle(
          'member_archives', const Duration(milliseconds: 500), () {
        _memberSeasonsController.onLoad();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ta的专栏')),
      body: Padding(
        padding: const EdgeInsets.only(
          left: StyleString.safeSpace,
          right: StyleString.safeSpace,
        ),
        child: SingleChildScrollView(
          controller: _memberSeasonsController.scrollController,
          child: FutureBuilder(
            future: _futureBuilderFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data != null) {
                  // TODO: refactor
                  if (snapshot.data is! Map) {
                    return HttpError(
                      isSliver: false,
                      callback: () => setState(() {
                        _futureBuilderFuture = _memberSeasonsController
                            .getSeasonDetail('onRefresh');
                      }),
                    );
                  }
                  Map data = snapshot.data as Map;
                  List list = _memberSeasonsController.seasonsList;
                  if (data['status']) {
                    return Obx(
                      () => list.isNotEmpty
                          ? LayoutBuilder(
                              builder: (context, boxConstraints) {
                                return GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithExtentAndRatio(
                                    mainAxisSpacing: StyleString.cardSpace,
                                    crossAxisSpacing: StyleString.cardSpace,
                                    maxCrossAxisExtent: Grid.smallCardWidth,
                                    childAspectRatio: 0.94,
                                  ),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _memberSeasonsController
                                      .seasonsList.length,
                                  itemBuilder: (context, i) {
                                    return MemberSeasonsItem(
                                      seasonItem: _memberSeasonsController
                                          .seasonsList[i],
                                    );
                                  },
                                );
                              },
                            )
                          : const SizedBox(),
                    );
                  } else {
                    return const SizedBox();
                  }
                } else {
                  return const SizedBox();
                }
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }
}
