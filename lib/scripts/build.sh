#!/bin/bash

set -e  # 遇到错误立即退出
set -x  # 打印执行的每一行命令

# 确保Flutter命令可用
export PATH="$PATH:/home/runner/work/_tool/flutter/flutter/bin"

# 显示当前目录
echo "当前工作目录: $(pwd)"

# 安装依赖
echo "安装依赖..."
flutter pub get

# 生成JSON序列化代码
echo "生成JSON序列化代码..."
flutter pub run build_runner build --delete-conflicting-outputs

# 添加版本信息
echo "添加版本信息..."
if [[ "$OSTYPE" == "darwin"* ]]; then
  build_time=$(date -u -v+8H +"%Y-%m-%d %H:%M:%S")
else
  build_time=$(date -u +"%Y-%m-%d %H:%M:%S" -d "+8 hours")
fi

commit_hash=$(git rev-parse HEAD)

cat <<EOL > lib/build_config.dart
class BuildConfig {
  static const bool isDebug = false;
  static const String buildTime = '$build_time';
  static const String commitHash = '$commit_hash';
}
EOL

# 然后构建APK
echo "构建APK..."
flutter build apk --release --target-platform=android-arm

# 检查APK是否构建成功
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
  echo "APK构建成功: build/app/outputs/flutter-apk/app-release.apk"
  ls -la build/app/outputs/flutter-apk/
else
  echo "错误: APK文件未找到!"
  echo "检查构建目录内容:"
  find build -name "*.apk" -type f 2>/dev/null || echo "未找到APK文件"
  exit 1
fi
