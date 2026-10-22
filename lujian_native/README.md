# 路鉴智巡原生软件

使用 Dart/Flutter 构建的两个独立原生程序，不包含 HTML 页面或 WebView。

## 程序入口

### 1. 总控台

Windows 可执行程序：

```text
D:\LujianNativeApps\control_console\lujian_control_console.exe
```

源码：

```text
apps/control_console
```

总控台包含：

- 可拖拽旋转的实时三维道路孪生。
- 病害空间实体、风险等级、终端频次和置信度。
- 总览 KPI、优先研判队列和最新病害事件。
- 病害台账检索与风险筛选。
- 工单派发、作业人员选择、优先级和派发说明。
- 数据处理流水线。
- 合作服务：路政按公里订阅、车企云端接口、科研脱敏数据和采集伙伴计划。
- 数据授权与合规：最小必要采集、脱敏、权限分级与地图成果边界。

### 2. 工单 App

Android 安装包：

```text
releases/workorder_app/lujian-workorder-debug.apk
```

Flutter 源码：

```text
apps/workorder_app
```

工单 App 包含：

- 我的工单和附近高风险病害。
- 原生矢量养护地图，支持双指缩放、拖动和点位点击。
- 病害证据、道路编号、桩号、经纬度、终端频次和置信度。
- “开始处置”和“完成处置”状态闭环。
- 任务、地图、我的三个原生页面。

### 3. 共享业务核心

```text
packages/lujian_core
```

两个程序共用同一套 Dart 病害、终端、工单和派发规则。

### 4. Kepler.gl 地图分析

Kepler 地图工作区：

```text
http://localhost:4174
```

源码：

```text
kepler_map
```

地图数据位于 `kepler_map/public/road_defects.geojson`，包含病害点位、道路编号、风险等级、终端捕获频次、模型置信度和状态。总控台顶部提供“Kepler 地图”入口。

## 直接运行

Windows 总控台：

```powershell
.\launch-control.bat
```

Android：

```powershell
.\install-workorder.bat
```

启动 Kepler 地图工作区：

```powershell
.\launch-kepler-map.bat
```

在 Android Studio 中，可使用 Flutter 插件打开 `apps/workorder_app`，选择模拟器后运行。

## 重新构建

当前项目路径含中文，Flutter Windows 的 MSBuild 在中文路径下不稳定。提供的脚本会自动复制到英文路径构建，再把产物复制回来。

```powershell
.\scripts\build-windows.ps1
.\scripts\build-android.ps1
```

## 验证

- `dart analyze`：共享业务核心无问题。
- `flutter analyze`：总控台与工单 App 无问题。
- `flutter test`：两个 App 的组件测试和共享工单规则测试通过。
- Windows Release：已实际启动并截图。
- Android Debug APK：已安装至 Pixel 10 Pro XL 模拟器，任务详情、地图、开始处置和完成处置均验证。
