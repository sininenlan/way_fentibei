# 路鉴智巡工人端 Android 工程

这是一个可直接用 Android Studio 打开并运行的工人作业 App。应用内置工人端前端资源和演示数据，不依赖本地网页服务器。

## Android Studio

1. 用 Android Studio 打开目录 `lujian-worker-android`。
2. Gradle JDK 选择 JDK 17。
3. 等待 Gradle Sync 完成。
4. 选择 `Pixel_10_Pro_XL` 模拟器或 Android 手机。
5. 运行 `app`。

## 命令行构建

```powershell
cd D:\aaa工作\竞赛\粉体杯261020\lujian-worker-android
C:\Users\青钰蓝\.gradle\wrapper\dists\gradle-8.11.1-all\2qik7nd48slq1ooc2496ixf4i\gradle-8.11.1\bin\gradle.bat assembleDebug
```

APK 输出位置：

```text
app/build/outputs/apk/debug/app-debug.apk
```

## 资源更新

Android 内的工人端资源来自 `lujian-software`。修改前端后，在 `lujian-software` 目录执行：

```powershell
npm run build
```

构建脚本会把最新资源同步到 `app/src/main/assets/worker`。

## 说明

- 应用内置演示数据，可离线查看任务、地图、病害详情并完成处置状态演示。
- OpenStreetMap 在线瓦片不可用时，自动显示本地道路示意底图。
- 生产部署时可把 WebView 入口替换为 HTTPS 服务地址，并接入登录、权限、对象存储和真实工单接口。
