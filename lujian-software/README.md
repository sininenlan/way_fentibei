# 路鉴智巡软件

低成本众包式路面病害识别平台，包含后装采集终端、工人作业客户端、道路数字孪生管理后台和合作方数据服务。系统使用 Leaflet + OpenStreetMap 作为开源地图底座，使用 YOLOv8 + RDD2022 作为检测基线，并包含一套可执行的 Python 推理与后处理流水线。

## 启动

```bash
cd lujian-software
npm install
npm run dev
```

打开 `http://localhost:8787`。

生产构建：

```bash
npm run build
npm start
```

打开 `http://localhost:8787`。`npm run dev` 会先构建前端，再由 Express 同时提供 API 和 `dist` 静态文件。

## 功能

- 工人端：任务列表、OSM 病害地图、道路编号、桩号、经纬度、多终端频次、研判建议、导航和处置回传。
- 数字孪生后台：路段空间总览、Three.js 道路孪生、病害台账、派发研判、工单状态、终端状态和模型管理。
- 采集终端：低成本后装终端、公务车/网约车/物流车/养护车采集来源、终端在线状态与 90 天试点准备。
- 合作服务：路政按公里订阅、车企云端识别接口、科研脱敏数据和采集伙伴计划；包含数据授权与合规说明。
- 数据处理：JSON 事件接入、15 米同类病害聚合、终端去重、派发评分、演示批次运行。
- 工单闭环：工人开始处置后必须回传修复照片，照片压缩后随工单归档并更新数字孪生状态。
- 模型基线：YOLOv8s + RDD2022，目标类别 D00、D10、D20、D40；RTMDet 作为 Apache-2.0 备选线。

## 演示入口

- 工人作业：`http://localhost:8787/`
- 数字孪生：`http://localhost:8787/?role=admin`
- 采集终端：`http://localhost:8787/?role=admin&section=terminals`
- 合作服务：`http://localhost:8787/?role=admin&section=services`

合作接口演示密钥为 `demo-partner-key`：

```text
POST /api/v1/detections
GET  /api/v1/road-defects?roadCode=G312
```

## 目录

```text
server/       Express API 与持久化演示数据
src/          React 工人端和数字孪生后台
pipeline/     YOLOv8 推理、聚合与上传脚本
docs/         软件架构与数据契约
public/       界面使用的证据图像
```

数据流水线说明见 `pipeline/README.md`，软件架构见 `docs/architecture.md`。

工人端 Android Studio 工程位于 `../lujian-worker-android`，构建时会把同一套界面与演示数据同步到 WebView 工程，可直接运行到模拟器或 Android 手机。

## 说明

- 页面使用本地演示数据，不代表第三方测试结果或生产部署指标。
- 路政、车企和科研合作均按“试点筹备 / 方案就绪 / 授权模板”展示，不将未签约意向计为已签署合同。
- OSM 瓦片仅在浏览器中按需加载；网络不可用时自动显示本地道路示意底图。
- YOLOv8 代码与权重的 AGPL-3.0 许可证需要在商业分发前复核。
- 演示系统把压缩后的修复照片写入本地 JSON；生产环境需要接入身份认证、权限、对象存储、PostGIS、审计和生产模型权重。
