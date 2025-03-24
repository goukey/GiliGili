import 'dart:async';
import 'dart:io';

import 'package:GiliGili/common/widgets/network_img_layer.dart';
import 'package:GiliGili/common/widgets/tabs.dart';
import 'package:GiliGili/pages/mine/controller.dart';
import 'package:GiliGili/utils/app_scheme.dart';
import 'package:GiliGili/utils/extension.dart';
import 'package:GiliGili/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:GiliGili/models/common/dynamic_badge_mode.dart';
import 'package:GiliGili/pages/dynamics/index.dart';
import 'package:GiliGili/pages/home/index.dart';
import 'package:GiliGili/utils/event_bus.dart';
import 'package:GiliGili/utils/feed_back.dart';
import 'package:GiliGili/utils/storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import './controller.dart';
import 'package:GiliGili/main.dart';

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);
  static final RouteObserver<Route> routeObserver = RouteObserver<Route>();

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late MainController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MainController());
    
    // 在TV平台上，直接导航到TV主页
    if (kIsAndroidTv) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/tvHome');
      });
    }
  }

  @override
  void dispose() {
    Get.delete<MainController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: Obx(() {
        return controller.pageList[controller.pageIndex.value];
      }),
      bottomNavigationBar: Obx(() {
        if (controller.selectedFirst.isNotEmpty) {
          return SizedBox(
            height: controller.navBarHeight.value,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).navigationBarTheme.backgroundColor ??
                    Theme.of(context).bottomAppBarTheme.color,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 0.3,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withAlpha(20),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent,
                labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
                height: controller.navBarHeight.value,
                selectedIndex: controller.pageIndex.value,
                onDestinationSelected: (index) {
                  // 避免重复点击
                  if (index == controller.pageIndex.value) {
                    controller.pageScrollUp(index);
                  } else {
                    controller.onDestinationSelected(index);
                  }
                },
                destinations: controller.selectedFirst.map((item) {
                  final int index = controller.selectedFirst.indexOf(item);
                  return NavigationDestination(
                    icon: index == controller.pageIndex.value
                        ? controller.getSelectedIcon(item)
                        : controller.getUnSelectedIcon(item),
                    label: controller.getLabel(item),
                  );
                }).toList(),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }
}
