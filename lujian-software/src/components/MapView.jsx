import { CircleMarker, MapContainer, Popup, TileLayer, Tooltip } from "react-leaflet";
import { severityMeta } from "../lib/format";

const severityColors = {
  high: "#d44f35",
  medium: "#d88a2d",
  low: "#2f7a6c",
};

export default function MapView({
  defects,
  selectedDefect,
  onSelect,
  className = "",
  compact = false,
}) {
  return (
    <div className={`map-shell ${className}`}>
      <MapContainer
        center={[34.2742, 109.0678]}
        zoom={compact ? 13 : 14}
        dragging
        touchZoom
        scrollWheelZoom
        doubleClickZoom
        boxZoom
        keyboard
        className="leaflet-map"
        zoomControl={!compact}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          maxZoom={19}
        />
        {defects.map((defect) => {
          const active = selectedDefect?.id === defect.id;
          const color = severityColors[defect.severity] || severityColors.low;
          return (
            <CircleMarker
              key={defect.id}
              center={[defect.lat, defect.lng]}
              radius={active ? 13 : 7 + Math.min(defect.terminalCount, 7) * 0.7}
              pathOptions={{
                color: active ? "#17201e" : "#ffffff",
                weight: active ? 3 : 2,
                fillColor: color,
                fillOpacity: 0.94,
              }}
              eventHandlers={{ click: () => onSelect?.(defect) }}
            >
              <Tooltip direction="top" offset={[0, -8]} opacity={1}>
                <div className="map-tooltip">
                  <strong>{defect.type}</strong>
                  <span>{defect.roadCode}</span>
                  <span>{defect.terminalCount} 个终端捕获</span>
                </div>
              </Tooltip>
              <Popup>
                <div className="map-popup">
                  <div className={`severity-dot ${severityMeta[defect.severity]?.tone}`} />
                  <strong>{defect.type}</strong>
                  <span>{defect.roadName}</span>
                  <span>{defect.roadCode} · {defect.terminalCount} 个终端</span>
                  <button type="button" onClick={() => onSelect?.(defect)}>
                    查看病害
                  </button>
                </div>
              </Popup>
            </CircleMarker>
          );
        })}
      </MapContainer>
      <div className="map-legend">
        <span><i className="legend-dot high" />高风险</span>
        <span><i className="legend-dot medium" />中风险</span>
        <span><i className="legend-dot low" />低风险</span>
      </div>
      <div className="map-source">OSM / Leaflet</div>
    </div>
  );
}
