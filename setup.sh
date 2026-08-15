#!/bin/bash
set -e

SCRIPT_DIR="\$(cd "\$(dirname "\$0")" && pwd)"
WORK_DIR="\$HOME/git"

echo "==> [1/7] 安装 Termux 依赖"
pkg update && pkg upgrade
pkg install -y nodejs-lts python clang cmake make binutils git libvips libvips-dev

echo "==> [2/7] 克隆官方 deepseek-harness"
if [ ! -d "\$WORK_DIR/deepseek-harness" ]; then
  git clone https://github.com/deepseek-ai/deepseek-harness "\$WORK_DIR/deepseek-harness"
fi
cd "\$WORK_DIR/deepseek-harness"

echo "==> [3/7] 应用 sharp 版本降级补丁"
git apply "\$SCRIPT_DIR/patches/sharp-version.patch"

echo "==> [4/7] 安装依赖（跳过编译脚本）"
pnpm install --no-frozen-lockfile --ignore-scripts

echo "==> [5/7] 复制预编译二进制"
KOFFI_DIR="node_modules/.pnpm/koffi@3.1.1/node_modules/koffi"
mkdir -p "\$KOFFI_DIR/build/koffi/android_arm64"
cp "\$SCRIPT_DIR/prebuilt/koffi.node" "\$KOFFI_DIR/build/koffi/android_arm64/koffi.node"

SHARP_DIR="node_modules/.pnpm/sharp@0.32.1/node_modules/sharp"
mkdir -p "\$SHARP_DIR/build/Release"
cp "\$SCRIPT_DIR/prebuilt/sharp-android-arm64v8.node" "\$SHARP_DIR/build/Release/sharp-android-arm64v8.node"

echo "==> [6/7] 创建符号链接 + 构建前端"
mkdir -p node_modules/@deepseek-ai
ln -sf ../../packages/client/ui-directory-picker-browse node_modules/@deepseek-ai/dsh-client-ui-directory-picker-browse
pnpm run build

echo "==> [7/7] 启动"
cd "\$WORK_DIR/deepseek-harness"
node --expose-internals --import tsx/esm apps/cli/src/bin.ts web
