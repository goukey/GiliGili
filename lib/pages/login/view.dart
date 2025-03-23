import 'dart:ui';

import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/widgets/spring_physics.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:PiliPlus/utils/tv_focus_utils.dart';
import 'package:PiliPlus/main.dart';
import 'package:PiliPlus/utils/feed_back.dart';

import 'controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginPageController _loginPageCtr = Get.put(LoginPageController());
  // late Future<Map<String, dynamic>> codeFuture;
  // 二维码生成时间
  bool showPassword = false;
  GlobalKey globalKey = GlobalKey();

  Widget loginByQRCode() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('使用 bilibili 官方 App 扫码登录'),
        const SizedBox(height: 20),
        Obx(() => Text('剩余有效时间: ${_loginPageCtr.qrCodeLeftTime} 秒',
            style: TextStyle(
                fontFeatures: const [FontFeature.tabularFigures()],
                color: Theme.of(context).colorScheme.primaryFixedDim))),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const SizedBox(width: 20),
            TvFocusable(
              autoFocus: true, // 自动获取焦点
              onTap: _loginPageCtr.refreshQRCode,
              child: TextButton.icon(
                onPressed: null, // 使用TvFocusable的onTap
                icon: const Icon(Icons.refresh),
                label: const Text('刷新二维码'),
              ),
            ),
            TvFocusable(
              onTap: () async {
                feedBack();
                SmartDialog.showLoading(msg: '正在生成截图');
                RenderRepaintBoundary boundary = globalKey.currentContext!
                    .findRenderObject()! as RenderRepaintBoundary;
                var image = await boundary.toImage();
                ByteData? byteData =
                    await image.toByteData(format: ImageByteFormat.png);
                Uint8List pngBytes = byteData!.buffer.asUint8List();
                SmartDialog.dismiss();
                SmartDialog.showLoading(msg: '正在保存至图库');
                String picName =
                    "PiliPlus_loginQRCode_${DateTime.now().toString().replaceAll(' ', '_').replaceAll(':', '-').split('.').first}";
                final SaveResult result = await SaverGallery.saveImage(
                  Uint8List.fromList(pngBytes),
                  fileName: picName,
                  extension: 'png',
                  // 保存到 PiliPlus文件夹
                  androidRelativePath: "Pictures/PiliPlus",
                  skipIfExists: false,
                );
                SmartDialog.dismiss();
                if (result.isSuccess) {
                  await SmartDialog.showToast('「$picName」已保存 ');
                } else {
                  await SmartDialog.showToast('保存失败，${result.errorMessage}');
                }
              },
              child: TextButton.icon(
                onPressed: null, // 使用TvFocusable的onTap
                icon: const Icon(Icons.save),
                label: const Text('保存至相册'),
              ),
            ),
          ],
        ),
        RepaintBoundary(
          key: globalKey,
          child: Obx(() {
            if (_loginPageCtr.codeInfo.value['data']?['url'] == null) {
              return Container(
                height: 200,
                width: 200,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  semanticsLabel: '二维码加载中',
                ),
              );
            }
            return QrImageView(
              backgroundColor: Colors.white,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black87,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black87,
              ),
              data: _loginPageCtr.codeInfo.value['data']!['url']!,
              size: 200,
              semanticsLabel: '二维码',
            );
          }),
        ),
        const SizedBox(height: 10),
        Obx(() => Text(
              _loginPageCtr.statusQRCode.value,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondaryFixedDim),
            )),
        Obx(() => GestureDetector(
              onTap: () {
                //以外部方式打开此链接
                // launchUrlString(
                //     _loginPageCtr.codeInfo.value['data']?['url'] ?? "",
                //     mode: LaunchMode.externalApplication);
                // 复制到剪贴板
                Utils.copyText(
                    _loginPageCtr.codeInfo.value['data']?['url'] ?? '',
                    toastText: '已复制到剪贴板，可粘贴至已登录的app私信处发送，然后点击已发送的链接打开');
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Text(_loginPageCtr.codeInfo.value['data']?['url'] ?? "",
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4))),
              ),
            )),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('请务必在 PiliPlus 开源仓库等可信渠道下载安装。',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4)))),
      ],
    );
  }

  Widget loginByCookie() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        const Text('使用Cookie登录'),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '使用App端Api实现的功能将不可用',
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextField(
            minLines: 1,
            maxLines: 10,
            controller: _loginPageCtr.cookieTextController,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.cookie_outlined),
              border: const UnderlineInputBorder(),
              labelText: 'Cookie',
              suffixIcon: TvFocusable(
                onTap: _loginPageCtr.cookieTextController.clear,
                child: IconButton(
                  onPressed: null, // 使用TvFocusable的onTap
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
          ),
        ),
        TvFocusable(
          autoFocus: true, // 自动获取焦点
          onTap: _loginPageCtr.loginByCookie,
          child: OutlinedButton.icon(
            onPressed: null, // 使用TvFocusable的onTap
            icon: const Icon(Icons.login),
            label: const Text('登录'),
          ),
        ),
      ],
    );
  }

  Widget loginByPassword() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('使用账号密码登录'),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextField(
            controller: _loginPageCtr.usernameTextController,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.account_box),
              border: const UnderlineInputBorder(),
              labelText: '账号',
              hintText: '邮箱/手机号',
              suffixIcon: TvFocusable(
                onTap: _loginPageCtr.usernameTextController.clear,
                child: IconButton(
                  onPressed: null, // 使用TvFocusable的onTap
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextField(
            obscureText: !showPassword,
            keyboardType: TextInputType.visiblePassword,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
            controller: _loginPageCtr.passwordTextController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.password),
              border: const UnderlineInputBorder(),
              labelText: '密码',
              suffixIcon: TvFocusable(
                onTap: _loginPageCtr.passwordTextController.clear,
                child: IconButton(
                  onPressed: null, // 使用TvFocusable的onTap
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            const SizedBox(width: 10),
            TvFocusable(
              onTap: () {
                feedBack();
                setState(() {
                  showPassword = !showPassword;
                });
              },
              child: Row(
                children: [
                  Checkbox(
                    value: showPassword,
                    onChanged: (value) {
                      setState(() {
                        showPassword = value!;
                      });
                    },
                  ),
                  const Text('显示密码'),
                ],
              ),
            ),
            const Spacer(),
            TvFocusable(
              onTap: () {
                feedBack();
                Utils.launchURL('https://passport.bilibili.com/register/findpassword.html');
              },
              child: TextButton(
                onPressed: null, // 使用TvFocusable的onTap
                child: const Text('忘记密码?'),
              ),
            ),
          ],
        ),
        TvFocusable(
          autoFocus: true, // 自动获取焦点
          onTap: _loginPageCtr.loginByPassword,
          child: OutlinedButton.icon(
            onPressed: null, // 使用TvFocusable的onTap
            icon: const Icon(Icons.login),
            label: const Text('登录'),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
                '根据 bilibili 官方登录接口规范，密码将在本地加盐、加密后传输。\n'
                '盐与公钥均由官方提供；以 RSA/ECB/PKCS1Padding 方式加密。\n'
                '账号密码仅用于该登录接口，不予保存；本地仅存储登录凭证。\n'
                '请务必在 PiliPlus 开源仓库等可信渠道下载安装。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4)))),
      ],
    );
  }

  Widget loginBySmS() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('使用手机短信验证码登录'),
        const SizedBox(height: 10),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: UnderlineTabIndicator(
                borderSide: BorderSide(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    Icons.phone,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  PopupMenuButton<Map<String, dynamic>>(
                    padding: EdgeInsets.zero,
                    tooltip: '选择国际冠码，'
                        '当前为${_loginPageCtr.selectedCountryCodeId['cname']}，'
                        '+${_loginPageCtr.selectedCountryCodeId['country_id']}',
                    //position: PopupMenuPosition.under,
                    onSelected: (Map<String, dynamic> type) {},
                    itemBuilder: (BuildContext context) => Constants
                        .internationalDialingPrefix
                        .map((Map<String, dynamic> item) {
                      return PopupMenuItem<Map<String, dynamic>>(
                        onTap: () {
                          setState(() {
                            _loginPageCtr.selectedCountryCodeId = item;
                          });
                        },
                        value: item,
                        // height: menuItemHeight,
                        child: Row(children: [
                          Text(item['cname']),
                          const Spacer(),
                          Text("+${item['country_id']}")
                        ]),
                      );
                    }).toList(),
                    child: Text(
                        "+${_loginPageCtr.selectedCountryCodeId['country_id']}"),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    height: 24, // 这里设置固定高度
                    child: VerticalDivider(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                      child: TextField(
                    controller: _loginPageCtr.telTextController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: '手机号',
                      suffixIcon: IconButton(
                        onPressed: _loginPageCtr.telTextController.clear,
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  )),
                ],
              ),
            )),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: UnderlineTabIndicator(
                borderSide: BorderSide(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _loginPageCtr.smsCodeTextController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.sms_outlined),
                        border: InputBorder.none,
                        labelText: '验证码',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  Obx(() => TextButton.icon(
                        onPressed: _loginPageCtr.smsSendCooldown > 0
                            ? null
                            : _loginPageCtr.sendSmsCode,
                        icon: const Icon(Icons.send),
                        label: Text(_loginPageCtr.smsSendCooldown > 0
                            ? '等待${_loginPageCtr.smsSendCooldown}秒'
                            : '获取验证码'),
                      )),
                ],
              ),
            )),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: _loginPageCtr.loginBySmsCode,
          icon: const Icon(Icons.login),
          label: const Text('登录'),
        ),
        const SizedBox(height: 20),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
                '手机号仅用于 bilibili 官方发送验证码与登录接口，不予保存；\n'
                '本地仅存储登录凭证。\n'
                '请务必在 PiliPlus 开源仓库等可信渠道下载安装。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4)))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              tooltip: '关闭',
              icon: const Icon(Icons.close_outlined),
              onPressed: Get.back),
          title: Row(children: [
            const Text('登录'),
            if (orientation == Orientation.landscape) ...[
              const Spacer(),
              Flexible(
                  child: TabBar(
                dividerHeight: 0,
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.password), Text(' 密码')],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.sms_outlined), Text(' 短信')],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.qr_code), Text(' 扫码')],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.cookie_outlined), Text(' Cookie')],
                    ),
                  ),
                ],
                controller: _loginPageCtr.tabController,
              ))
            ]
          ]),
          bottom: orientation == Orientation.portrait
              ? TabBar(
                  tabs: const [
                    Tab(icon: Icon(Icons.password), text: '密码'),
                    Tab(icon: Icon(Icons.sms_outlined), text: '短信'),
                    Tab(icon: Icon(Icons.qr_code), text: '扫码'),
                    Tab(icon: Icon(Icons.cookie_outlined), text: 'Cookie'),
                  ],
                  controller: _loginPageCtr.tabController,
                )
              : null,
        ),
        body: NotificationListener(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              if (notification.metrics.axis == Axis.horizontal) {
                FocusScope.of(context).unfocus();
              }
            }
            return true;
          },
          child: tabBarView(
            controller: _loginPageCtr.tabController,
            children: [
              tabViewOuter(loginByPassword()),
              tabViewOuter(loginBySmS()),
              tabViewOuter(loginByQRCode()),
              tabViewOuter(loginByCookie()),
            ],
          ),
        ),
      );
    });
  }

  Widget tabViewOuter(child) {
    return SingleChildScrollView(
        child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 500,
              width: 600,
              child: child,
            )));
  }
}
