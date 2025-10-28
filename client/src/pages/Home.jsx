import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  Plane,
  Hotel,
  Car,
  Compass,
  MessageSquare,
  Bell,
  LogOut,
  Calendar,
  TrendingUp,
} from "lucide-react";
import { useAuth } from "../contexts/AuthContext";
import { db } from "../firebase"; // ensure you export db from firebase.js
import {
  collection,
  query,
  where,
  orderBy,
  limit,
  getDocs,
} from "firebase/firestore";

export default function Home() {
  const { user, profile, signOut } = useAuth();
  const [trips, setTrips] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    if (user) loadTrips();
  }, [user]);

  async function loadTrips() {
    try {
      const tripsRef = collection(db, "trips");
      const q = query(
        tripsRef,
        where("user_id", "==", user.uid),
        orderBy("created_at", "desc"),
        limit(6)
      );

      const querySnapshot = await getDocs(q);
      const tripsData = querySnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      setTrips(tripsData);
    } catch (error) {
      console.error("Error loading trips:", error);
    } finally {
      setLoading(false);
    }
  }

  async function handleSignOut() {
    await signOut();
    navigate("/login");
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
      {/* Navbar */}
      <nav className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-6 py-4 flex justify-between items-center">
          <div className="flex items-center gap-3">
            <div className="bg-blue-600 p-2 rounded-xl">
              <Plane className="w-6 h-6 text-white" />
            </div>
            <h1 className="text-2xl font-bold text-gray-900">Trip Planner</h1>
          </div>

          <div className="flex items-center gap-4">
            <button className="text-gray-600 hover:text-gray-900 font-medium">
              Discover
            </button>
            <button className="text-gray-600 hover:text-gray-900 font-medium">
              My Trips
            </button>
            <button className="p-2 hover:bg-gray-100 rounded-lg transition">
              <Bell className="w-5 h-5 text-gray-600" />
            </button>
            <div className="flex items-center gap-3 pl-3 border-l border-gray-200">
              <div className="text-right">
                <p className="text-sm font-medium text-gray-900">
                  {profile?.full_name || "User"}
                </p>
                <p className="text-xs text-gray-500">{profile?.email}</p>
              </div>
              <button
                onClick={handleSignOut}
                className="p-2 hover:bg-gray-100 rounded-lg transition"
                title="Sign Out"
              >
                <LogOut className="w-5 h-5 text-gray-600" />
              </button>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <div className="max-w-7xl mx-auto px-6 py-12">
        <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-3xl p-12 mb-12 text-white shadow-xl">
          <div className="max-w-3xl">
            <h2 className="text-4xl font-bold mb-4">
              Welcome back, {profile?.full_name?.split(" ")[0] || "Traveler"}!
            </h2>
            <p className="text-xl text-blue-100 mb-8">
              Ready to plan your next adventure? Let our AI assistant create the
              perfect itinerary tailored just for you.
            </p>
            <div className="flex gap-4">
              <button
                onClick={() => navigate("/plan")}
                className="flex items-center gap-2 bg-white text-blue-600 px-8 py-4 rounded-xl font-semibold hover:bg-blue-50 transition shadow-lg"
              >
                <Plane className="w-5 h-5" /> Plan New Trip
              </button>
              <button
                onClick={() => navigate("/assistant")}
                className="flex items-center gap-2 bg-blue-500 text-white px-8 py-4 rounded-xl font-semibold hover:bg-blue-400 transition"
              >
                <MessageSquare className="w-5 h-5" /> AI Assistant
              </button>
            </div>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-12">
          <div className="bg-white rounded-2xl p-8 shadow-sm hover:shadow-md transition">
            <div className="bg-blue-100 w-16 h-16 rounded-2xl flex items-center justify-center mb-6">
              <Calendar className="w-8 h-8 text-blue-600" />
            </div>
            <h3 className="text-2xl font-bold text-gray-900 mb-2">
              {trips.length}
            </h3>
            <p className="text-gray-600">Total Trips Planned</p>
          </div>

          <div className="bg-white rounded-2xl p-8 shadow-sm hover:shadow-md transition">
            <div className="bg-green-100 w-16 h-16 rounded-2xl flex items-center justify-center mb-6">
              <TrendingUp className="w-8 h-8 text-green-600" />
            </div>
            <h3 className="text-2xl font-bold text-gray-900 mb-2">
              {trips.filter((t) => t.status === "confirmed").length}
            </h3>
            <p className="text-gray-600">Confirmed Trips</p>
          </div>

          <div className="bg-white rounded-2xl p-8 shadow-sm hover:shadow-md transition">
            <div className="bg-orange-100 w-16 h-16 rounded-2xl flex items-center justify-center mb-6">
              <Compass className="w-8 h-8 text-orange-600" />
            </div>
            <h3 className="text-2xl font-bold text-gray-900 mb-2">
              {new Set(trips.map((t) => t.destination)).size}
            </h3>
            <p className="text-gray-600">Destinations Explored</p>
          </div>
        </div>

        {/* Recent Trips */}
        <div className="flex justify-between items-center mb-6">
          <h3 className="text-2xl font-bold text-gray-900">Recent Trips</h3>
          {trips.length > 0 && (
            <button className="text-blue-600 font-semibold hover:text-blue-700 transition">
              View All →
            </button>
          )}
        </div>

        {loading ? (
          <div className="text-center py-20 text-gray-500">
            <div className="animate-pulse">Loading your trips...</div>
          </div>
        ) : trips.length === 0 ? (
          <div className="bg-white rounded-2xl p-16 text-center shadow-sm">
            <div className="bg-gray-100 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-4">
              <Plane className="w-10 h-10 text-gray-400" />
            </div>
            <h4 className="text-xl font-semibold text-gray-900 mb-2">
              No trips yet
            </h4>
            <p className="text-gray-600 mb-6">
              Start planning your first adventure with our AI assistant
            </p>
            <button
              onClick={() => navigate("/plan")}
              className="bg-blue-600 text-white px-6 py-3 rounded-xl font-semibold hover:bg-blue-700 transition"
            >
              Plan Your First Trip
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {trips.map((trip) => (
              <div
                key={trip.id}
                onClick={() => navigate(`/trip/${trip.id}`)}
                className="bg-white rounded-2xl p-6 shadow-sm hover:shadow-xl transition cursor-pointer border border-gray-100 group"
              >
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <h4 className="font-bold text-xl text-gray-900 mb-1 group-hover:text-blue-600 transition">
                      {trip.destination}
                    </h4>
                    <p className="text-sm text-gray-600">
                      {trip.duration_days} days trip
                    </p>
                  </div>
                  <div className="text-right">
                    <p className="text-lg font-bold text-green-600">
                      ₹{trip.budget?.toLocaleString()}
                    </p>
                    <p className="text-xs text-gray-500">Budget</p>
                  </div>
                </div>
                <div className="flex items-center gap-2 mb-4">
                  <span
                    className={`px-3 py-1 rounded-full text-xs font-medium ${
                      trip.status === "confirmed"
                        ? "bg-green-100 text-green-700"
                        : trip.status === "planning"
                        ? "bg-blue-100 text-blue-700"
                        : trip.status === "completed"
                        ? "bg-gray-100 text-gray-700"
                        : "bg-yellow-100 text-yellow-700"
                    }`}
                  >
                    {trip.status
                      ? trip.status.charAt(0).toUpperCase() +
                        trip.status.slice(1)
                      : "Planning"}
                  </span>
                </div>
                <p className="text-sm text-gray-500">
                  Created{" "}
                  {trip.created_at
                    ? new Date(
                        trip.created_at.seconds * 1000
                      ).toLocaleDateString()
                    : ""}
                </p>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
