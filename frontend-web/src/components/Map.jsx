import { MapContainer, Marker, Popup, TileLayer } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

const markerIcon = (emoji) =>
  L.divIcon({
    html: `<div style="font-size: 24px">${emoji}</div>`,
    className: 'leaflet-custom-icon',
    iconSize: [32, 32]
  });

const Map = ({ markers = [] }) => {
  return (
    <MapContainer center={[11.0168, 76.9558]} zoom={14} className="live-map">
      <TileLayer
        attribution='&copy; OpenStreetMap contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        className="map-tiles-dark"
      />
      {markers.map((marker) => (
        <Marker key={marker.id} position={[marker.lat, marker.lng]} icon={markerIcon(marker.icon)}>
          <Popup>{marker.popup}</Popup>
        </Marker>
      ))}
    </MapContainer>
  );
};

export default Map;
