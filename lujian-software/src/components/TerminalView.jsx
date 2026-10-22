import {
  BatteryCharging,
  Camera,
  CarFront,
  MapPinned,
  Navigation,
  RadioTower,
  Route,
  ShieldCheck,
  Truck,
  Wifi,
} from "lucide-react";
import { formatTime } from "../lib/format";

const statusLabel = {
  online: "在线采集",
  idle: "怠速待命",
  offline: "离线",
};

const vehicleIcon = {
  公务车: CarFront,
  网约车: Navigation,
  物流车: Truck,
  养护车: Route,
};

function TerminalView({ store }) {
  const online = store.terminals.filter((terminal) => terminal.status === "online").length;
  const sourceCounts = store.terminals.reduce((counts, terminal) => {
    counts[terminal.vehicleType] = (counts[terminal.vehicleType] || 0) + 1;
    return counts;
  }, {});

  return (
    <div className="device-view">
      <section className="device-hero">
        <div className="device-hero-copy">
          <span className="eyebrow">LOW-COST CROWDSOURCED CAPTURE</span>
          <h2>后装式众包采集终端</h2>
          <p>
            车辆正常行驶时采集路面图像、时间、速度、航向与卫星定位。
            模块化后装，不改变车辆结构，也不采集车内影像与音频。
          </p>
          <div className="device-tags">
            <span><Camera size={14} /> 路面抽帧</span>
            <span><MapPinned size={14} /> 定位校核</span>
            <span><ShieldCheck size={14} /> 最小必要采集</span>
          </div>
        </div>
        <div className="device-schematic" aria-label="车载采集终端结构示意">
          <span className="schematic-grid" />
          <span className="schematic-car"><CarFront size={48} /></span>
          <span className="schematic-camera"><Camera size={18} /></span>
          <span className="schematic-gnss"><Navigation size={15} /> GNSS</span>
          <span className="schematic-link one" />
          <span className="schematic-link two" />
          <span className="schematic-label">MIRROR MOUNT / EDGE-1</span>
        </div>
      </section>

      <section className="device-metrics">
        <div><span>终端总数</span><strong>{store.terminals.length}<small>台</small></strong><em>后装模块化终端</em></div>
        <div><span>在线终端</span><strong>{online}<small>台</small></strong><em>在线率 {Math.round((online / store.terminals.length) * 100)}%</em></div>
        <div><span>当前覆盖</span><strong>{store.summary.monitoredKm.toFixed(1)}<small>km</small></strong><em>国省干线 + 农村公路</em></div>
        <div><span>图像合格率</span><strong>94.7<small>%</small></strong><em>模糊 / 逆光 / 遮挡筛查</em></div>
      </section>

      <div className="device-main-grid">
        <section className="device-terminal-panel">
          <div className="panel-heading">
            <div>
              <span className="eyebrow">CROWDSOURCED EDGE NODES</span>
              <h2>采集伙伴与终端状态</h2>
            </div>
            <span className="panel-meta"><RadioTower size={14} /> {online} 台在线</span>
          </div>
          <div className="device-terminal-list">
            {store.terminals.map((terminal) => {
              const VehicleIcon = vehicleIcon[terminal.vehicleType] || CarFront;
              return (
                <article className="device-terminal" key={terminal.id}>
                  <span className={`terminal-status ${terminal.status}`} />
                  <span className="device-vehicle-icon"><VehicleIcon size={20} /></span>
                  <div className="device-terminal-main">
                    <strong>{terminal.vehicleType} · {terminal.vehicle}</strong>
                    <span>{terminal.id} · {terminal.segment}</span>
                  </div>
                  <div className="device-terminal-meta">
                    <span><BatteryCharging size={13} /> {terminal.battery}%</span>
                    <span><Wifi size={13} /> {statusLabel[terminal.status]}</span>
                  </div>
                  <div className="device-terminal-foot">
                    <span>覆盖 {terminal.coverageKm} km</span>
                    <span>{terminal.firmware}</span>
                    <span>回传 {formatTime(terminal.lastSeen)}</span>
                  </div>
                </article>
              );
            })}
          </div>
        </section>

        <aside className="device-side-stack">
          <section className="device-spec-panel">
            <div className="panel-heading">
              <div>
                <span className="eyebrow">TERMINAL SPEC</span>
                <h2>低成本终端</h2>
              </div>
              <span className="device-cost">≤ 120 元</span>
            </div>
            <dl className="device-spec-list">
              <div><dt>整机 BOM</dt><dd>约 85 元</dd></div>
              <div><dt>安装位置</dt><dd>后视镜下方球头支架</dd></div>
              <div><dt>采集内容</dt><dd>路面图像 / 时间 / 速度 / 定位</dd></div>
              <div><dt>隐私边界</dt><dd>不采集车内影像与音频</dd></div>
              <div><dt>部署方式</dt><dd>模块化后装，不改车辆结构</dd></div>
            </dl>
          </section>
          <section className="device-source-panel">
            <div className="panel-heading">
              <div>
                <span className="eyebrow">CAPTURE MIX</span>
                <h2>采集来源</h2>
              </div>
            </div>
            <div className="source-bars">
              {Object.entries(sourceCounts).map(([source, count]) => (
                <div key={source}>
                  <span>{source}</span>
                  <i><b style={{ width: `${(count / store.terminals.length) * 100}%` }} /></i>
                  <strong>{count}</strong>
                </div>
              ))}
            </div>
          </section>
        </aside>
      </div>

      <section className="pilot-plan-panel">
        <div>
          <span className="eyebrow">90-DAY PILOT READINESS</span>
          <h2>首期试点准备</h2>
          <p>西安周边优先选择 2 至 3 个 200 至 500 公里路段，采用固定线路加弹性补采。</p>
        </div>
        <div className="pilot-route-list">
          {[...new Set(store.terminals.map((terminal) => terminal.segment))].map((segment, index) => (
            <span key={segment}>
              <b>0{index + 1}</b>
              {segment}
              <small>{index === 0 ? "国省干线" : index === 1 ? "农村公路" : "补充线路"}</small>
            </span>
          ))}
        </div>
        <span className="pilot-status">试点筹备中</span>
      </section>
    </div>
  );
}

export default TerminalView;
