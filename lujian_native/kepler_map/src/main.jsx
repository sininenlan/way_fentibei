import React, { useEffect, useRef, useState } from "react";
import { createRoot } from "react-dom/client";
import { Provider, useDispatch } from "react-redux";
import { applyMiddleware, combineReducers, createStore } from "redux";
import { addDataToMap } from "@kepler.gl/actions";
import KeplerGl from "@kepler.gl/components";
import { processGeojson } from "@kepler.gl/processors";
import keplerGlReducer, {
  enhanceReduxMiddleware,
} from "@kepler.gl/reducers";

import defectData from "../public/road_defects.geojson";
import mapStyle from "../public/kepler-style.json";
import "./styles.css";

const reducers = combineReducers({
  keplerGl: keplerGlReducer,
});
const middlewares = enhanceReduxMiddleware([]);
const store = createStore(reducers, applyMiddleware(...middlewares));
window.__lujianStore = store;

const visConfig = {
  version: "v1",
  config: {
    mapState: {
      latitude: 34.2725,
      longitude: 109.0674,
      zoom: 12.8,
      bearing: 0,
      pitch: 42,
      dragRotate: true,
      isSplit: false,
    },
    mapStyle: {
      styleType: "lujian-light",
      topLayerGroups: {},
      visibleLayerGroups: {},
      threeDBuildingColor: [40, 48, 45],
      mapStyles: {},
    },
    visState: {
      filters: [
        {
          id: "severity-filter",
          dataId: "road-defects",
          name: "severity_group",
          type: "multiSelect",
          value: ["高风险", "中风险", "低风险"],
          enlarged: true,
          plotType: "histogram",
          yAxis: null,
          speed: 1,
          view: "side",
        },
        {
          id: "road-filter",
          dataId: "road-defects",
          name: "road_code",
          type: "multiSelect",
          value: [
            "G312-K1082+350",
            "XA-CB-007-K3+260",
            "XA-BY-002-K7+120",
            "XA-BY-002-K8+050",
            "S107-K044+930",
            "G312-K1081+860",
            "S107-K045+780",
            "XA-NH-011-K2+640",
          ],
          enlarged: false,
          plotType: "histogram",
          yAxis: null,
          speed: 1,
          view: "side",
        },
      ],
      layers: [
        {
          id: "road-defects",
          type: "point",
          config: {
            dataId: "road-defects",
            label: "路面病害",
            isVisible: true,
            colorField: { name: "severity_color", type: "string" },
            colorScale: "ordinal",
            color: [212, 79, 53],
            columns: { lat: "latitude", lng: "longitude", altitude: null },
            sizeField: { name: "terminal_count", type: "integer" },
            sizeScale: "linear",
            sizeRange: [10, 55],
            isAggregated: false,
            visConfig: {
              radius: 30,
              fixedRadius: false,
              opacity: 0.9,
              outline: true,
              thickness: 2,
              filled: true,
              billboard: false,
              radiusRange: [10, 55],
              colorRange: {
                name: "Lujian Risk",
                type: "qualitative",
                category: "Custom",
                colors: ["#D44F35", "#D58B31", "#2F7A6C"],
              },
            },
          },
        },
      ],
      interactionConfig: {
        tooltip: {
          fieldsToShow: {
            "road-defects": [
              { name: "road_code", format: null },
              { name: "type_name", format: null },
              { name: "severity_group", format: null },
              { name: "terminal_count", format: null },
              { name: "confidence", format: null },
              { name: "status_name", format: null },
            ],
            "road-segments": [
              { name: "road_name", format: null },
              { name: "length_km", format: null },
            ],
          },
          enabled: true,
          compareMode: false,
          compareType: "absolute",
        },
        brush: { enabled: false, size: 0.5 },
        geocoder: { enabled: false },
        coordinate: { enabled: true },
      },
      layerBlending: "normal",
      splitMaps: [],
      animationConfig: {
        currentTime: null,
        speed: 1,
      },
    },
  },
};

function MapWorkspace() {
  const dispatch = useDispatch();
  const containerRef = useRef(null);
  const [size, setSize] = useState({ width: 1280, height: 760 });
  const [initialized, setInitialized] = useState(false);

  useEffect(() => {
    if (!containerRef.current) return undefined;
    const observer = new ResizeObserver(([entry]) => {
      const { width, height } = entry.contentRect;
      setSize({ width: Math.max(width, 640), height: Math.max(height, 520) });
    });
    observer.observe(containerRef.current);
    return () => observer.disconnect();
  }, []);

  useEffect(() => {
    if (!initialized) return;
    dispatch(
      addDataToMap({
        datasets: {
          info: {
            id: "road-defects",
            label: "路面病害",
            color: [212, 79, 53],
          },
          data: processGeojson(defectData),
        },
        options: {
          centerMap: true,
          readOnly: false,
          keepExistingConfig: false,
        },
        config: visConfig,
      }),
    );
  }, [dispatch, initialized]);

  return (
    <div className="map-stage" ref={containerRef}>
      <div className="base-map" />
      <KeplerGl
        id="lujian"
        mapboxApiAccessToken=""
        mapStyles={[{ id: "lujian-light", style: mapStyle }]}
        mapStylesReplaceDefault
        width={size.width}
        height={size.height}
        appName="路鉴智巡"
        onKeplerGlInitialized={() => setInitialized(true)}
        theme={{
          sidePanelBg: "#17201e",
          sidePanelTextColor: "#eef4f0",
          panelBackgroundColor: "#202d29",
          panelBackgroundColorHover: "#283834",
          panelTextColor: "#dce6e1",
          subtextColor: "#8ea097",
          primaryBtnBgd: "#2f7a6c",
          secondaryBtnBgd: "#26332f",
          secondaryBtnActBgd: "#35463f",
          mapPanelBackgroundColor: "#17201e",
          mapPanelHeaderBackgroundColor: "#202d29",
        }}
      />
    </div>
  );
}

function Header() {
  return (
    <header className="topbar">
      <div className="brand">
        <span className="brand-mark">路</span>
        <div>
          <strong>路鉴智巡 · Kepler 地图分析</strong>
          <span>ROAD DEFECT GEOSPATIAL WORKSPACE</span>
        </div>
      </div>
      <div className="stats">
        <div><strong>8</strong><span>病害点位</span></div>
        <div><strong>3</strong><span>道路路段</span></div>
        <div><strong>4</strong><span>高风险</span></div>
        <div className="live"><i /> KEPLER.GL 3.2.5</div>
      </div>
    </header>
  );
}

function App() {
  return (
    <Provider store={store}>
      <div className="app-shell">
        <Header />
        <MapWorkspace />
        <aside className="map-note">
          <span>数据口径</span>
          <strong>点位 = 病害空间位置</strong>
          <p>道路编号、风险等级、病害类型与终端频次可在 Kepler 工具提示中查看。</p>
        </aside>
      </div>
    </Provider>
  );
}

createRoot(document.getElementById("root")).render(<App />);
