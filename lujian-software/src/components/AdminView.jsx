import { useMemo, useState } from "react";
import {
  Activity,
  ArrowUpRight,
  Box,
  Camera,
  Check,
  ChevronRight,
  CircleAlert,
  ClipboardList,
  Clock,
  Cloud,
  Cpu,
  Database,
  FileCheck2,
  Filter,
  Gauge,
  GitMerge,
  HardDrive,
  Layers,
  Map,
  MapPinned,
  Network,
  Play,
  RadioTower,
  RefreshCw,
  ScanLine,
  Search,
  Send,
  ShieldCheck,
  Users,
  Workflow,
  Wrench,
  X,
  Zap,
} from "lucide-react";
import { api } from "../api";
import {
  defectStatusMeta,
  formatCoordinate,
  formatDateTime,
  formatPriority,
  formatTime,
  orderForDefect,
  severityMeta,
} from "../lib/format";
import MapView from "./MapView";
import ServiceView from "./ServiceView";
import TerminalView from "./TerminalView";
import TwinScene from "./TwinScene";

const navItems = [
  { id: "twin", label: "数字孪生", icon: Gauge },
  { id: "ledger", label: "病害台账", icon: ClipboardList },
  { id: "dispatch", label: "工单调度", icon: Send },
  { id: "terminals", label: "采集终端", icon: Camera },
  { id: "pipeline", label: "数据处理", icon: Workflow },
  { id: "services", label: "合作服务", icon: Network },
  { id: "models", label: "模型管理", icon: Cpu },
];

function PanelHeading({ kicker, title, action }) {
  return (
    <div className="panel-heading">
      <div>
        {kicker && <span className="eyebrow">{kicker}</span>}
        <h2>{title}</h2>
      </div>
      {action}
    </div>
  );
}

function KpiStrip({ summary }) {
  const items = [
    {
      label: "监测路段",
      value: summary.monitoredKm.toFixed(1),
      unit: "km",
      meta: "国省干线 + 农村公路",
      icon: MapPinned,
      tone: "blue",
    },
    {
      label: "在线终端",
      value: summary.activeTerminals,
      unit: `/ ${summary.totalTerminals}`,
      meta: `在线率 ${Math.round((summary.activeTerminals / summary.totalTerminals) * 100)}%`,
      icon: RadioTower,
      tone: "safe",
    },
    {
      label: "待研判病害",
      value: summary.pendingDefects,
      unit: "处",
      meta: `${summary.highRisk} 处高风险`,
      icon: CircleAlert,
      tone: "danger",
    },
    {
      label: "未闭环工单",
      value: summary.openOrders,
      unit: "单",
      meta: `${summary.completedOrders} 单今日闭环`,
      icon: Wrench,
      tone: "warning",
    },
  ];
  return (
    <div className="kpi-strip">
      {items.map((item) => {
        const Icon = item.icon;
        return (
          <div className="kpi-item" key={item.label}>
            <span className={`kpi-icon ${item.tone}`}><Icon size={18} /></span>
            <div>
              <span>{item.label}</span>
              <strong>{item.value}<small>{item.unit}</small></strong>
              <small>{item.meta}</small>
            </div>
          </div>
        );
      })}
    </div>
  );
}

function RiskBadge({ severity }) {
  const meta = severityMeta[severity] || severityMeta.low;
  return <span className={`severity-label ${meta.tone}`}>{meta.label}</span>;
}

function StatusBadge({ status }) {
  const meta = defectStatusMeta[status] || defectStatusMeta.pending_review;
  return <span className={`status-badge ${meta.tone}`}>{meta.label}</span>;
}

function RecentDefectTable({ defects, onSelect, onDispatch, limit }) {
  const rows = defects.slice(0, limit || defects.length);
  return (
    <div className="table-wrap">
      <table className="data-table">
        <thead>
          <tr>
            <th>病害与位置</th>
            <th>道路编号</th>
            <th>终端频次</th>
            <th>置信度</th>
            <th>风险</th>
            <th>状态</th>
            <th aria-label="操作" />
          </tr>
        </thead>
        <tbody>
          {rows.map((defect) => (
            <tr key={defect.id} onClick={() => onSelect(defect)}>
              <td>
                <div className="table-primary">
                  <span className={`type-glyph ${defect.severity}`}>
                    {defect.type.slice(0, 1)}
                  </span>
                  <span>
                    <strong>{defect.type}</strong>
                    <small>{defect.roadName}</small>
                  </span>
                </div>
              </td>
              <td><span className="mono">{defect.roadCode}</span></td>
              <td>
                <span className="terminal-count">
                  <RadioTower size={13} />
                  {defect.terminalCount}
                </span>
              </td>
              <td>{Math.round(defect.confidence * 100)}%</td>
              <td><RiskBadge severity={defect.severity} /></td>
              <td><StatusBadge status={defect.status} /></td>
              <td>
                <button
                  type="button"
                  className="table-action"
                  onClick={(event) => {
                    event.stopPropagation();
                    onDispatch(defect);
                  }}
                  aria-label={`研判${defect.type}`}
                >
                  <ArrowUpRight size={16} />
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function DispatchModal({ defect, workers, onClose, onConfirm, busy }) {
  const [workerId, setWorkerId] = useState(workers[0]?.id || "");
  const [priority, setPriority] = useState(
    defect.severity === "high" ? "high" : defect.severity === "medium" ? "medium" : "low",
  );
  const [note, setNote] = useState(defect.recommendation.reason);

  return (
    <div className="modal-backdrop" role="presentation" onMouseDown={onClose}>
      <div
        className="dispatch-modal"
        role="dialog"
        aria-modal="true"
        aria-labelledby="dispatch-title"
        onMouseDown={(event) => event.stopPropagation()}
      >
        <div className="modal-heading">
          <div>
            <span className="eyebrow">WORK ORDER</span>
            <h2 id="dispatch-title">派发养护工单</h2>
          </div>
          <button type="button" className="icon-button" onClick={onClose} aria-label="关闭">
            <X size={18} />
          </button>
        </div>

        <div className="modal-defect-summary">
          <span className={`type-glyph ${defect.severity}`}>{defect.type.slice(0, 1)}</span>
          <div>
            <strong>{defect.type} · {defect.roadCode}</strong>
            <span>{defect.roadName}</span>
          </div>
          <RiskBadge severity={defect.severity} />
        </div>

        <div className="modal-form">
          <label>
            <span>作业人员</span>
            <select value={workerId} onChange={(event) => setWorkerId(event.target.value)}>
              {workers.map((worker) => (
                <option value={worker.id} key={worker.id}>
                  {worker.name} · {worker.team}
                </option>
              ))}
            </select>
          </label>
          <label>
            <span>优先级</span>
            <div className="segmented-control">
              {["urgent", "high", "medium", "low"].map((value) => (
                <button
                  type="button"
                  key={value}
                  className={priority === value ? "active" : ""}
                  onClick={() => setPriority(value)}
                >
                  {formatPriority(value)}
                </button>
              ))}
            </div>
          </label>
          <label>
            <span>派发说明</span>
            <textarea
              rows={4}
              value={note}
              onChange={(event) => setNote(event.target.value)}
            />
          </label>
        </div>

        <div className="recommendation-strip">
          <span><Zap size={15} /> 系统建议 {defect.recommendation.score}</span>
          <p>{defect.recommendation.reason}</p>
        </div>

        <div className="modal-actions">
          <button type="button" className="secondary-button" onClick={onClose}>取消</button>
          <button
            type="button"
            className="primary-button"
            disabled={busy || !workerId}
            onClick={() => onConfirm({ workerId, priority, note })}
          >
            <Send size={16} />
            确认派发
          </button>
        </div>
      </div>
    </div>
  );
}

function DashboardView({
  store,
  selectedDefect,
  setSelectedDefect,
  openDispatch,
  onRefresh,
  showToast,
}) {
  const queue = useMemo(
    () =>
      store.defects
        .filter((defect) => ["pending_review", "awaiting_dispatch"].includes(defect.status))
        .sort((a, b) => b.recommendation.score - a.recommendation.score),
    [store.defects],
  );
  const current = selectedDefect || queue[0] || store.defects[0];

  return (
    <>
      <KpiStrip summary={store.summary} />
      <div className="dashboard-grid">
        <section className="map-panel">
          <PanelHeading
            kicker="ROAD NETWORK"
            title="病害空间分布"
            action={
              <span className="panel-meta"><RadioTower size={14} /> {store.terminals.length} 台众包终端</span>
            }
          />
          <MapView
            defects={store.defects}
            selectedDefect={current}
            onSelect={setSelectedDefect}
            className="dashboard-map"
            compact
          />
        </section>

        <div className="dashboard-side">
          <section className="twin-panel">
            <PanelHeading
              kicker="SPATIAL MESH"
              title="道路数字孪生"
              action={<span className="panel-meta"><Activity size={14} /> 实时</span>}
            />
            <TwinScene defects={store.defects} selectedDefect={current} />
          </section>

          <section className="triage-panel">
            <PanelHeading
              kicker="DISPATCH QUEUE"
              title="优先研判"
              action={<span className="queue-count">{queue.length}</span>}
            />
            <div className="triage-list">
              {queue.slice(0, 3).map((defect) => (
                <button
                  type="button"
                  className="triage-item"
                  key={defect.id}
                  onClick={() => setSelectedDefect(defect)}
                >
                  <span className={`score-ring ${defect.recommendation.score >= 80 ? "high" : ""}`}>
                    {defect.recommendation.score}
                  </span>
                  <span>
                    <strong>{defect.type} · {defect.terminalCount}个终端</strong>
                    <small>{defect.roadCode}</small>
                  </span>
                  <ChevronRight size={16} />
                </button>
              ))}
            </div>
            <button type="button" className="full-link" onClick={() => openDispatch(queue[0])}>
              进入工单调度
              <ArrowUpRight size={15} />
            </button>
          </section>
        </div>
      </div>

      <section className="recent-panel">
        <PanelHeading
          kicker="LATEST CAPTURE"
          title="最新病害事件"
          action={
            <button type="button" className="text-button" onClick={onRefresh}>
              <RefreshCw size={14} /> 刷新
            </button>
          }
        />
        <RecentDefectTable
          defects={[...store.defects].sort((a, b) => new Date(b.lastSeen) - new Date(a.lastSeen))}
          onSelect={setSelectedDefect}
          onDispatch={openDispatch}
          limit={6}
        />
      </section>
    </>
  );
}

function LedgerView({ store, onDispatch, setSelectedDefect }) {
  const [query, setQuery] = useState("");
  const [status, setStatus] = useState("all");
  const [severity, setSeverity] = useState("all");

  const filtered = useMemo(() => {
    const needle = query.trim().toLowerCase();
    return store.defects.filter((defect) => {
      const statusMatch = status === "all" || defect.status === status;
      const severityMatch = severity === "all" || defect.severity === severity;
      const queryMatch =
        !needle ||
        [defect.type, defect.roadCode, defect.roadName, defect.id]
          .join(" ")
          .toLowerCase()
          .includes(needle);
      return statusMatch && severityMatch && queryMatch;
    });
  }, [query, severity, status, store.defects]);

  return (
    <section className="ledger-panel">
      <PanelHeading
        kicker="DEFECT LEDGER"
        title="病害台账"
        action={<span className="panel-meta">{filtered.length} 条记录</span>}
      />
      <div className="ledger-toolbar">
        <div className="table-search">
          <Search size={16} />
          <input
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="搜索道路、编号或病害类型"
            aria-label="搜索病害台账"
          />
        </div>
        <div className="filter-group">
          <Filter size={15} />
          <select value={status} onChange={(event) => setStatus(event.target.value)}>
            <option value="all">全部状态</option>
            <option value="pending_review">待复核</option>
            <option value="awaiting_dispatch">待研判</option>
            <option value="dispatched">已派发</option>
            <option value="in_progress">处置中</option>
            <option value="completed">已完成</option>
            <option value="observing">观察中</option>
          </select>
          <select value={severity} onChange={(event) => setSeverity(event.target.value)}>
            <option value="all">全部风险</option>
            <option value="high">高风险</option>
            <option value="medium">中风险</option>
            <option value="low">低风险</option>
          </select>
        </div>
      </div>
      <RecentDefectTable
        defects={filtered}
        onSelect={setSelectedDefect}
        onDispatch={onDispatch}
      />
    </section>
  );
}

function DispatchWorkspace({
  store,
  selectedDefect,
  setSelectedDefect,
  onDispatch,
  onReview,
  busy,
}) {
  const queue = store.defects
    .filter((defect) => ["pending_review", "awaiting_dispatch"].includes(defect.status))
    .sort((a, b) => b.recommendation.score - a.recommendation.score);
  const current = selectedDefect || queue[0] || store.defects[0];
  const order = current ? orderForDefect(store.orders, current.id) : null;

  return (
    <div className="dispatch-workspace">
      <aside className="dispatch-queue-panel">
        <PanelHeading
          kicker="TRIAGE QUEUE"
          title="待研判病害"
          action={<span className="queue-count">{queue.length}</span>}
        />
        <div className="dispatch-queue-list">
          {queue.map((defect) => (
            <button
              type="button"
              key={defect.id}
              className={`dispatch-queue-card ${current?.id === defect.id ? "active" : ""}`}
              onClick={() => setSelectedDefect(defect)}
            >
              <span className={`score-ring ${defect.recommendation.score >= 80 ? "high" : ""}`}>
                {defect.recommendation.score}
              </span>
              <span>
                <strong>{defect.type}</strong>
                <small>{defect.roadCode}</small>
                <small>{defect.terminalCount} 个终端 · {defect.confidence.toFixed(2)}</small>
              </span>
              <RiskBadge severity={defect.severity} />
            </button>
          ))}
        </div>
      </aside>

      {current && (
        <div className="dispatch-focus">
          <div className="dispatch-map-row">
            <MapView
              defects={store.defects}
              selectedDefect={current}
              onSelect={setSelectedDefect}
              className="dispatch-map"
              compact
            />
            <div className="dispatch-detail-card">
              <div className="dispatch-detail-head">
                <span className={`type-glyph ${current.severity}`}>{current.type.slice(0, 1)}</span>
                <div>
                  <span className="eyebrow">{current.id}</span>
                  <h2>{current.type}</h2>
                </div>
                <StatusBadge status={current.status} />
              </div>
              <div className="dispatch-score">
                <span className={`score-ring large ${current.recommendation.score >= 80 ? "high" : ""}`}>
                  {current.recommendation.score}
                </span>
                <div>
                  <strong>派发建议</strong>
                  <span>{current.recommendation.action === "dispatch" ? "建议派发" : current.recommendation.action === "review" ? "建议复核" : "建议观察"}</span>
                </div>
              </div>
              <p className="recommendation-copy">{current.recommendation.reason}</p>
              <dl className="dispatch-facts">
                <div><dt>道路编号</dt><dd>{current.roadCode}</dd></div>
                <div><dt>桩号</dt><dd>{current.mileage || "--"}</dd></div>
                <div><dt>终端频次</dt><dd>{current.terminalCount} 个</dd></div>
                <div><dt>模型置信度</dt><dd>{Math.round(current.confidence * 100)}%</dd></div>
                <div><dt>纬度</dt><dd>{formatCoordinate(current.lat, "lat")}</dd></div>
                <div><dt>经度</dt><dd>{formatCoordinate(current.lng, "lng")}</dd></div>
              </dl>
              <div className="dispatch-actions">
                <button
                  type="button"
                  className="secondary-button"
                  disabled={busy || current.status !== "pending_review"}
                  onClick={() => onReview(current, "observe")}
                >
                  <Clock size={16} />
                  转观察
                </button>
                {order ? (
                  <button type="button" className="primary-button" disabled>
                    <Check size={16} />
                    已派发
                  </button>
                ) : (
                  <button
                    type="button"
                    className="primary-button"
                    onClick={() => onDispatch(current)}
                  >
                    <Send size={16} />
                    派发工单
                  </button>
                )}
              </div>
            </div>
          </div>

          <div className="dispatch-history">
            <PanelHeading kicker="EVIDENCE CHAIN" title="研判证据链" />
            <div className="evidence-chain">
              <div><ScanLine size={18} /><span>模型识别</span><strong>{current.typeCode} · {Math.round(current.confidence * 100)}%</strong></div>
              <i />
              <div><GitMerge size={18} /><span>多帧合并</span><strong>{current.terminalCount} 个终端</strong></div>
              <i />
              <div><MapPinned size={18} /><span>路段匹配</span><strong>{current.roadCode}</strong></div>
              <i />
              <div><FileCheck2 size={18} /><span>人工研判</span><strong>{current.recommendation.score} 分</strong></div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function PipelineView({ store, onRefresh, showToast, busy, setBusy }) {
  const { pipeline } = store;
  const runBatch = async () => {
    setBusy(true);
    try {
      await api.runPipeline(120);
      showToast("120 帧演示批次已进入处理流水线");
      await onRefresh();
    } catch (error) {
      showToast(error.message, "error");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="pipeline-view">
      <section className="pipeline-hero">
        <div>
          <span className="eyebrow">DATA PIPELINE</span>
          <h2>从终端图像到可执行工单</h2>
          <p>低成本后装终端按固定间隔上传路面图像，质量筛查、YOLOv8 推理、多帧去重、道路匹配和人工复核在同一条事件链上留痕。</p>
        </div>
        <button type="button" className="primary-button" disabled={busy} onClick={runBatch}>
          <Play size={16} />
          运行演示批次
        </button>
      </section>

      <section className="pipeline-flow-panel">
        <div className="pipeline-summary-row">
          <span><Cloud size={16} /> 最近批次 {formatDateTime(pipeline.lastRun)}</span>
          <span className={pipeline.status === "idle" ? "safe-text" : ""}>
            <Activity size={16} /> {pipeline.status === "idle" ? "流水线空闲" : "批次处理中"}
          </span>
        </div>
        <div className="pipeline-stages">
          {pipeline.stages.map((stage, index) => {
            const icons = [Database, ShieldCheck, ScanLine, GitMerge, MapPinned, Users];
            const Icon = icons[index] || Workflow;
            return (
              <div className="pipeline-stage-wrap" key={stage.id}>
                <div className={`pipeline-stage ${stage.status}`}>
                  <span className="stage-number">{String(index + 1).padStart(2, "0")}</span>
                  <Icon size={21} />
                  <strong>{stage.name}</strong>
                  <span>{stage.detail}</span>
                  <div className="stage-stats">
                    <span>{stage.passed.toLocaleString("zh-CN")}</span>
                    <small>{stage.latency}</small>
                  </div>
                </div>
                {index < pipeline.stages.length - 1 && (
                  <ChevronRight className="stage-arrow" size={18} />
                )}
              </div>
            );
          })}
        </div>
      </section>

      <div className="pipeline-metrics-grid">
        {[
          ["入湖帧", pipeline.counters.ingested, "累计图像与元数据"],
          ["质量通过", pipeline.counters.qualified, "合格率 94.7%"],
          ["病害检测", pipeline.counters.detected, "原始检测框"],
          ["聚合病害", pipeline.counters.merged, "去除跨帧重复"],
          ["待人工复核", pipeline.counters.pendingReview, "低置信度优先"],
          ["已发布点位", pipeline.counters.published, "进入数字孪生"],
        ].map(([label, value, meta]) => (
          <div key={label}>
            <span>{label}</span>
            <strong>{Number(value).toLocaleString("zh-CN")}</strong>
            <small>{meta}</small>
          </div>
        ))}
      </div>

      <div className="pipeline-lower-grid">
        <section className="terminal-table-panel">
          <PanelHeading
            kicker="EDGE NODES"
            title="终端接入状态"
            action={<span className="panel-meta">{store.summary.activeTerminals} 在线</span>}
          />
          <div className="terminal-table">
            {store.terminals.map((terminal) => (
              <div key={terminal.id}>
                <span className={`terminal-status ${terminal.status}`} />
                <span>
                  <strong>{terminal.vehicle}</strong>
                  <small>{terminal.vehicleType || "采集车辆"} · {terminal.id}</small>
                </span>
                <span>{terminal.segment}</span>
                <span>{terminal.battery}%</span>
                <small>{formatTime(terminal.lastSeen)}</small>
              </div>
            ))}
          </div>
        </section>
        <section className="contract-panel">
          <PanelHeading kicker="EVENT CONTRACT" title="核心数据字段" />
          <div className="field-cloud">
            {[
              "defect_id",
              "road_code",
              "type_code",
              "severity",
              "lat / lng",
              "mileage",
              "terminal_ids",
              "confidence",
              "first_seen",
              "last_seen",
              "evidence_uri",
              "dispatch_score",
            ].map((field) => <span key={field}>{field}</span>)}
          </div>
          <div className="contract-note">
            <HardDrive size={17} />
            <div>
              <strong>合作接入接口</strong>
              <span>POST /api/v1/detections</span>
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}

function ModelsView({ store }) {
  const selected = store.models.find((model) => model.selected) || store.models[0];
  return (
    <div className="models-view">
      <section className="model-hero">
        <div className="model-hero-copy">
          <span className="eyebrow">OPEN SOURCE BASELINE</span>
          <h2>{selected.name}</h2>
          <p>{selected.note}</p>
          <div className="model-status-row">
            <span className="safe-text"><Check size={15} /> 当前基线</span>
            <span><ShieldCheck size={15} /> {selected.license}</span>
            <span><Box size={15} /> {selected.input}</span>
          </div>
        </div>
        <div className="model-orbit">
          <span className="orbit-core"><ScanLine size={27} /></span>
          <span className="orbit-node one">D00</span>
          <span className="orbit-node two">D10</span>
          <span className="orbit-node three">D20</span>
          <span className="orbit-node four">D40</span>
        </div>
      </section>

      <div className="model-details-grid">
        <section>
          <PanelHeading kicker="MODEL SPEC" title="推理规格" />
          <dl className="spec-list">
            <div><dt>任务</dt><dd>{selected.task}</dd></div>
            <div><dt>框架</dt><dd>{selected.framework}</dd></div>
            <div><dt>运行方式</dt><dd>{selected.runtime}</dd></div>
            <div><dt>输入尺寸</dt><dd>{selected.input}</dd></div>
            <div><dt>输出</dt><dd>类别、框、置信度、病害几何</dd></div>
            <div><dt>预处理</dt><dd>质量门控、路面 ROI、归一化</dd></div>
          </dl>
        </section>
        <section>
          <PanelHeading kicker="DETECTION CLASSES" title="病害类别" />
          <div className="class-list">
            {selected.classes.map((item, index) => (
              <div key={item}>
                <span className={`class-swatch class-${index}`} />
                <strong>{item}</strong>
                <small>{["纵向纹理", "横向贯穿", "网状扩展", "结构性破损"][index]}</small>
              </div>
            ))}
          </div>
          <div className="license-note">
            <ShieldCheck size={17} />
            <p>YOLOv8 代码与权重的开放许可证需在商业分发前复核；保留 Apache-2.0 的 RTMDet 作为许可替代基线。</p>
          </div>
        </section>
      </div>

      <section className="model-comparison-panel">
        <PanelHeading kicker="MODEL REGISTRY" title="候选模型" />
        <div className="model-cards">
          {store.models.map((model) => (
            <div className={`model-card ${model.selected ? "selected" : ""}`} key={model.id}>
              <span className="model-card-icon"><Cpu size={21} /></span>
              <div>
                <span className="eyebrow">{model.status.toUpperCase()}</span>
                <h3>{model.name}</h3>
                <p>{model.note}</p>
              </div>
              <dl>
                <div><dt>许可证</dt><dd>{model.license}</dd></div>
                <div><dt>版本</dt><dd>{model.id}</dd></div>
              </dl>
              {model.selected && <span className="selected-flag"><Check size={13} /> BASELINE</span>}
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}

export default function AdminView({
  store,
  selectedDefect,
  setSelectedDefect,
  onRefresh,
  showToast,
}) {
  const [section, setSection] = useState(() => {
    const requested = new URLSearchParams(window.location.search).get("section");
    return navItems.some((item) => item.id === requested) ? requested : "twin";
  });
  const [dispatchTarget, setDispatchTarget] = useState(null);
  const [busy, setBusy] = useState(false);

  const openDispatch = (defect) => {
    if (!defect) return;
    setDispatchTarget(defect);
  };

  const confirmDispatch = async ({ workerId, priority, note }) => {
    if (!dispatchTarget) return;
    setBusy(true);
    try {
      await api.dispatchDefect(dispatchTarget.id, workerId, priority, note);
      showToast(`工单已派发 · ${dispatchTarget.roadCode}`);
      setDispatchTarget(null);
      await onRefresh();
    } catch (error) {
      if (error.payload?.order) {
        showToast("该病害已有未闭环工单", "error");
        setDispatchTarget(null);
        await onRefresh();
      } else {
        showToast(error.message, "error");
      }
    } finally {
      setBusy(false);
    }
  };

  const reviewAsObserve = async (defect) => {
    setBusy(true);
    try {
      await api.reviewDefect(defect.id, "observe");
      showToast("已转为观察，暂不派发");
      await onRefresh();
    } catch (error) {
      showToast(error.message, "error");
    } finally {
      setBusy(false);
    }
  };

  const sectionContent = {
    twin: (
      <DashboardView
        store={store}
        selectedDefect={selectedDefect}
        setSelectedDefect={setSelectedDefect}
        openDispatch={(defect) => {
          if (defect) setSelectedDefect(defect);
          setSection("dispatch");
        }}
        onRefresh={onRefresh}
        showToast={showToast}
      />
    ),
    ledger: (
      <LedgerView
        store={store}
        onDispatch={openDispatch}
        setSelectedDefect={setSelectedDefect}
      />
    ),
    dispatch: (
      <DispatchWorkspace
        store={store}
        selectedDefect={selectedDefect}
        setSelectedDefect={setSelectedDefect}
        onDispatch={openDispatch}
        onReview={reviewAsObserve}
        busy={busy}
      />
    ),
    terminals: <TerminalView store={store} />,
    pipeline: (
      <PipelineView
        store={store}
        onRefresh={onRefresh}
        showToast={showToast}
        busy={busy}
        setBusy={setBusy}
      />
    ),
    services: <ServiceView />,
    models: <ModelsView store={store} />,
  }[section];

  const titleMap = {
    twin: ["道路数字孪生控制台", "实时映射路段资产、病害与养护动作"],
    ledger: ["病害台账", "统一查看病害证据、空间位置与闭环状态"],
    dispatch: ["工单调度", "结合风险、终端频次与现场条件进行人工研判"],
    terminals: ["采集终端", "低成本后装终端与社会车辆采集网络"],
    pipeline: ["数据处理流程", "从边缘采集到数字孪生发布的完整事件链"],
    services: ["合作服务", "面向路政、车企、科研与采集伙伴的开放服务"],
    models: ["模型管理", "开源模型基线、许可证与检测类别"],
  };

  return (
    <div className="admin-layout">
      <aside className="admin-sidebar">
        <div className="admin-sidebar-brand">
          <span>CROWDSOURCED ROAD CARE</span>
          <strong>众包巡检</strong>
          <small>OPS CONSOLE</small>
        </div>
        <nav>
          {navItems.map((item) => {
            const Icon = item.icon;
            return (
              <button
                type="button"
                className={section === item.id ? "active" : ""}
                key={item.id}
                onClick={() => setSection(item.id)}
              >
                <Icon size={17} />
                {item.label}
                {item.id === "dispatch" && <span>6</span>}
              </button>
            );
          })}
        </nav>
        <div className="admin-sidebar-status">
          <span><span className="live-dot" /> 数据服务正常</span>
          <small>同步延迟 1.8s</small>
          <div className="status-meter"><i /></div>
        </div>
      </aside>

      <main className="admin-main">
        <header className="admin-header">
          <div>
            <span className="eyebrow">2026年10月21日 · 灞桥路网</span>
            <h1>{titleMap[section][0]}</h1>
            <p>{titleMap[section][1]}</p>
          </div>
          <div className="admin-header-actions">
            <span className="demo-badge"><span /> LOCAL DEMO DATA</span>
            <button type="button" className="secondary-button" onClick={onRefresh}>
              <RefreshCw size={15} />
              刷新
            </button>
          </div>
        </header>
        <div className="admin-content">{sectionContent}</div>
      </main>

      {dispatchTarget && (
        <DispatchModal
          defect={dispatchTarget}
          workers={store.workers}
          onClose={() => setDispatchTarget(null)}
          onConfirm={confirmDispatch}
          busy={busy}
        />
      )}
    </div>
  );
}
