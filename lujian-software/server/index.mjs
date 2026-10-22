import express from "express";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const STORE_PATH = process.env.LUJIAN_STORE_PATH
  ? path.resolve(process.env.LUJIAN_STORE_PATH)
  : path.join(__dirname, "data", "store.json");
const DIST_PATH = path.join(ROOT, "dist");
const PORT = Number(process.env.PORT || 8787);
const app = express();

app.use(express.json({ limit: "8mb" }));

function readStore() {
  return JSON.parse(fs.readFileSync(STORE_PATH, "utf8"));
}

function writeStore(store) {
  fs.writeFileSync(STORE_PATH, `${JSON.stringify(store, null, 2)}\n`, "utf8");
}

function timestamp() {
  return new Date().toISOString();
}

function haversineMeters(lat1, lng1, lat2, lng2) {
  const radius = 6371000;
  const toRadians = (value) => (value * Math.PI) / 180;
  const dLat = toRadians(lat2 - lat1);
  const dLng = toRadians(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRadians(lat1)) *
      Math.cos(toRadians(lat2)) *
      Math.sin(dLng / 2) ** 2;
  return 2 * radius * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function severityValue(severity) {
  return { urgent: 1, high: 1, medium: 0.65, low: 0.25 }[severity] || 0.4;
}

function recommendationFor(defect) {
  const frequency = Math.min((defect.terminalCount || 1) / 7, 1);
  const score = Math.round(38 + severityValue(defect.severity) * 36 + frequency * 18);
  if (defect.severity === "high" || defect.terminalCount >= 4) {
    return {
      score,
      action: "dispatch",
      reason: `多终端重复捕获且属于${defect.severityLabel || "较高风险"}，建议优先派发。`,
    };
  }
  if (defect.confidence < 0.8 || defect.terminalCount < 2) {
    return {
      score,
      action: "review",
      reason: "证据数量或识别置信度有限，建议先复核近景图像。",
    };
  }
  return {
    score,
    action: "observe",
    reason: "病害风险仍在可控范围，建议纳入本周巡查观察。",
  };
}

function summaryFor(store) {
  const openOrders = store.orders.filter(
    (order) => !["completed", "cancelled"].includes(order.status),
  );
  const pendingDefects = store.defects.filter((defect) =>
    ["pending_review", "awaiting_dispatch"].includes(defect.status),
  );
  const highRisk = store.defects.filter(
    (defect) => defect.severity === "high" && defect.status !== "completed",
  );
  const onlineTerminals = store.terminals.filter(
    (terminal) => terminal.status === "online",
  );
  const averageConfidence =
    store.defects.reduce((total, defect) => total + defect.confidence, 0) /
    Math.max(store.defects.length, 1);
  return {
    monitoredKm: 126.4,
    activeTerminals: onlineTerminals.length,
    totalTerminals: store.terminals.length,
    pendingDefects: pendingDefects.length,
    highRisk: highRisk.length,
    openOrders: openOrders.length,
    completedOrders: store.orders.filter((order) => order.status === "completed").length,
    averageConfidence: Number(averageConfidence.toFixed(3)),
    latestCapture: store.defects
      .map((defect) => defect.lastSeen)
      .sort()
      .at(-1),
  };
}

app.get("/api/health", (_request, response) => {
  response.json({ ok: true, service: "lujian-zhixun-api", now: timestamp() });
});

app.get("/api/bootstrap", (_request, response) => {
  const store = readStore();
  response.json({
    ...store,
    summary: summaryFor(store),
  });
});

app.get("/api/defects", (request, response) => {
  const store = readStore();
  const query = String(request.query.q || "").trim().toLowerCase();
  const status = String(request.query.status || "");
  const defects = store.defects.filter((defect) => {
    const matchesStatus = !status || defect.status === status;
    const matchesQuery =
      !query ||
      [defect.id, defect.type, defect.roadCode, defect.roadName]
        .join(" ")
        .toLowerCase()
        .includes(query);
    return matchesStatus && matchesQuery;
  });
  response.json(defects);
});

app.post("/api/defects/:id/review", (request, response) => {
  const store = readStore();
  const defect = store.defects.find((item) => item.id === request.params.id);
  if (!defect) {
    return response.status(404).json({ error: "defect_not_found" });
  }
  const decision = request.body?.decision;
  if (decision === "approve") {
    defect.status = "awaiting_dispatch";
    defect.timeline.unshift({
      time: timestamp(),
      title: "人工复核通过",
      detail: "病害证据确认，进入派发研判。",
    });
  } else if (decision === "observe") {
    defect.status = "observing";
    defect.timeline.unshift({
      time: timestamp(),
      title: "转为观察",
      detail: "暂不派发，纳入后续巡查周期。",
    });
  } else if (decision === "reject") {
    defect.status = "archived";
    defect.timeline.unshift({
      time: timestamp(),
      title: "复核排除",
      detail: "经人工复核不认定为有效病害。",
    });
  } else {
    return response.status(400).json({ error: "invalid_decision" });
  }
  writeStore(store);
  return response.json({ ok: true, defect });
});

app.post("/api/defects/:id/dispatch", (request, response) => {
  const store = readStore();
  const defect = store.defects.find((item) => item.id === request.params.id);
  if (!defect) {
    return response.status(404).json({ error: "defect_not_found" });
  }
  const { workerId, priority = "medium", note = "" } = request.body || {};
  const worker = store.workers.find((item) => item.id === workerId);
  if (!worker) {
    return response.status(400).json({ error: "worker_required" });
  }
  const existing = store.orders.find(
    (order) =>
      order.defectId === defect.id &&
      !["completed", "cancelled"].includes(order.status),
  );
  if (existing) {
    return response.status(409).json({ error: "open_order_exists", order: existing });
  }
  const sequence = String(store.orders.length + 19).padStart(3, "0");
  const day = new Date().toISOString().slice(0, 10).replaceAll("-", "");
  const order = {
    id: `WO-${day}-${sequence}`,
    defectId: defect.id,
    workerId,
    priority,
    status: "assigned",
    createdAt: timestamp(),
    dueAt: new Date(Date.now() + 6 * 60 * 60 * 1000).toISOString(),
    note,
    timeline: [
      {
        time: timestamp(),
        title: "工单创建",
        detail: `派发至${worker.name}，优先级${priority}`,
      },
    ],
  };
  store.orders.unshift(order);
  defect.status = "dispatched";
  defect.timeline.unshift({
    time: timestamp(),
    title: "工单派发",
    detail: `派发至${worker.name}，工单号${order.id}`,
  });
  writeStore(store);
  return response.status(201).json({ ok: true, order, defect });
});

app.post("/api/orders/:id/status", (request, response) => {
  const store = readStore();
  const order = store.orders.find((item) => item.id === request.params.id);
  if (!order) {
    return response.status(404).json({ error: "order_not_found" });
  }
  const {
    status,
    note = "",
    repairPhoto = "",
    repairNote = "",
  } = request.body || {};
  if (!["assigned", "in_progress", "completed", "cancelled"].includes(status)) {
    return response.status(400).json({ error: "invalid_status" });
  }
  const hasRepairPhoto =
    typeof repairPhoto === "string" && repairPhoto.startsWith("data:image/");
  if (status === "completed" && !hasRepairPhoto && !order.repairPhoto) {
    return response.status(400).json({ error: "repair_photo_required" });
  }
  order.status = status;
  if (hasRepairPhoto) order.repairPhoto = repairPhoto;
  if (repairNote) order.repairNote = repairNote;
  if (status === "completed") {
    order.completedAt = timestamp();
  }
  order.timeline.unshift({
    time: timestamp(),
    title:
      status === "in_progress"
        ? "开始处置"
        : status === "completed"
          ? "处置完成"
          : "工单状态更新",
    detail:
      status === "completed"
        ? repairNote || note || "已回传修复照片并归档"
        : note || `工单状态更新为${status}`,
  });
  const defect = store.defects.find((item) => item.id === order.defectId);
  if (defect) {
    defect.status =
      status === "completed"
        ? "completed"
        : status === "in_progress"
          ? "in_progress"
          : "dispatched";
    defect.timeline.unshift({
      time: timestamp(),
      title: status === "completed" ? "处置完成" : "工单状态更新",
      detail:
        status === "completed"
          ? repairNote || note || "修复照片已归档，数字孪生状态已更新"
          : note || `工单${order.id}状态更新`,
    });
  }
  writeStore(store);
  return response.json({ ok: true, order, defect });
});

app.post("/api/pipeline/run", (request, response) => {
  const store = readStore();
  const batchSize = Number(request.body?.batchSize || 120);
  const accepted = Math.max(1, Math.round(batchSize * 0.947));
  const detections = Math.max(1, Math.round(accepted * 0.055));
  const merged = Math.max(1, Math.round(detections * 0.64));
  store.pipeline.status = "idle";
  store.pipeline.lastRun = timestamp();
  store.pipeline.counters.ingested += batchSize;
  store.pipeline.counters.qualified += accepted;
  store.pipeline.counters.detected += detections;
  store.pipeline.counters.merged += merged;
  store.pipeline.counters.pendingReview += Math.max(1, Math.round(detections * 0.18));
  store.pipeline.counters.published += Math.max(1, detections - Math.round(detections * 0.18));
  writeStore(store);
  response.json({
    ok: true,
    batch: { batchSize, accepted, detections, merged },
    pipeline: store.pipeline,
  });
});

function ingestDetections(request, response) {
  const store = readStore();
  const detections = Array.isArray(request.body) ? request.body : request.body?.detections;
  if (!Array.isArray(detections)) {
    return response.status(400).json({ error: "detections_array_required" });
  }
  let mergedCount = 0;
  let createdCount = 0;
  for (const detection of detections) {
    const lat = Number(detection.lat);
    const lng = Number(detection.lng);
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) continue;
    const type = detection.type || "坑槽";
    const typeCode = detection.typeCode || "D40";
    const terminalId = detection.terminalId || "API-INGEST";
    const existing = store.defects.find(
      (defect) =>
        defect.typeCode === typeCode &&
        haversineMeters(lat, lng, defect.lat, defect.lng) <= 15,
    );
    if (existing) {
      const terminalIds = new Set([...(existing.terminalIds || []), terminalId]);
      existing.terminalIds = [...terminalIds];
      existing.terminalCount = terminalIds.size;
      existing.confidence = Math.max(existing.confidence, Number(detection.confidence || 0));
      existing.lastSeen = detection.timestamp || timestamp();
      existing.timeline.unshift({
        time: timestamp(),
        title: "新终端命中",
        detail: `${terminalId} 在15米范围内捕获同类病害，已自动合并。`,
      });
      mergedCount += 1;
    } else {
      const severity = detection.severity || "low";
      const defect = {
        id: `DEF-${Date.now()}-${createdCount + 1}`,
        type,
        typeCode,
        severity,
        severityLabel:
          severity === "high" ? "高风险" : severity === "medium" ? "中风险" : "低风险",
        roadCode: detection.roadCode || "UNASSIGNED",
        roadName: detection.roadName || "待匹配路段",
        lat,
        lng,
        mileage: detection.mileage || "",
        lane: detection.lane || "待确认",
        terminalCount: 1,
        terminalIds: [terminalId],
        confidence: Number(detection.confidence || 0.5),
        firstSeen: detection.timestamp || timestamp(),
        lastSeen: detection.timestamp || timestamp(),
        status: "pending_review",
        dimensions: detection.dimensions || {
          lengthCm: 0,
          widthCm: 0,
          areaM2: 0,
        },
        capture: detection.capture || {
          speed: 0,
          weather: "未知",
          source: "API导入",
          laneConfidence: 0,
        },
        timeline: [
          {
            time: timestamp(),
            title: "数据接入",
            detail: `${terminalId} 上传检测结果，等待聚合与复核。`,
          },
        ],
      };
      defect.recommendation = recommendationFor(defect);
      store.defects.unshift(defect);
      createdCount += 1;
    }
  }
  store.pipeline.lastRun = timestamp();
  store.pipeline.counters.ingested += detections.length;
  store.pipeline.counters.qualified += detections.length;
  store.pipeline.counters.pendingReview += createdCount;
  writeStore(store);
  response.status(201).json({
    ok: true,
    accepted: detections.length,
    merged: mergedCount,
    created: createdCount,
  });
}

app.post("/api/detections/ingest", ingestDetections);

function partnerAuthorized(request) {
  return request.get("x-api-key") === "demo-partner-key";
}

app.get("/api/v1/road-defects", (request, response) => {
  if (!partnerAuthorized(request)) {
    return response.status(401).json({ error: "partner_api_key_required" });
  }
  const store = readStore();
  const roadCode = String(request.query.roadCode || "").trim().toUpperCase();
  const defects = store.defects
    .filter((defect) => !roadCode || defect.roadCode.toUpperCase().includes(roadCode))
    .map((defect) => ({
      defectId: defect.id,
      roadCode: defect.roadCode,
      typeCode: defect.typeCode,
      severity: defect.severity,
      status: defect.status,
      confidence: defect.confidence,
      terminalCount: defect.terminalCount,
      coordinates: [defect.lng, defect.lat],
      mileage: defect.mileage,
      firstSeen: defect.firstSeen,
      lastSeen: defect.lastSeen,
    }));
  response.json({
    apiVersion: "v1",
    scope: "road-defect-read",
    generatedAt: timestamp(),
    count: defects.length,
    data: defects,
  });
});

app.post("/api/v1/detections", (request, response) => {
  if (!partnerAuthorized(request)) {
    return response.status(401).json({ error: "partner_api_key_required" });
  }
  ingestDetections(request, response);
});

if (fs.existsSync(DIST_PATH)) {
  app.use(express.static(DIST_PATH));
  app.get("*", (_request, response) => {
    response.sendFile(path.join(DIST_PATH, "index.html"));
  });
}

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Lujian API listening on http://127.0.0.1:${PORT}`);
});
