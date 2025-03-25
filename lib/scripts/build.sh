#!/bin/bash

set -e  # 遇到错误立即退出
set -x  # 打印执行的每一行命令

# 显示当前目录
echo "当前工作目录: $(pwd)"

# 确保Flutter命令可用
export PATH="$PATH:$FLUTTER_ROOT/bin"

# 安装依赖
echo "安装依赖..."
flutter pub get

# 添加版本信息
echo "添加版本信息..."
if [[ $(uname) == darwin* ]]; then
  build_time=$(date -u -v+8H "+%Y-%m-%d %H:%M:%S")
else
  build_time=$(date -u "+%Y-%m-%d %H:%M:%S" -d "+8 hours")
fi

commit_hash=$(git rev-parse HEAD)

cat > lib/build_config.dart << EOF
// 构建信息，由CI自动生成
class BuildConfig {
  static const String buildTime = "$build_time";
  static const String commitHash = "$commit_hash";
}
EOF

# 构建APK
echo "构建APK..."
flutter build apk --release --target-platform=android-arm --no-tree-shake-icons

# 检查APK是否成功生成
echo "检查APK是否生成成功..."
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK_PATH" ]; then
  echo "APK生成成功: $APK_PATH"
  echo "APK文件大小: $(du -h "$APK_PATH" | cut -f1)"
else
  echo "错误: APK文件未生成在预期路径 $APK_PATH"
  echo "当前目录内容:"
  find build -name "*.apk" -type f
  exit 1
fi
