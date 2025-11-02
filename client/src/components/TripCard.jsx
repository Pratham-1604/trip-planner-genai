// src/components/TripCard.jsx
import React from "react";

const TripCard = ({ trip, onClick }) => {
  return (
    <div
      className="bg-white rounded-xl shadow-md p-4 cursor-pointer hover:shadow-lg transition"
      onClick={() => onClick(trip)}
    >
      <h3 className="text-lg font-semibold mb-1">{trip.tripTitle}</h3>
      <p className="text-gray-500 text-sm">{trip.destination}</p>
      <p className="text-gray-600 text-sm">{trip.duration}</p>
      <p className="text-gray-600 text-xs">
        {trip.startDate} - {trip.endDate}
      </p>
      <p className="text-gray-800 font-medium mt-2">{trip.totalCost}</p>
    </div>
  );
};

export default TripCard;
