"""Run an open-source YOLOv8 road defect model and emit platform events."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
from datetime import datetime, timezone
from pathlib import Path
from urllib import request

from PIL import Image
from ultralytics import YOLO


CLASS_MAP = {
    "d00": ("纵向裂缝", "D00"),
    "longitudinal crack": ("纵向裂缝", "D00"),
    "d10": ("横向裂缝", "D10"),
    "transverse crack": ("横向裂缝", "D10"),
    "d20": ("龟裂", "D20"),
    "alligator crack": ("龟裂", "D20"),
    "d40": ("坑槽", "D40"),
    "pothole": ("坑槽", "D40"),
    "d44": ("修补破损", "D44"),
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--images", type=Path, required=True, help="Frame directory")
    parser.add_argument("--weights", type=Path, required=True, help="YOLOv8 .pt or .onnx")
    parser.add_argument("--sidecar", type=Path, required=True, help="CSV metadata sidecar")
    parser.add_argument("--output", type=Path, default=Path("detections.jsonl"))
    parser.add_argument("--confidence", type=float, default=0.35)
    parser.add_argument("--iou", type=float, default=0.5)
    parser.add_argument("--imgsz", type=int, default=1024)
    parser.add_argument("--upload-url", default="", help="Optional platform ingest endpoint")
    return parser.parse_args()


def load_sidecar(path: Path) -> dict[str, dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        rows = csv.DictReader(handle)
        return {row["filename"]: row for row in rows}


def classify(name: str) -> tuple[str, str] | None:
    normalized = name.strip().lower()
    if normalized in CLASS_MAP:
        return CLASS_MAP[normalized]
    for key, value in CLASS_MAP.items():
        if key in normalized:
            return value
    return None


def severity_for(type_code: str, box_ratio: float) -> str:
    if type_code == "D40":
        return "high" if box_ratio >= 0.003 else "medium"
    if type_code == "D20":
        return "high" if box_ratio >= 0.012 else "medium"
    return "medium" if box_ratio >= 0.004 else "low"


def stable_id(value: str) -> str:
    return hashlib.sha1(value.encode("utf-8")).hexdigest()[:12]


def upload(url: str, detections: list[dict]) -> None:
    payload = json.dumps({"detections": detections}, ensure_ascii=False).encode("utf-8")
    req = request.Request(
        url,
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with request.urlopen(req, timeout=30) as response:
        print(response.read().decode("utf-8"))


def main() -> None:
    args = parse_args()
    metadata = load_sidecar(args.sidecar)
    model = YOLO(str(args.weights))
    detections: list[dict] = []
    frames = sorted(
        path
        for path in args.images.iterdir()
        if path.suffix.lower() in {".jpg", ".jpeg", ".png", ".webp"}
    )
    for frame in frames:
        meta = metadata.get(frame.name)
        if not meta:
            print(f"skip {frame.name}: no sidecar metadata")
            continue
        result = model.predict(
            source=str(frame),
            conf=args.confidence,
            iou=args.iou,
            imgsz=args.imgsz,
            verbose=False,
        )[0]
        with Image.open(frame) as image:
            width, height = image.size
        for index, box in enumerate(result.boxes):
            class_name = result.names[int(box.cls.item())]
            mapped = classify(str(class_name))
            if not mapped:
                continue
            defect_type, type_code = mapped
            x1, y1, x2, y2 = [float(value) for value in box.xyxy[0].tolist()]
            box_ratio = max((x2 - x1) * (y2 - y1), 1) / max(width * height, 1)
            detection_id = stable_id(f"{frame.name}:{index}:{x1:.1f}:{y1:.1f}")
            detections.append(
                {
                    "eventId": detection_id,
                    "type": defect_type,
                    "typeCode": type_code,
                    "severity": severity_for(type_code, box_ratio),
                    "confidence": round(float(box.conf.item()), 4),
                    "bbox": [round(x1, 2), round(y1, 2), round(x2, 2), round(y2, 2)],
                    "imageWidth": width,
                    "imageHeight": height,
                    "roadCode": meta.get("road_code", ""),
                    "roadName": meta.get("road_name", ""),
                    "mileage": meta.get("mileage", ""),
                    "lane": meta.get("lane", ""),
                    "lat": float(meta["lat"]),
                    "lng": float(meta["lng"]),
                    "terminalId": meta.get("terminal_id", "UNKNOWN"),
                    "timestamp": meta.get("timestamp")
                    or datetime.now(timezone.utc).isoformat(),
                    "capture": {
                        "speed": float(meta.get("speed") or 0),
                        "weather": meta.get("weather", "未知"),
                        "source": "YOLOv8 pipeline",
                        "laneConfidence": float(meta.get("lane_confidence") or 0),
                    },
                    "dimensions": {
                        "pixelWidth": round(x2 - x1, 2),
                        "pixelHeight": round(y2 - y1, 2),
                        "boxRatio": round(box_ratio, 6),
                    },
                    "evidenceUri": str(frame),
                }
            )
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", encoding="utf-8") as handle:
        for detection in detections:
            handle.write(json.dumps(detection, ensure_ascii=False) + "\n")
    print(f"wrote {len(detections)} detections to {args.output}")
    if args.upload_url:
        upload(args.upload_url, detections)


if __name__ == "__main__":
    main()
