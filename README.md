# deepseek-harness Termux 安装补丁

在 Termux 上一键安装并运行 deepseek-harness。

## 使用

git clone https://github.com/kylemingli/deepseek-harness-termux
cd deepseek-harness-termux
bash setup.sh

首次运行自动安装并启动，之后再次运行 bash setup.sh 直接启动。

浏览器访问: http://127.0.0.1:3080

## 目录

- setup.sh — 一键安装启动脚本（首次安装，之后直接启动）
- prebuilt/koffi.node — 预编译 koffi 3.1.1 (android-arm64)
- prebuilt/sharp-android-arm64v8.node — 预编译 sharp 0.32.1
- prebuilt/pty.node — 预编译 node-pty
- patches/sharp-version.patch — sharp 依赖降级补丁（备用）
