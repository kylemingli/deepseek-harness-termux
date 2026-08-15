#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="$HOME/git"
PROJECT_DIR="$WORK_DIR/deepseek-harness"
MARKER_FILE="$PROJECT_DIR/.termux-setup-done"

# 如果已经安装过，直接启动
if [ -f "$MARKER_FILE" ]; then
  echo "==> 检测到已安装，直接启动"
  cd "$PROJECT_DIR"
  node --expose-internals --import tsx/esm apps/cli/src/bin.ts web
  exit 0
fi

echo "==> [1/8] 安装 Termux 依赖"
pkg update && pkg upgrade
pkg install -y nodejs-lts python clang cmake make binutils git libvips

echo "==> [2/8] 克隆官方 deepseek-harness"
if [ ! -d "$PROJECT_DIR" ]; then
  git clone https://github.com/deepseek-ai/deepseek-harness "$PROJECT_DIR"
fi
cd "$PROJECT_DIR"

echo "==> [3/8] 应用 sharp 版本降级"
sed -i 's/"sharp": "^0.35.3"/"sharp": "0.32.1"/' packages/attachment/attachment-local/package.json

echo "==> [4/8] 修复 image.ts 类型错误"
sed -i 's/return { mediaType, width: metadata.width, height: metadata.height }/return { mediaType, width: metadata.width ?? 0, height: metadata.height ?? 0 }/' packages/attachment/attachment-local/src/image.ts

echo "==> [5/8] 安装依赖（跳过编译脚本）"
pnpm install --no-frozen-lockfile --ignore-scripts

echo "==> [6/8] 复制预编译二进制 + 创建链接"
KOFFI_DIR="node_modules/.pnpm/koffi@3.1.1/node_modules/koffi"
mkdir -p "$KOFFI_DIR/build/koffi/android_arm64"
cp "$SCRIPT_DIR/prebuilt/koffi.node" "$KOFFI_DIR/build/koffi/android_arm64/koffi.node"
ln -sf .pnpm/koffi@3.1.1/node_modules/koffi node_modules/koffi

SHARP_DIR="node_modules/.pnpm/sharp@0.32.1/node_modules/sharp"
mkdir -p "$SHARP_DIR/build/Release"
cp "$SCRIPT_DIR/prebuilt/sharp-android-arm64v8.node" "$SHARP_DIR/build/Release/sharp-android-arm64v8.node"
ln -sf .pnpm/sharp@0.32.1/node_modules/sharp node_modules/sharp

PTY_DIR="node_modules/.pnpm/node-pty@1.1.0/node_modules/node-pty"
mkdir -p "$PTY_DIR/build/Release"
cp "$SCRIPT_DIR/prebuilt/pty.node" "$PTY_DIR/build/Release/pty.node"

mkdir -p node_modules/@deepseek-ai
ln -sf ../../packages/client/ui-directory-picker-browse node_modules/@deepseek-ai/dsh-client-ui-directory-picker-browse

echo "==> [7/8] 构建前端"
NODE_OPTIONS="--max-old-space-size=4096" pnpm run build

# 标记安装完成
touch "$MARKER_FILE"

echo "==> [8/8] 启动"
node --expose-internals --import tsx/esm apps/cli/src/bin.ts web
