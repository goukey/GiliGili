import 'package:GiliGili/pages/search/controller.dart';
import 'package:GiliGili/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:GiliGili/models/common/search_type.dart';
import 'package:GiliGili/pages/search_panel/index.dart';
import 'controller.dart';
import 'package:GiliGili/common/widgets/spring_physics.dart';

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({super.key});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    with TickerProviderStateMixin {
  late SearchResultController _searchResultController;
  late TabController _tabController;
  final String _tag = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    _searchResultController = Get.put(
      SearchResultController(),
      tag: _tag,
    );

    _tabController = TabController(
      vsync: this,
      initialIndex: Get.arguments is int ? Get.arguments : 0,
      length: SearchType.values.length,
    );

    if (Get.arguments is int) {
      _tabController.addListener(listener);
    }
  }

  void listener() {
    if (Get.isRegistered<SSearchController>()) {
      Get.find<SSearchController>().initIndex = _tabController.index;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(listener);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.08),
            width: 1,
          ),
        ),
        title: GestureDetector(
          onTap: () {
            if (Get.previousRoute.startsWith('/search')) {
              Get.back();
            } else {
              Get.offNamed(
                '/search',
                parameters: {'text': _searchResultController.keyword},
              );
            }
          },
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _searchResultController.keyword,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 4),
            color: Theme.of(context).colorScheme.surface,
            child: Theme(
              data: ThemeData(
                splashColor: Colors.transparent, // 点击时的水波纹颜色设置为透明
                highlightColor: Colors.transparent, // 点击时的背景高亮颜色设置为透明
              ),
              child: TabBar(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                controller: _tabController,
                tabs: SearchType.values
                    .map(
                      (item) => Obx(
                        () {
                          int count = _searchResultController.count[item.index];
                          return Tab(
                              text:
                                  '${item.label}${count != -1 ? ' ${count > 99 ? '99+' : count}' : ''}');
                        },
                      ),
                    )
                    .toList(),
                isScrollable: true,
                indicatorWeight: 0,
                indicatorPadding:
                    const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Theme.of(context).colorScheme.onSecondaryContainer,
                labelStyle: const TextStyle(fontSize: 13),
                dividerColor: Colors.transparent,
                dividerHeight: 0,
                unselectedLabelColor: Theme.of(context).colorScheme.outline,
                tabAlignment: TabAlignment.start,
                onTap: (index) {
                  if (_tabController.indexIsChanging.not) {
                    Get.find<SearchPanelController>(
                            tag: SearchType.values[index].name + _tag)
                        .animateToTop();
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: tabBarView(
              controller: _tabController,
              children: SearchType.values
                  .map(
                    (item) => SearchPanel(
                      keyword: _searchResultController.keyword,
                      searchType: item,
                      tag: _tag,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
