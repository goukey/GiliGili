import 'dart:math';

import 'package:GiliGili/http/loading_state.dart';
import 'package:GiliGili/models/space/tab2.dart';
import 'package:GiliGili/pages/common/common_controller.dart';
import 'package:GiliGili/pages/member/new/controller.dart';
import 'package:GiliGili/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../models/space/item.dart';

class MemberContributeCtr extends CommonController
    with GetTickerProviderStateMixin {
  MemberContributeCtr({
    required this.heroTag,
    required this.initialIndex,
  });
  final String? heroTag;
  final int? initialIndex;

  TabController? tabController;
  List<Tab>? tabs;
  late final _ctr = Get.find<MemberControllerNew>(tag: heroTag);
  List<Item>? items;

  @override
  void onInit() {
    super.onInit();
    Tab2 contribute =
        _ctr.tab2!.firstWhere((item) => item.param == 'contribute');
    if (contribute.items?.isNullOrEmpty == false) {
      items = contribute.items;
      if (contribute.items!.length > 1) {
        // show if exist
        if (_ctr.hasSeasonOrSeries == true) {
          items!.add(
            Item(
              param: 'ugcSeason',
              title: '全部合集/列表',
            ),
          );
        }
        tabs = items!.map((item) => Tab(text: item.title)).toList();
        tabController = TabController(
          vsync: this,
          length: items!.length,
          initialIndex: max(0, initialIndex ?? 0),
        );
      }
    }
  }

  @override
  Future<LoadingState> customGetData() {
    throw UnimplementedError();
  }

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }
}
