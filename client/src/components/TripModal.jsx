import { X } from "lucide-react";
import GeneratePDF from "./GeneratePDF";

const TripModal = ({ trip, onClose }) => {
  if (!trip) return null;

  // Prepare data for the PDF table
  const columns = ["Day", "Title", "Activities"];
  const data = (trip.itinerary || []).map((dayPlan) => ({
    Day: `Day ${dayPlan.day}`,
    Title: dayPlan.title,
    Activities: (dayPlan.activities || [])
      .map((a) => `${a.time || ""} — ${a.activity || ""}`)
      .join("\n"),
  }));

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 px-2">
      <div className="bg-white rounded-2xl w-full sm:w-11/12 md:w-3/4 lg:w-2/3 xl:w-1/2 p-5 md:p-8 relative max-h-[85vh] overflow-y-auto shadow-2xl">
        {/* Close Button */}
        <button
          className="absolute top-3 right-3 text-gray-500 hover:text-black transition"
          onClick={onClose}
        >
          <X size={22} />
        </button>

        {/* Title & Overview */}
        <h2 className="text-2xl md:text-3xl font-bold mb-2 text-gray-900">
          {trip.tripTitle}
        </h2>
        <p className="text-gray-600 text-sm md:text-base mb-4 leading-relaxed">
          {trip.overview}
        </p>

        {/* Itinerary Section */}
        {trip.itinerary?.length > 0 && (
          <>
            <h3 className="text-lg md:text-xl font-semibold mt-4 mb-2 text-gray-800">
              🗓️ Itinerary
            </h3>

            <div className="space-y-5">
              {trip.itinerary.map((dayPlan, index) => (
                <div
                  key={index}
                  className="border border-gray-200 rounded-xl p-4 bg-gray-50 shadow-sm"
                >
                  <h4 className="font-semibold text-gray-900 mb-2">
                    Day {dayPlan.day}: {dayPlan.title}
                  </h4>

                  <ul className="space-y-2">
                    {dayPlan.activities?.map((act, i) => (
                      <li
                        key={i}
                        className="bg-white border border-gray-100 rounded-lg p-3 shadow-sm"
                      >
                        <p className="font-medium text-gray-800">
                          ⏰ {act.time} — {act.activity}
                        </p>
                        <p className="text-sm text-gray-600">
                          {act.description}
                        </p>
                        <p className="text-xs text-gray-500 mt-1 italic">
                          📍 {act.location}
                        </p>
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            </div>
          </>
        )}

        {/* Budget Section */}
        {trip.budget && (
          <>
            <h3 className="text-lg md:text-xl font-semibold mt-6 mb-2 text-gray-800">
              💰 Budget
            </h3>
            <p className="text-gray-700 text-sm md:text-base">
              Estimated Cost:{" "}
              <span className="font-semibold">{trip.budget}</span>
            </p>
          </>
        )}

        {/* Additional Activities */}
        {trip.activities?.length > 0 && (
          <>
            <h3 className="text-lg md:text-xl font-semibold mt-6 mb-2 text-gray-800">
              🎯 Activities
            </h3>
            <ul className="list-disc list-inside space-y-1 text-gray-700 text-sm md:text-base">
              {trip.activities.map((activity, i) => (
                <li key={i}>{activity}</li>
              ))}
            </ul>
          </>
        )}

        {/* PDF Download */}
        <div className="flex justify-end mt-6">
          <GeneratePDF
            title={trip.tripTitle || "Trip Plan"}
            columns={columns}
            data={data}
            filename={trip.tripTitle || "Trip"}
          />
        </div>
      </div>
    </div>
  );
};

export default TripModal;
