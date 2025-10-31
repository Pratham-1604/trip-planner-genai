// src/pages/Discovery.jsx
import React, { useState } from "react";
import tripData from "./../tripIternary.json";
import TripCard from "../components/TripCard";
import TripModal from "../components/TripModal";

const Discovery = () => {
  const [selectedTrip, setSelectedTrip] = useState(null);

  return (
    <div className="p-6 bg-gray-50 min-h-screen">
      <h1 className="text-2xl font-bold mb-6">Discover Amazing Trips</h1>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        {tripData.trips.map((trip) => (
          <TripCard key={trip.id} trip={trip} onClick={setSelectedTrip} />
        ))}
      </div>

      {selectedTrip && (
        <TripModal trip={selectedTrip} onClose={() => setSelectedTrip(null)} />
      )}
    </div>
  );
};

export default Discovery;
