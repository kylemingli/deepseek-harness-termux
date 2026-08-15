# deepseek-harness Termux 安装补丁

在 Termux 上一键安装并运行 deepseek-harness。

## 使用

git clone <此仓库地址>
cd deepseek-harness-termux
bash setup.sh

浏览器访问: http://127.0.0.1:3080

## 目录

- setup.sh — 一键安装启动脚本
- prebuilt/koffi.node — 预编译 koffi 3.1.1 (android-arm64)
- prebuilt/sharp-android-arm64v8.node — 预编译 sharp 0.32.1
- patches/sharp-version.patch — sharp 依赖降级补丁
