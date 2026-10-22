"""Merge nearby road-defect events before publishing them to the platform."""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--output", type=Path, default=Path("publishable.jsonl"))
    parser.add_argument("--distance", type=float, default=15.0)
    return parser.parse_args()


def haversine_meters(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    radius = 6371000
    d_lat = math.radians(lat2 - lat1)
    d_lng = math.radians(lng2 - lng1)
    a = (
        math.sin(d_lat / 2) ** 2
        + math.cos(math.radians(lat1))
        * math.cos(math.radians(lat2))
        * math.sin(d_lng / 2) ** 2
    )
    return 2 * radius * math.atan2(math.sqrt(a), math.sqrt(1 - a))


def main() -> None:
    args = parse_args()
    events = [
        json.loads(line)
        for line in args.input.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    merged: list[dict] = []
    for event in events:
        target = next(
            (
                item
                for item in merged
                if item["typeCode"] == event["typeCode"]
                and item["roadCode"] == event["roadCode"]
                and haversine_meters(
                    item["lat"], item["lng"], event["lat"], event["lng"]
                )
                <= args.distance
            ),
            None,
        )
        if target is None:
            event["terminalIds"] = [event["terminalId"]]
            event["terminalCount"] = 1
            event["evidenceUris"] = [event.pop("evidenceUri", "")]
            merged.append(event)
            continue
        terminals = set(target["terminalIds"])
        terminals.add(event["terminalId"])
        target["terminalIds"] = sorted(terminals)
        target["terminalCount"] = len(terminals)
        target["confidence"] = max(target["confidence"], event["confidence"])
        target["lastSeen"] = event["timestamp"]
        target["evidenceUris"].append(event.pop("evidenceUri", ""))

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", encoding="utf-8") as handle:
        for item in merged:
            handle.write(json.dumps(item, ensure_ascii=False) + "\n")
    print(f"merged {len(events)} events into {len(merged)} defects")


if __name__ == "__main__":
    main()
