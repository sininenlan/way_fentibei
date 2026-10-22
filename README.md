# 路鉴智巡（way_fentibei）

本仓库包含三套可独立运行的软件：

1. `lujian-software`：Web 综合平台，包含工人端、数字孪生后台、采集终端与合作服务。
2. `lujian_native`：Flutter 原生套件，包含 Windows 总控台、原生工单 App、共享业务核心和 Kepler 地图工作区。
3. `lujian-worker-android`：Android WebView 工人端，可直接用 Android Studio 构建运行。

## 1. Web 综合平台

环境要求：Node.js 20+。

```powershell
cd lujian-software
npm ci
npm run dev
```

浏览器打开 `http://localhost:8787`。

- 工人端：`http://localhost:8787/`
- 数字孪生后台：`http://localhost:8787/?role=admin`
- 采集终端：`http://localhost:8787/?role=admin&section=terminals`
- 合作服务：`http://localhost:8787/?role=admin&section=services`

生产运行：

```powershell
npm run build
npm start
```

## 2. Flutter 原生套件

环境要求：Flutter 3.41+、Windows 桌面构建工具、Android SDK/JDK 17。

### Windows 总控台

仓库内已有发布包时，直接运行：

```powershell
.\lujian_native\launch-control.bat
```

从源码运行：

```powershell
cd lujian_native\apps\control_console
flutter pub get
flutter run -d windows
```

重新构建 Windows 发布包：

```powershell
.\lujian_native\scripts\build-windows.ps1
```

### 原生工单 App

先启动 Android 模拟器或用 USB 连接手机，然后运行：

```powershell
.\lujian_native\scripts\build-android.ps1
.\lujian_native\install-workorder.bat
```

原生 APK 约 138 MB，超过 GitHub 普通仓库单文件限制，因此不纳入 Git；构建脚本会生成 `lujian_native\releases\workorder_app\lujian-workorder-debug.apk`。

从源码运行：

```powershell
cd lujian_native\apps\workorder_app
flutter pub get
flutter run
```

### Kepler 地图

```powershell
cd lujian_native\kepler_map
npm ci
npm run dev
```

浏览器打开 `http://localhost:4174`，也可以运行 `.\lujian_native\launch-kepler-map.bat`。

## 3. Android WebView 工人端

资源已内置，不依赖本地网页服务器。用 Android Studio 打开 `lujian-worker-android`，选择 JDK 17 和模拟器/手机，运行 `app`。

命令行构建：

```powershell
cd lujian-worker-android
.\gradlew.bat assembleDebug
```

APK 输出到 `lujian-worker-android\app\build\outputs\apk\debug\app-debug.apk`。修改 Web 工人端后，在 `lujian-software` 中执行 `npm run build`，会把前端资源同步到该 Android 工程。

## 说明

仓库只提交源码、依赖锁定文件、启动脚本和必要的 Windows 发布目录。`node_modules`、Gradle 缓存、构建中间产物、编辑器配置及超过 GitHub 单文件限制的 APK 均由 `.gitignore` 排除。
