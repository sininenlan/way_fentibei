export const severityMeta = {
  high: { label: "高风险", tone: "danger", rank: 3 },
  medium: { label: "中风险", tone: "warning", rank: 2 },
  low: { label: "低风险", tone: "safe", rank: 1 },
};

export const defectStatusMeta = {
  pending_review: { label: "待复核", tone: "warning" },
  awaiting_dispatch: { label: "待研判", tone: "accent" },
  dispatched: { label: "已派发", tone: "info" },
  in_progress: { label: "处置中", tone: "info" },
  completed: { label: "已完成", tone: "safe" },
  observing: { label: "观察中", tone: "neutral" },
  archived: { label: "已归档", tone: "neutral" },
};

export const orderStatusMeta = {
  assigned: "待接单",
  in_progress: "处置中",
  completed: "已完成",
  cancelled: "已取消",
};

const dateTimeFormatter = new Intl.DateTimeFormat("zh-CN", {
  timeZone: "Asia/Shanghai",
  month: "2-digit",
  day: "2-digit",
  hour: "2-digit",
  minute: "2-digit",
  hour12: false,
});

const timeFormatter = new Intl.DateTimeFormat("zh-CN", {
  timeZone: "Asia/Shanghai",
  hour: "2-digit",
  minute: "2-digit",
  hour12: false,
});

const fullDateFormatter = new Intl.DateTimeFormat("zh-CN", {
  timeZone: "Asia/Shanghai",
  year: "numeric",
  month: "long",
  day: "numeric",
  weekday: "long",
});

export function formatDateTime(value) {
  if (!value) return "--";
  return dateTimeFormatter.format(new Date(value)).replaceAll("/", ".");
}

export function formatTime(value) {
  if (!value) return "--";
  return timeFormatter.format(new Date(value));
}

export function formatFullDate(value = new Date()) {
  return fullDateFormatter.format(new Date(value));
}

export function formatCoordinate(value, axis) {
  if (!Number.isFinite(Number(value))) return "--";
  const suffix = axis === "lat" ? "N" : "E";
  return `${Number(value).toFixed(6)}° ${suffix}`;
}

export function orderForDefect(orders, defectId) {
  return orders
    .filter((order) => order.defectId === defectId && order.status !== "cancelled")
    .sort((a, b) => {
      if (a.status === "completed" && b.status !== "completed") return 1;
      if (b.status === "completed" && a.status !== "completed") return -1;
      return new Date(b.createdAt) - new Date(a.createdAt);
    })[0];
}

export function workerForId(workers, workerId) {
  return workers.find((worker) => worker.id === workerId);
}

export function formatPriority(priority) {
  return { urgent: "紧急", high: "高", medium: "中", low: "低" }[priority] || "中";
}

export function shortRoadName(defect) {
  return defect.roadName?.split("·")[0]?.trim() || defect.roadCode;
}
