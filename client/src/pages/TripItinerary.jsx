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
  Sparkles,
} from "lucide-react";
import { db } from "../firebase";
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
import { StoriesModal } from "../components/StoriesModal";
import GeneratePDF from "../components/GeneratePDF";

export default function TripItinerary() {
  const { tripId } = useParams();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [trip, setTrip] = useState(null);
  const [itineraries, setItineraries] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showStories, setShowStories] = useState(false);
  const [stories, setStories] = useState([]);

  useEffect(() => {
    if (tripId) loadTripData();
    else loadMockData();
  }, [tripId]);

  async function loadTripData() {
    try {
      const tripRef = doc(db, "trips", tripId);
      const tripSnap = await getDoc(tripRef);
      if (!tripSnap.exists()) return loadMockData();

      const tripData = tripSnap.data();
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
      loadMockStories();
    } catch (error) {
      console.error("Error loading trip:", error);
      loadMockData();
    } finally {
      setLoading(false);
    }
  }

  function loadMockData() {
    const mockTrip = {
      id: "mock-1",
      user_id: user?.uid || "",
      title: "Gujarat Heritage Tour",
      destination: "Gujarat",
      duration_days: 7,
      budget: 22000,
    };

    const mockItineraries = [
      {
        id: "1",
        trip_id: "mock-1",
        day_number: 1,
        activities: [
          {
            time: "09:00",
            title: "Arrival at Dwarkadhish",
            location: "Dwarka International Airport",
            cost: 2600,
            description:
              "Arrive at Dwarka and check into your accommodation.",
            type: "morning",
          },
          {
            time: "14:00",
            title: "Visit Dwarkadhish Temple",
            location: "Dwarkadhish Temple",
            cost: 500,
            description: "Explore the temple and the view of Arabian Sea.",
            type: "afternoon",
          },
        ],
      },
    ];

    setTrip(mockTrip);
    setItineraries(mockItineraries);
    loadMockStories();
    setLoading(false);
  }

  function loadMockStories() {
    setStories([
      {
        id: "1",
        title: "Dwarkadhish Temple",
        description: "A spiritual journey at the ancient temple.",
      },
    ]);
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

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center text-gray-600">
        Loading itinerary...
      </div>
    );
  }

  const columns = ["Day", "Time", "Title", "Location", "Cost"];
  const pdfData = itineraries.flatMap((day) =>
    day.activities.map((a) => ({
      Day: day.day_number,
      Time: a.time,
      Title: a.title,
      Location: a.location,
      Cost: a.cost,
    }))
  );

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
      <nav className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center gap-3">
          <button
            onClick={() => navigate("/")}
            className="p-2 hover:bg-gray-100 rounded-lg"
          >
            <ArrowLeft className="w-5 h-5 text-gray-600" />
          </button>
          <Plane className="w-6 h-6 text-blue-600" />
          <h1 className="text-xl font-bold text-gray-900">
            Trip Itinerary - {trip?.destination}
          </h1>
        </div>
      </nav>

      <div className="max-w-5xl mx-auto px-6 py-6 flex gap-4">
        <GeneratePDF
          title="Trip Itinerary Report"
          columns={columns}
          data={pdfData}
          filename="trip_itinerary"
        />
        <button
          onClick={() => setShowStories(true)}
          className="flex items-center gap-2 bg-purple-600 text-white px-6 py-3 rounded-xl font-semibold hover:bg-purple-700 transition"
        >
          <Sparkles className="w-5 h-5" />
          View Stories
        </button>
      </div>

      <div className="max-w-4xl mx-auto p-6">
        {itineraries.map((day) => (
          <div
            key={day.id}
            className="bg-white shadow rounded-2xl p-6 mb-6 border border-gray-100"
          >
            <h2 className="text-lg font-semibold text-gray-800 mb-4">
              Day {day.day_number}
            </h2>
            {day.activities.map((activity, i) => (
              <div
                key={i}
                className="flex items-start gap-3 border-l-4 border-blue-500 pl-4 mb-3"
              >
                <div className="mt-1">{getTimeIcon(activity.type)}</div>
                <div>
                  <h3 className="font-semibold">
                    {activity.time} — {activity.title}
                  </h3>
                  <p className="text-sm text-gray-600">{activity.description}</p>
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
        ))}
      </div>

      {showStories && (
        <StoriesModal stories={stories} onClose={() => setShowStories(false)} />
      )}
    </div>
  );
}
