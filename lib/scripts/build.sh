#!/bin/bash

# 确保Flutter命令可用
export PATH="$PATH:/home/runner/work/_tool/flutter/flutter/bin"

# 安装依赖
echo "安装依赖..."
flutter pub get

# 生成JSON序列化代码
echo "生成JSON序列化代码..."
flutter pub run build_runner build --delete-conflicting-outputs

# 然后构建APK
echo "构建APK..."
flutter build apk --release --target-platform=android-arm

# 生成构建信息
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
