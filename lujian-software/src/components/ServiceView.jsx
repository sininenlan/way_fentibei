import { useState } from "react";
import {
  ArrowUpRight,
  Building2,
  CarFront,
  Check,
  Code2,
  Copy,
  Database,
  FileJson,
  GraduationCap,
  Handshake,
  KeyRound,
  Landmark,
  LockKeyhole,
  RadioTower,
  ShieldCheck,
} from "lucide-react";

const programs = [
  {
    id: "government",
    audience: "路政养护单位",
    title: "按覆盖公里订阅",
    detail: "从病害发现、人工复核到派发与验收，形成可追踪的养护工单。",
    entry: "年度订阅 · 试点项目",
    icon: Landmark,
    tone: "teal",
    status: "主力服务",
  },
  {
    id: "automaker",
    audience: "车企与智能交通企业",
    title: "云端识别接口",
    detail: "输出病害类别、位置与采集时间，支持技术验证和量产授权。",
    entry: "API 接入 · 算法授权",
    icon: CarFront,
    tone: "blue",
    status: "接口方案",
  },
  {
    id: "research",
    audience: "高校与科研院所",
    title: "脱敏数据服务",
    detail: "提供标准化、长时序的道路病害样本，合同限定用途与再分发。",
    entry: "年度数据订阅 · 联合课题",
    icon: GraduationCap,
    tone: "amber",
    status: "授权模板",
  },
  {
    id: "capture",
    audience: "采集合作伙伴",
    title: "设备减免与服务优惠",
    detail: "公务车、网约车、物流车与养护车按既有线路参与固定采集。",
    entry: "固定线路 + 弹性补采",
    icon: Handshake,
    tone: "orange",
    status: "伙伴计划",
  },
];

const governanceItems = [
  {
    title: "最小必要采集",
    detail: "只处理路面图像、时间、速度与位置，不采集车内影像和音频。",
    icon: RadioTower,
  },
  {
    title: "脱敏与权限分级",
    detail: "车牌、人脸与可识别场景脱敏，按政府、车企、科研角色授权。",
    icon: LockKeyhole,
  },
  {
    title: "数据授权边界",
    detail: "不向第三方出售可识别个人或车辆的原始数据，科研仅提供脱敏或聚合版本。",
    icon: KeyRound,
  },
  {
    title: "地图合规",
    detail: "使用 OpenStreetMap 作为开源底图，不生产、不销售地图成果。",
    icon: ShieldCheck,
  },
];

const apiExample = `POST /api/v1/detections
x-api-key: demo-partner-key
Content-Type: application/json

{
  "terminalId": "TERM-XA-017",
  "roadCode": "G312-K1082+350",
  "typeCode": "D10",
  "confidence": 0.93,
  "lat": 34.27386,
  "lng": 109.06421,
  "timestamp": "2026-10-21T10:46:00+08:00"
}`;

function ServiceView() {
  const [copied, setCopied] = useState(false);

  const copyExample = async () => {
    try {
      await navigator.clipboard.writeText(apiExample);
      setCopied(true);
      window.setTimeout(() => setCopied(false), 1800);
    } catch {
      setCopied(false);
    }
  };

  return (
    <div className="service-view">
      <section className="service-hero">
        <div className="service-hero-copy">
          <span className="eyebrow">FOUR-PARTY VALUE NETWORK</span>
          <h2>一套平台，连接养护、车企、科研与采集伙伴</h2>
          <p>
            以路政按公里订阅为基本盘，向车企提供云端识别接口与算法授权，
            向科研院所提供经授权的脱敏数据，并通过设备减免连接社会采集车辆。
          </p>
          <div className="service-hero-points">
            <span><Check size={14} /> 不把未签约意向计入收入</span>
            <span><Check size={14} /> 原始数据不转售</span>
            <span><Check size={14} /> 工单闭环可审计</span>
          </div>
        </div>
        <div className="value-network" aria-label="四方价值网络">
          <span className="value-core"><Building2 size={24} /><b>路鉴智巡</b><small>病害数据与工单</small></span>
          <span className="value-node government"><Landmark size={16} /> 路政</span>
          <span className="value-node automaker"><CarFront size={16} /> 车企</span>
          <span className="value-node research"><GraduationCap size={16} /> 科研</span>
          <span className="value-node partner"><Handshake size={16} /> 采集伙伴</span>
          <i className="value-line line-one" />
          <i className="value-line line-two" />
          <i className="value-line line-three" />
          <i className="value-line line-four" />
        </div>
      </section>

      <section className="program-grid">
        {programs.map((program) => {
          const Icon = program.icon;
          return (
            <article className={`program-card ${program.tone}`} key={program.id}>
              <div className="program-top">
                <span className="program-icon"><Icon size={19} /></span>
                <span className="program-status">{program.status}</span>
              </div>
              <span>{program.audience}</span>
              <h3>{program.title}</h3>
              <p>{program.detail}</p>
              <div className="program-entry">
                <span>{program.entry}</span>
                <ArrowUpRight size={15} />
              </div>
            </article>
          );
        })}
      </section>

      <div className="service-detail-grid">
        <section className="api-panel">
          <div className="panel-heading">
            <div>
              <span className="eyebrow">PARTNER API / V1</span>
              <h2>车企与平台接入</h2>
            </div>
            <button type="button" className="text-button" onClick={copyExample}>
              {copied ? <Check size={14} /> : <Copy size={14} />}
              {copied ? "已复制" : "复制示例"}
            </button>
          </div>
          <div className="api-endpoint-row">
            <span><Code2 size={15} /> 检测结果写入</span>
            <code>POST /api/v1/detections</code>
            <span className="api-state"><i /> 接口演示可用</span>
          </div>
          <pre className="api-code"><code>{apiExample}</code></pre>
          <div className="api-contract">
            <div><FileJson size={17} /><span>写入契约</span><strong>terminalId / roadCode / typeCode / confidence / position</strong></div>
            <div><Database size={17} /><span>读取接口</span><strong>GET /api/v1/road-defects?roadCode=G312</strong></div>
          </div>
        </section>

        <section className="governance-panel">
          <div className="panel-heading">
            <div>
              <span className="eyebrow">DATA GOVERNANCE</span>
              <h2>数据授权与合规</h2>
            </div>
            <ShieldCheck size={18} />
          </div>
          <div className="governance-list">
            {governanceItems.map((item) => {
              const Icon = item.icon;
              return (
                <div key={item.title}>
                  <span><Icon size={16} /></span>
                  <div>
                    <strong>{item.title}</strong>
                    <p>{item.detail}</p>
                  </div>
                </div>
              );
            })}
          </div>
        </section>
      </div>

      <section className="service-readiness-panel">
        <div className="panel-heading">
          <div>
            <span className="eyebrow">COOPERATION PIPELINE</span>
            <h2>合作准备状态</h2>
          </div>
          <span className="panel-meta">未签约事项均标记为准备状态</span>
        </div>
        <div className="readiness-list">
          <div>
            <span className="readiness-icon"><Landmark size={18} /></span>
            <div><strong>陕西县域公路试点</strong><small>2 至 3 个路段 · 单段 200 至 500 km · 90 天</small></div>
            <span className="readiness-badge prep">试点筹备</span>
          </div>
          <div>
            <span className="readiness-icon"><CarFront size={18} /></span>
            <div><strong>车企云端识别接口</strong><small>输出病害类别、位置与采集时间 · 技术验证方案</small></div>
            <span className="readiness-badge plan">方案就绪</span>
          </div>
          <div>
            <span className="readiness-icon"><GraduationCap size={18} /></span>
            <div><strong>科研脱敏数据</strong><small>标准化字段 · 合同限定用途 · 禁止再识别与再分发</small></div>
            <span className="readiness-badge plan">授权模板</span>
          </div>
        </div>
      </section>
    </div>
  );
}

export default ServiceView;
