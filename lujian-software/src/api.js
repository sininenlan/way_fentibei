async function request(path, options = {}) {
  const response = await fetch(path, {
    headers: {
      "Content-Type": "application/json",
      ...(options.headers || {}),
    },
    ...options,
  });
  const payload = await response.json().catch(() => ({}));
  if (!response.ok) {
    const error = new Error(payload.error || `Request failed: ${response.status}`);
    error.payload = payload;
    throw error;
  }
  return payload;
}

const embeddedStore =
  typeof window !== "undefined" && window.__LUJIAN_LOCAL_STORE__
    ? structuredClone(window.__LUJIAN_LOCAL_STORE__)
    : null;

function localSummary(store) {
  store.summary = {
    ...store.summary,
    pendingDefects: store.defects.filter((defect) =>
      ["pending_review", "awaiting_dispatch"].includes(defect.status),
    ).length,
    highRisk: store.defects.filter(
      (defect) => defect.severity === "high" && defect.status !== "completed",
    ).length,
    openOrders: store.orders.filter(
      (order) => !["completed", "cancelled"].includes(order.status),
    ).length,
    completedOrders: store.orders.filter((order) => order.status === "completed").length,
  };
  return store;
}

function localBootstrap() {
  return structuredClone(localSummary(embeddedStore));
}

function localOrderUpdate(orderId, status, note, evidence = {}) {
  const order = embeddedStore.orders.find((item) => item.id === orderId);
  if (!order) throw new Error("order_not_found");
  if (status === "completed" && !evidence.photo && !order.repairPhoto) {
    throw new Error("请先上传修复照片");
  }
  order.status = status;
  if (evidence.photo) order.repairPhoto = evidence.photo;
  if (evidence.repairNote) order.repairNote = evidence.repairNote;
  if (status === "completed") order.completedAt = new Date().toISOString();
  order.timeline.unshift({
    time: new Date().toISOString(),
    title: status === "in_progress" ? "开始处置" : "处置完成",
    detail:
      status === "completed"
        ? evidence.repairNote || note || "修复照片已归档"
        : note || "Android 客户端状态更新",
  });
  const defect = embeddedStore.defects.find((item) => item.id === order.defectId);
  if (defect) {
    defect.status =
      status === "completed"
        ? "completed"
        : status === "in_progress"
          ? "in_progress"
          : "dispatched";
    defect.timeline.unshift({
      time: new Date().toISOString(),
      title: status === "completed" ? "处置完成" : "工单状态更新",
      detail:
        status === "completed"
          ? evidence.repairNote || note || "修复照片已归档，数字孪生状态已更新"
          : note || "Android 客户端状态更新",
    });
  }
  return { ok: true, order, defect };
}

export const api = {
  bootstrap: () => (embeddedStore ? localBootstrap() : request("/api/bootstrap")),
  reviewDefect: (defectId, decision) => {
    if (embeddedStore) {
      const defect = embeddedStore.defects.find((item) => item.id === defectId);
      if (!defect) throw new Error("defect_not_found");
      defect.status =
        decision === "approve"
          ? "awaiting_dispatch"
          : decision === "observe"
            ? "observing"
            : "archived";
      return Promise.resolve({ ok: true, defect });
    }
    return request(`/api/defects/${defectId}/review`, {
      method: "POST",
      body: JSON.stringify({ decision }),
    });
  },
  dispatchDefect: (defectId, workerId, priority, note) => {
    if (embeddedStore) {
      const defect = embeddedStore.defects.find((item) => item.id === defectId);
      const worker = embeddedStore.workers.find((item) => item.id === workerId);
      if (!defect || !worker) throw new Error("dispatch_invalid");
      const day = new Date().toISOString().slice(0, 10).replaceAll("-", "");
      const order = {
        id: `WO-${day}-${String(embeddedStore.orders.length + 1).padStart(3, "0")}`,
        defectId,
        workerId,
        priority,
        status: "assigned",
        createdAt: new Date().toISOString(),
        dueAt: new Date(Date.now() + 6 * 60 * 60 * 1000).toISOString(),
        note,
        timeline: [
          {
            time: new Date().toISOString(),
            title: "工单创建",
            detail: `派发至${worker.name}`,
          },
        ],
      };
      embeddedStore.orders.unshift(order);
      defect.status = "dispatched";
      return Promise.resolve({ ok: true, order, defect });
    }
    return request(`/api/defects/${defectId}/dispatch`, {
      method: "POST",
      body: JSON.stringify({ workerId, priority, note }),
    });
  },
  updateOrder: (orderId, status, note, evidence = {}) => {
    if (embeddedStore) {
      return Promise.resolve(localOrderUpdate(orderId, status, note, evidence));
    }
    return request(`/api/orders/${orderId}/status`, {
      method: "POST",
      body: JSON.stringify({
        status,
        note,
        repairPhoto: evidence.photo || "",
        repairNote: evidence.repairNote || "",
      }),
    });
  },
  runPipeline: (batchSize = 120) => {
    if (embeddedStore) {
      embeddedStore.pipeline.lastRun = new Date().toISOString();
      embeddedStore.pipeline.counters.ingested += batchSize;
      embeddedStore.pipeline.counters.qualified += Math.round(batchSize * 0.947);
      return Promise.resolve({ ok: true, pageEmbedded: true });
    }
    return request("/api/pipeline/run", {
      method: "POST",
      body: JSON.stringify({ batchSize }),
    });
  },
  ingestDetections: (detections) => {
    if (embeddedStore) {
      return Promise.resolve({
        ok: true,
        accepted: detections.length,
        merged: 0,
        created: 0,
      });
    }
    return request("/api/detections/ingest", {
      method: "POST",
      body: JSON.stringify({ detections }),
    });
  },
};
