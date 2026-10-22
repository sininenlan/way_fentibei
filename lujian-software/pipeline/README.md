# 数据与推理流水线

该流水线以开源 Ultralytics YOLOv8 为检测基线，输入车载终端抽帧图像与同名 CSV 元数据，输出平台可直接接收的病害事件。

## 运行

```bash
python -m pip install -r requirements.txt
python infer.py \
  --images ./frames \
  --weights ./models/yolov8s-rdd2022.pt \
  --sidecar ./sidecar.csv \
  --output ./detections.jsonl \
  --upload-url http://127.0.0.1:8787/api/detections/ingest
```

`sidecar.csv` 必须与图像文件同名，并包含道路编号、经纬度、终端编号、时间、速度和天气。示例字段见 `sample_sidecar.csv`。

## 后处理

```bash
python postprocess.py --input ./detections.jsonl --output ./publishable.jsonl
```

后处理按 `typeCode + roadCode + 15m` 规则合并同类病害，保留首次和末次捕获时间、最大置信度与去重后的终端集合。

## 模型基线

- 主基线：YOLOv8s，结合 RDD2022 路面病害数据迁移训练。
- 类别：D00 纵向裂缝、D10 横向裂缝、D20 龟裂、D40 坑槽。
- 代码与权重许可证：AGPL-3.0。商业分发前需完成许可证复核；若不满足要求，切换到 Apache-2.0 的 RTMDet 评估线。
- 本仓库不附带训练权重。将合法获取的权重放入 `models/` 后运行。
