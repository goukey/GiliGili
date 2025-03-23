import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class CommonController extends GetxController {
  final ScrollController scrollController = ScrollController();

  int currentPage = 1;
  bool isLoading = false;
  bool isEnd = false;
  Rx<LoadingState> loadingState = LoadingState.loading().obs;

  Future<LoadingState> customGetData();

  List? handleListResponse(List currentList, List dataList) {
    return null;
  }

  bool customHandleResponse(Success response) {
    return false;
  }

  bool handleError(String? errMsg) {
    return false;
  }

  // void handleSuccess(List currentList, List dataList) {}

  Future queryData([bool isRefresh = true]) async {
    if (isLoading || (isRefresh.not && isEnd)) return;
    isLoading = true;
    LoadingState response = await customGetData();
    if (response is Success) {
      if (!customHandleResponse(response)) {
        if ((response.response as List?).isNullOrEmpty) {
          isEnd = true;
        }
        List currentList = loadingState.value is Success
            ? (loadingState.value as Success).response
            : [];
        List? handleList = handleListResponse(currentList, response.response);
        loadingState.value = isRefresh
            ? handleList != null
                ? LoadingState.success(handleList)
                : response
            : LoadingState.success(currentList + response.response);
        // handleSuccess(currentList, response.response);
      }
      currentPage++;
    } else {
      if (isRefresh &&
          handleError(response is Error ? response.errMsg : null).not) {
        loadingState.value = response;
      }
    }
    isLoading = false;
  }

  Future onRefresh() async {
    currentPage = 1;
    isEnd = false;
    await queryData();
  }

  Future onLoadMore() async {
    await queryData(false);
  }

  void animateToTop() {
    scrollController.animToTop();
  }

  Future onReload() async {
    loadingState.value = LoadingState.loading();
    await onRefresh();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
