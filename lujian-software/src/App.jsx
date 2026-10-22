import { useCallback, useEffect, useState } from "react";
import { AlertCircle, CheckCircle2, LoaderCircle, Route } from "lucide-react";
import { api } from "./api";
import TopBar from "./components/TopBar";
import WorkerView from "./components/WorkerView";
import AdminView from "./components/AdminView";

function AppLoading() {
  return (
    <div className="app-loading">
      <div className="loading-mark">
        <Route size={27} />
      </div>
      <strong>路鉴智巡</strong>
      <span><LoaderCircle size={15} className="spin" /> 正在连接道路数字孪生</span>
    </div>
  );
}

function AppError({ message, onRetry }) {
  return (
    <div className="app-error">
      <span className="error-mark"><AlertCircle size={25} /></span>
      <h1>数据服务暂时不可用</h1>
      <p>{message}</p>
      <button type="button" className="primary-button" onClick={onRetry}>重新连接</button>
      <code>npm run dev</code>
    </div>
  );
}

function Toast({ toast }) {
  if (!toast) return null;
  const Icon = toast.type === "error" ? AlertCircle : CheckCircle2;
  return (
    <div className={`toast ${toast.type || "success"}`} role="status">
      <Icon size={17} />
      <span>{toast.message}</span>
    </div>
  );
}

export default function App() {
  const [store, setStore] = useState(null);
  const [role, setRole] = useState(() => {
    const requested = new URLSearchParams(window.location.search).get("role");
    return requested === "admin" ? "admin" : "worker";
  });
  const [selectedId, setSelectedId] = useState("DEF-20261021-013");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [toast, setToast] = useState(null);

  const refresh = useCallback(async (initial = false) => {
    if (initial) setLoading(true);
    try {
      const payload = await api.bootstrap();
      setStore(payload);
      setError("");
    } catch (requestError) {
      setError(requestError.message || "无法读取后台数据");
    } finally {
      if (initial) setLoading(false);
    }
  }, []);

  useEffect(() => {
    refresh(true);
  }, [refresh]);

  useEffect(() => {
    if (!toast) return undefined;
    const timer = window.setTimeout(() => setToast(null), 3200);
    return () => window.clearTimeout(timer);
  }, [toast]);

  const showToast = useCallback((message, type = "success") => {
    setToast({ message, type });
  }, []);

  const selectedDefect = store?.defects.find((defect) => defect.id === selectedId) || null;
  const setSelectedDefect = useCallback((defect) => {
    if (defect?.id) setSelectedId(defect.id);
  }, []);

  if (loading) return <AppLoading />;
  if (!store) {
    return <AppError message={error} onRetry={() => refresh(true)} />;
  }

  return (
    <div className={`app role-${role}`}>
      <TopBar role={role} onRoleChange={setRole} />
      {role === "worker" ? (
        <WorkerView
          store={store}
          selectedDefect={selectedDefect}
          setSelectedDefect={setSelectedDefect}
          onRefresh={() => refresh(false)}
          showToast={showToast}
        />
      ) : (
        <AdminView
          store={store}
          selectedDefect={selectedDefect}
          setSelectedDefect={setSelectedDefect}
          onRefresh={() => refresh(false)}
          showToast={showToast}
        />
      )}
      <Toast toast={toast} />
    </div>
  );
}
