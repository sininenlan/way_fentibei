import { useMemo, useState } from "react";
import {
  AlertTriangle,
  Camera,
  CheckCircle2,
  ChevronRight,
  Clock3,
  Crosshair,
  ImagePlus,
  Layers3,
  ListFilter,
  LocateFixed,
  MapPin,
  Navigation,
  Radio,
  Search,
  ShieldCheck,
  UploadCloud,
} from "lucide-react";
import MapView from "./MapView";
import { api } from "../api";
import {
  defectStatusMeta,
  formatCoordinate,
  formatDateTime,
  formatPriority,
  formatTime,
  orderForDefect,
  orderStatusMeta,
  severityMeta,
} from "../lib/format";

function WorkerOrderCard({ defect, order, active, onClick }) {
  const severity = severityMeta[defect.severity] || severityMeta.low;
  return (
    <button
      type="button"
      className={`worker-order-card ${active ? "active" : ""}`}
      onClick={onClick}
    >
      <span className={`severity-rail ${severity.tone}`} />
      <span className="worker-order-top">
        <span className={`severity-label ${severity.tone}`}>{severity.label}</span>
        <span className="order-due">
          <Clock3 size={13} />
          {order ? orderStatusMeta[order.status] : defectStatusMeta[defect.status]?.label}
        </span>
      </span>
      <strong>{defect.type}</strong>
      <span className="worker-order-road">{defect.roadName}</span>
      <span className="worker-order-meta">
        <span>{defect.roadCode}</span>
        <span><Radio size={12} /> {defect.terminalCount}</span>
      </span>
      <ChevronRight size={17} className="worker-order-arrow" />
    </button>
  );
}

function EvidencePanel({ defect }) {
  return (
    <div className="evidence-frame">
      <img src="cover-evidence.png" alt={`${defect.type}现场识别图像`} />
      <span className="detection-box" />
      <span className="detection-tag">
        {defect.typeCode} · {Math.round(defect.confidence * 100)}%
      </span>
      <span className="evidence-index">证据 01 / 03</span>
    </div>
  );
}

function compressRepairPhoto(file) {
  if (!file?.type?.startsWith("image/")) {
    return Promise.reject(new Error("请选择图片文件"));
  }
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onerror = () => reject(new Error("图片读取失败"));
    reader.onload = () => {
      const image = new window.Image();
      image.onerror = () => reject(new Error("图片解析失败"));
      image.onload = () => {
        const scale = Math.min(1, 1280 / Math.max(image.width, image.height));
        const canvas = document.createElement("canvas");
        canvas.width = Math.max(1, Math.round(image.width * scale));
        canvas.height = Math.max(1, Math.round(image.height * scale));
        const context = canvas.getContext("2d");
        context.drawImage(image, 0, 0, canvas.width, canvas.height);
        resolve(canvas.toDataURL("image/jpeg", 0.72));
      };
      image.src = reader.result;
    };
    reader.readAsDataURL(file);
  });
}

function WorkerDetail({
  defect,
  order,
  terminalCapacity,
  onRefresh,
  showToast,
  refreshing,
  setRefreshing,
}) {
  const severity = severityMeta[defect.severity] || severityMeta.low;
  const status = defectStatusMeta[defect.status] || defectStatusMeta.pending_review;
  const [repairPhoto, setRepairPhoto] = useState(order?.repairPhoto || "");
  const [repairNote, setRepairNote] = useState(order?.repairNote || "");
  const [uploading, setUploading] = useState(false);

  const updateStatus = async (statusValue) => {
    if (!order || refreshing) return;
    if (statusValue === "completed" && !repairPhoto) {
      showToast("请先上传修复照片", "error");
      return;
    }
    setRefreshing(true);
    try {
      const note =
        statusValue === "in_progress"
          ? "工人端确认到场，开始现场处置。"
          : repairNote || "处置完成，已记录修复照片与现场说明。";
      await api.updateOrder(order.id, statusValue, note, {
        photo: statusValue === "completed" ? repairPhoto : "",
        repairNote,
      });
      showToast(statusValue === "completed" ? "工单已完成并同步至数字孪生" : "已开始处置");
      await onRefresh();
    } catch (error) {
      showToast(error.message, "error");
    } finally {
      setRefreshing(false);
    }
  };

  const selectRepairPhoto = async (event) => {
    const [file] = event.target.files || [];
    event.target.value = "";
    if (!file) return;
    setUploading(true);
    try {
      const photo = await compressRepairPhoto(file);
      setRepairPhoto(photo);
      showToast("修复照片已添加，可随工单归档");
    } catch (error) {
      showToast(error.message, "error");
    } finally {
      setUploading(false);
    }
  };

  const openInOsm = () => {
    window.open(
      `https://www.openstreetmap.org/?mlat=${defect.lat}&mlon=${defect.lng}#map=18/${defect.lat}/${defect.lng}`,
      "_blank",
      "noopener,noreferrer",
    );
  };

  return (
    <div className="worker-detail">
      <div className="detail-heading">
        <div>
          <span className="eyebrow">病害任务 {order?.id || defect.id}</span>
          <h2>{defect.type}</h2>
        </div>
        <span className={`status-pill ${status.tone}`}>{status.label}</span>
      </div>

      <EvidencePanel defect={defect} />

      <div className="detail-severity-row">
        <span className={`severity-badge ${severity.tone}`}>
          <AlertTriangle size={14} />
          {severity.label}
        </span>
        <span className="confidence-copy">
          模型置信度 <strong>{Math.round(defect.confidence * 100)}%</strong>
        </span>
      </div>

      <div className="detail-data-grid">
        <div>
          <span>道路编号</span>
          <strong>{defect.roadCode}</strong>
        </div>
        <div>
          <span>出现频次</span>
          <strong>{defect.terminalCount} 个终端</strong>
        </div>
        <div>
          <span>纬度</span>
          <strong>{formatCoordinate(defect.lat, "lat")}</strong>
        </div>
        <div>
          <span>经度</span>
          <strong>{formatCoordinate(defect.lng, "lng")}</strong>
        </div>
        <div>
          <span>车道</span>
          <strong>{defect.lane}</strong>
        </div>
        <div>
          <span>桩号</span>
          <strong>{defect.mileage || "--"}</strong>
        </div>
      </div>

      <section className="detail-section">
        <div className="section-label-row">
          <span><Radio size={15} /> 多终端交叉验证</span>
          <strong>{defect.terminalCount} / {terminalCapacity}</strong>
        </div>
        <div className="terminal-track">
          {Array.from({ length: terminalCapacity }).map((_, index) => (
            <span
              key={index}
              className={index < Math.min(defect.terminalCount, terminalCapacity) ? "filled" : ""}
            />
          ))}
        </div>
        <p className="muted-copy">
          最近捕获 {formatDateTime(defect.lastSeen)} · 采集速度 {defect.capture.speed} km/h
        </p>
      </section>

      <section className="recommendation-box">
        <div className="recommendation-title">
          <Crosshair size={16} />
          研判建议
          <strong>{defect.recommendation.score}</strong>
        </div>
        <p>{defect.recommendation.reason}</p>
      </section>

      {(order?.status === "in_progress" || order?.repairPhoto) && (
        <section className="detail-section repair-section">
          <div className="section-label-row">
            <span><ShieldCheck size={15} /> 完工回传</span>
            <strong>{order?.status === "completed" ? "已归档" : "照片必传"}</strong>
          </div>
          <label className={`repair-upload ${repairPhoto ? "has-image" : ""}`}>
            <input
              type="file"
              accept="image/*"
              capture="environment"
              disabled={uploading || order?.status === "completed"}
              onChange={selectRepairPhoto}
            />
            {repairPhoto ? (
              <>
                <img src={repairPhoto} alt="修复完成现场照片" />
                <span className="repair-upload-action">
                  <UploadCloud size={14} />
                  {order?.status === "completed" ? "修复照片已归档" : "重新选择照片"}
                </span>
              </>
            ) : (
              <span className="repair-upload-empty">
                <ImagePlus size={24} />
                <strong>{uploading ? "正在处理照片..." : "拍摄或上传修复照片"}</strong>
                <small>照片将压缩后随工单归档，不采集车内影像</small>
              </span>
            )}
          </label>
          <textarea
            className="repair-note"
            rows={2}
            value={repairNote}
            disabled={order?.status === "completed"}
            onChange={(event) => setRepairNote(event.target.value)}
            placeholder="补充修复材料、施工范围或现场情况（选填）"
          />
        </section>
      )}

      <section className="detail-section timeline-section">
        <div className="section-label-row">
          <span>任务动态</span>
          {order && <strong>截止 {formatTime(order.dueAt)}</strong>}
        </div>
        <div className="timeline-list">
          {(order?.timeline || defect.timeline).slice(0, 3).map((item, index) => (
            <div className="timeline-item" key={`${item.time}-${index}`}>
              <i />
              <div>
                <strong>{item.title}</strong>
                <span>{formatDateTime(item.time)} · {item.detail}</span>
              </div>
            </div>
          ))}
        </div>
      </section>

      <div className="detail-actions">
        <button type="button" className="secondary-button" onClick={openInOsm}>
          <Navigation size={17} />
          地图导航
        </button>
        {order?.status === "assigned" && (
          <button
            type="button"
            className="primary-button"
            disabled={refreshing}
            onClick={() => updateStatus("in_progress")}
          >
            <Camera size={17} />
            开始处置
          </button>
        )}
        {order?.status === "in_progress" && (
          <button
            type="button"
            className="primary-button"
            disabled={refreshing || !repairPhoto}
            onClick={() => updateStatus("completed")}
          >
            <CheckCircle2 size={17} />
            完成处置
          </button>
        )}
        {(!order || order.status === "completed") && (
          <button type="button" className="primary-button" onClick={openInOsm}>
            <MapPin size={17} />
            查看位置
          </button>
        )}
      </div>
    </div>
  );
}

export default function WorkerView({
  store,
  selectedDefect,
  setSelectedDefect,
  onRefresh,
  showToast,
}) {
  const [tab, setTab] = useState("tasks");
  const [query, setQuery] = useState("");
  const [refreshing, setRefreshing] = useState(false);
  const currentWorkerId = "w-01";

  const myOrders = useMemo(
    () =>
      store.orders
        .filter((order) => order.workerId === currentWorkerId)
        .sort((a, b) => {
          if (a.status === "completed" && b.status !== "completed") return 1;
          if (b.status === "completed" && a.status !== "completed") return -1;
          return new Date(a.dueAt) - new Date(b.dueAt);
        }),
    [store.orders],
  );

  const defectsForTab = useMemo(() => {
    const needle = query.trim().toLowerCase();
    return store.defects
      .filter((defect) => {
        const order = orderForDefect(store.orders, defect.id);
        const tabMatch =
          tab === "tasks"
            ? order?.workerId === currentWorkerId && order.status !== "completed"
            : tab === "completed"
              ? order?.workerId === currentWorkerId && order.status === "completed"
              : defect.status !== "completed";
        const queryMatch =
          !needle ||
          [defect.type, defect.roadCode, defect.roadName]
            .join(" ")
            .toLowerCase()
            .includes(needle);
        return tabMatch && queryMatch;
      })
      .sort((a, b) => {
        const rank = { high: 3, medium: 2, low: 1 };
        return (
          (rank[b.severity] || 0) - (rank[a.severity] || 0) ||
          new Date(b.lastSeen) - new Date(a.lastSeen)
        );
      });
  }, [query, store.defects, store.orders, tab]);

  const selected =
    selectedDefect ||
    defectsForTab[0] ||
    store.defects.find((defect) => {
      const order = orderForDefect(store.orders, defect.id);
      return order?.workerId === currentWorkerId;
    }) ||
    store.defects[0];
  const selectedOrder = selected ? orderForDefect(store.orders, selected.id) : null;
  const taskCount = myOrders.filter((order) => order.status !== "completed").length;

  return (
    <div className="worker-layout">
      <aside className="worker-list-pane">
        <div className="worker-greeting">
          <span className="eyebrow">10月21日 · 星期三</span>
          <h1>早上好，王磊</h1>
          <p>今日 {taskCount} 项养护任务待处理</p>
        </div>

        <div className="task-tabs" role="tablist">
          <button
            type="button"
            className={tab === "tasks" ? "active" : ""}
            onClick={() => setTab("tasks")}
          >
            我的任务 <span>{taskCount}</span>
          </button>
          <button
            type="button"
            className={tab === "nearby" ? "active" : ""}
            onClick={() => setTab("nearby")}
          >
            附近病害
          </button>
          <button
            type="button"
            className={tab === "completed" ? "active" : ""}
            onClick={() => setTab("completed")}
          >
            已完成
          </button>
        </div>

        <div className="worker-search">
          <Search size={16} />
          <input
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="搜索道路或病害"
            aria-label="搜索道路或病害"
          />
          <button type="button" aria-label="筛选">
            <ListFilter size={16} />
          </button>
        </div>

        <div className="worker-order-list">
          {defectsForTab.map((defect) => {
            const order = orderForDefect(store.orders, defect.id);
            return (
              <WorkerOrderCard
                key={defect.id}
                defect={defect}
                order={order}
                active={selected?.id === defect.id}
                onClick={() => setSelectedDefect(defect)}
              />
            );
          })}
          {!defectsForTab.length && (
            <div className="empty-state">
              <CheckCircle2 size={24} />
              <strong>当前列表为空</strong>
              <span>新的病害任务会在此处出现</span>
            </div>
          )}
        </div>
      </aside>

      <main className="worker-map-pane">
        <MapView
          defects={store.defects}
          selectedDefect={selected}
          onSelect={setSelectedDefect}
        />
        <div className="worker-map-heading">
          <span className="map-mode-icon"><Layers3 size={17} /></span>
          <div>
            <strong>灞桥养护作业图</strong>
            <span>{defectsForTab.length} 个点位 · OpenStreetMap</span>
          </div>
        </div>
        <div className="map-floating-tools">
          <button type="button" aria-label="定位到当前位置"><LocateFixed size={18} /></button>
          <button type="button" aria-label="图层"><Layers3 size={18} /></button>
        </div>
        <div className="worker-map-note">
          <span className="live-dot" />
          终端在线 {store.summary.activeTerminals}/{store.summary.totalTerminals}
        </div>
      </main>

      <aside className="worker-detail-pane">
        {selected && (
          <WorkerDetail
            key={selected.id}
            defect={selected}
            order={selectedOrder}
            terminalCapacity={store.summary.totalTerminals}
            onRefresh={onRefresh}
            showToast={showToast}
            refreshing={refreshing}
            setRefreshing={setRefreshing}
          />
        )}
      </aside>
    </div>
  );
}
