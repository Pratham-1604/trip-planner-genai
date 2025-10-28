import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import {
  ArrowLeft,
  Save,
  Share2,
  Coffee,
  Sun,
  Moon,
  MapPin,
  IndianRupee,
  Plane,
} from "lucide-react";
import { db } from "../firebase"; // ✅ make sure firebase.js exports `db`
import { useAuth } from "../contexts/AuthContext";
import {
  doc,
  getDoc,
  collection,
  query,
  where,
  getDocs,
  orderBy,
} from "firebase/firestore";

export default function TripItinerary() {
  const { tripId } = useParams();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [trip, setTrip] = useState(null);
  const [itineraries, setItineraries] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (tripId) {
      loadTripData();
    } else {
      loadMockData();
    }
  }, [tripId]);

  // ✅ Fetch trip + itineraries from Firestore
  async function loadTripData() {
    try {
      // Fetch trip document
      const tripRef = doc(db, "trips", tripId);
      const tripSnap = await getDoc(tripRef);

      if (!tripSnap.exists()) {
        console.warn("Trip not found, loading mock data...");
        return loadMockData();
      }

      const tripData = tripSnap.data();

      // Fetch related itineraries ordered by day_number
      const itinerariesRef = collection(db, "itineraries");
      const q = query(
        itinerariesRef,
        where("trip_id", "==", tripId),
        orderBy("day_number", "asc")
      );
      const itinerarySnap = await getDocs(q);

      const itineraryData = itinerarySnap.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      setTrip({ id: tripSnap.id, ...tripData });
      setItineraries(itineraryData || []);
    } catch (error) {
      console.error("Error loading trip:", error);
      loadMockData();
    } finally {
      setLoading(false);
    }
  }

  // ✅ Fallback: mock data
  function loadMockData() {
    const mockTrip = {
      id: "mock-1",
      user_id: user?.uid || "",
      title: "Gujarat Heritage Tour",
      destination: "Gujarat",
      duration_days: 7,
      budget: 22000,
      start_date: null,
      end_date: null,
      status: "planning",
      preferences: {},
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    const mockItineraries = [
      {
        id: "1",
        trip_id: "mock-1",
        day_number: 1,
        date: null,
        daily_budget: 3500,
        activities: [
          {
            time: "09:00",
            title: "Arrival at Dwarkadhish",
            description:
              "Arrive at Dwarkadhish (Dwarka) International Airport...",
            location: "Dwarka International Airport",
            cost: 2600,
            type: "morning",
          },
          {
            time: "14:00",
            title: "Visit Dwarkadhish Temple",
            description: "Visit the majestic Dwarkadhish Mandir...",
            location: "Dwarkadhish Temple",
            cost: 500,
            type: "afternoon",
          },
        ],
        created_at: new Date().toISOString(),
      },
    ];

    setTrip(mockTrip);
    setItineraries(mockItineraries);
    setLoading(false);
  }

  function getTimeIcon(type) {
    switch (type) {
      case "morning":
        return <Sun className="w-4 h-4" />;
      case "afternoon":
        return <Coffee className="w-4 h-4" />;
      case "evening":
      case "night":
        return <Moon className="w-4 h-4" />;
      default:
        return <MapPin className="w-4 h-4" />;
    }
  }

  async function handleSaveItinerary() {
    alert("Itinerary saved successfully!");
  }

  function handleShareItinerary() {
    alert("Share functionality coming soon!");
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-gray-600">Loading itinerary...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
      {/* 🔹 Navbar */}
      <nav className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center gap-4">
            <button
              onClick={() => navigate("/")}
              className="p-2 hover:bg-gray-100 rounded-lg transition"
            >
              <ArrowLeft className="w-5 h-5 text-gray-600" />
            </button>
            <div className="flex items-center gap-3">
              <div className="bg-blue-600 p-2 rounded-xl">
                <Plane className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">
                  Trip Itinerary
                </h1>
                <p className="text-sm text-gray-600">
                  {trip?.destination || "Your Journey"}
                </p>
              </div>
            </div>
          </div>
        </div>
      </nav>

      {/* 🗓️ Render Itinerary */}
      <div className="max-w-4xl mx-auto p-6">
        {itineraries.map((day) => (
          <div
            key={day.id}
            className="bg-white shadow rounded-2xl p-6 mb-6 border border-gray-100"
          >
            <h2 className="text-lg font-semibold text-gray-800 mb-4">
              Day {day.day_number}
            </h2>
            <div className="space-y-4">
              {day.activities.map((activity, idx) => (
                <div
                  key={idx}
                  className="flex items-start gap-3 border-l-4 border-blue-500 pl-4"
                >
                  <div className="mt-1">{getTimeIcon(activity.type)}</div>
                  <div>
                    <h3 className="font-semibold text-gray-900">
                      {activity.time} — {activity.title}
                    </h3>
                    <p className="text-sm text-gray-600">
                      {activity.description}
                    </p>
                    <p className="text-sm text-gray-500 flex items-center gap-1">
                      <MapPin className="w-3 h-3" /> {activity.location}
                    </p>
                    <p className="text-sm text-gray-700 flex items-center gap-1">
                      <IndianRupee className="w-3 h-3" /> {activity.cost}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
