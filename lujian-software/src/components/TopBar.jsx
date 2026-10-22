import {
  Bell,
  ChevronDown,
  HardHat,
  LayoutDashboard,
  RadioTower,
  Route,
} from "lucide-react";

export default function TopBar({ role, onRoleChange }) {
  return (
    <header className="topbar">
      <div className="brand-lockup">
        <span className="brand-mark"><Route size={20} strokeWidth={2.2} /></span>
        <span className="brand-copy">
          <strong>路鉴智巡</strong>
          <small>CROWDSOURCED ROAD CARE</small>
        </span>
      </div>

      <nav className="role-switch" aria-label="工作界面切换">
        <button
          type="button"
          className={role === "worker" ? "active" : ""}
          onClick={() => onRoleChange("worker")}
        >
          <HardHat size={16} />
          工人作业
        </button>
        <button
          type="button"
          className={role === "admin" ? "active" : ""}
          onClick={() => onRoleChange("admin")}
        >
          <LayoutDashboard size={16} />
          数字孪生
        </button>
      </nav>

      <div className="topbar-actions">
        <span className="model-chip">
          <RadioTower size={14} />
          众包采集 · YOLOv8
          <i className="live-dot" />
        </span>
        <button type="button" className="icon-button notification-button" aria-label="通知">
          <Bell size={18} />
          <span className="notification-dot" />
        </button>
        <button type="button" className="user-menu">
          <span className="avatar">{role === "worker" ? "王" : "值"}</span>
          <span className="user-menu-copy">
            <strong>{role === "worker" ? "王磊" : "值班调度"}</strong>
            <small>{role === "worker" ? "城东养护一班" : "路网管理中心"}</small>
          </span>
          <ChevronDown size={15} />
        </button>
      </div>
    </header>
  );
}
