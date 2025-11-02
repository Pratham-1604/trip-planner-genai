import { GoogleMap, Marker, useLoadScript } from "@react-google-maps/api";

export function GoogleMapComponent({ latitude, longitude, title }) {
  const { isLoaded, loadError } = useLoadScript({
    googleMapsApiKey: import.meta.env.VITE_GOOGLE_MAPS_API_KEY || "",
  });

  const center = { lat: latitude, lng: longitude };

  if (loadError)
    return <div className="p-4 text-red-500">Error loading map</div>;
  if (!isLoaded) return <div className="p-4 text-gray-500">Loading map...</div>;

  return (
    <div className="w-full h-full">
      <GoogleMap
        mapContainerStyle={{ width: "100%", height: "100%" }}
        center={center}
        zoom={15}
      >
        <Marker position={center} title={title} />
      </GoogleMap>
    </div>
  );
}
