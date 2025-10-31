import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  Plane,
  Compass,
  MessageSquare,
  Bell,
  LogOut,
  Calendar,
  TrendingUp,
} from "lucide-react";
import { useAuth } from "../contexts/AuthContext";
import { db } from "../firebase";
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
        <div className="max-w-7xl mx-auto px-4 sm:px-6 py-3 flex flex-wrap justify-between items-center gap-3">
          {/* Logo */}
          <div className="flex items-center gap-3">
            <div className="bg-blue-600 p-2 rounded-xl">
              <Plane className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
            </div>
            <h1 className="text-lg sm:text-2xl font-bold text-gray-900">
              Trip Planner
            </h1>
          </div>

          {/* Right Section */}
          <div className="flex items-center gap-2 sm:gap-4 flex-wrap justify-end">
            <button
              onClick={() => navigate("/discovery")}
              className="text-gray-600 hover:text-gray-900 text-sm sm:text-base font-medium"
            >
              Discover
            </button>

            <button className="text-gray-600 hover:text-gray-900 text-sm sm:text-base font-medium">
              My Trips
            </button>
            <button className="p-2 hover:bg-gray-100 rounded-lg transition">
              <Bell className="w-5 h-5 text-gray-600" />
            </button>

            {/* Profile + Logout */}
            <div className="flex items-center gap-3 pl-2 sm:pl-3 border-l border-gray-200">
              <div className="hidden sm:block text-right">
                <p className="text-sm font-medium text-gray-900 truncate max-w-[100px]">
                  {profile?.full_name || "User"}
                </p>
                <p className="text-xs text-gray-500 truncate max-w-[100px]">
                  {profile?.email}
                </p>
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
      <div className="max-w-7xl mx-auto px-4 sm:px-6 py-8 sm:py-12">
        <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-2xl sm:rounded-3xl p-6 sm:p-12 mb-10 text-white shadow-xl">
          <div className="max-w-3xl">
            <h2 className="text-2xl sm:text-4xl font-bold mb-3 sm:mb-4">
              Welcome back, {profile?.full_name?.split(" ")[0] || "Traveler"}!
            </h2>
            <p className="text-sm sm:text-lg text-blue-100 mb-6 sm:mb-8">
              Ready to plan your next adventure? Let our AI assistant create the
              perfect itinerary tailored just for you.
            </p>
            <div className="flex flex-col sm:flex-row gap-3 sm:gap-4">
              <button
                onClick={() => navigate("/plan")}
                className="flex items-center justify-center gap-2 bg-white text-blue-600 px-5 sm:px-8 py-2.5 sm:py-4 rounded-xl font-semibold hover:bg-blue-50 transition shadow-md"
              >
                <Plane className="w-5 h-5" /> Plan New Trip
              </button>
              <button
                onClick={() => navigate("/assistant")}
                className="flex items-center justify-center gap-2 bg-blue-500 text-white px-5 sm:px-8 py-2.5 sm:py-4 rounded-xl font-semibold hover:bg-blue-400 transition"
              >
                <MessageSquare className="w-5 h-5" /> AI Assistant
              </button>
            </div>
          </div>
        </div>

        {/* Stats Section */}
        <div className="grid grid-cols-2 sm:grid-cols-2 md:grid-cols-3 gap-4 sm:gap-6 mb-12">
          {/* Total Trips */}
          <div className="bg-white rounded-xl p-4 sm:p-6 shadow-sm hover:shadow-md transition text-center">
            <div className="bg-blue-100 w-10 h-10 sm:w-14 sm:h-14 rounded-xl flex items-center justify-center mx-auto mb-3">
              <Calendar className="w-5 h-5 sm:w-7 sm:h-7 text-blue-600" />
            </div>
            <h3 className="text-lg sm:text-2xl font-bold text-gray-900">
              {trips.length}
            </h3>
            <p className="text-xs sm:text-sm text-gray-600 mt-1">
              Total Trips Planned
            </p>
          </div>

          {/* Confirmed Trips */}
          <div className="bg-white rounded-xl p-4 sm:p-6 shadow-sm hover:shadow-md transition text-center">
            <div className="bg-green-100 w-10 h-10 sm:w-14 sm:h-14 rounded-xl flex items-center justify-center mx-auto mb-3">
              <TrendingUp className="w-5 h-5 sm:w-7 sm:h-7 text-green-600" />
            </div>
            <h3 className="text-lg sm:text-2xl font-bold text-gray-900">
              {trips.filter((t) => t.status === "confirmed").length}
            </h3>
            <p className="text-xs sm:text-sm text-gray-600 mt-1">
              Confirmed Trips
            </p>
          </div>

          {/* Destinations */}
          <div className="bg-white rounded-xl p-4 sm:p-6 shadow-sm hover:shadow-md transition text-center col-span-2 md:col-span-1">
            <div className="bg-orange-100 w-10 h-10 sm:w-14 sm:h-14 rounded-xl flex items-center justify-center mx-auto mb-3">
              <Compass className="w-5 h-5 sm:w-7 sm:h-7 text-orange-600" />
            </div>
            <h3 className="text-lg sm:text-2xl font-bold text-gray-900">
              {new Set(trips.map((t) => t.destination)).size}
            </h3>
            <p className="text-xs sm:text-sm text-gray-600 mt-1">
              Destinations Explored
            </p>
          </div>
        </div>

        {/* Recent Trips */}
        <div className="flex flex-col sm:flex-row justify-between sm:items-center mb-6">
          <h3 className="text-lg sm:text-2xl font-bold text-gray-900">
            Recent Trips
          </h3>
          {trips.length > 0 && (
            <button className="text-blue-600 text-sm sm:text-base font-semibold hover:text-blue-700 transition mt-2 sm:mt-0">
              View All →
            </button>
          )}
        </div>

        {loading ? (
          <div className="text-center py-16 text-gray-500 animate-pulse">
            Loading your trips...
          </div>
        ) : trips.length === 0 ? (
          <div className="bg-white rounded-xl sm:rounded-2xl p-10 text-center shadow-sm">
            <div className="bg-gray-100 w-14 h-14 sm:w-20 sm:h-20 rounded-full flex items-center justify-center mx-auto mb-4">
              <Plane className="w-8 h-8 sm:w-10 sm:h-10 text-gray-400" />
            </div>
            <h4 className="text-lg sm:text-xl font-semibold text-gray-900 mb-2">
              No trips yet
            </h4>
            <p className="text-gray-600 mb-6 text-sm sm:text-base">
              Start planning your first adventure with our AI assistant
            </p>
            <button
              onClick={() => navigate("/plan")}
              className="bg-blue-600 text-white px-5 py-2.5 sm:px-6 sm:py-3 rounded-xl font-semibold hover:bg-blue-700 transition text-sm sm:text-base"
            >
              Plan Your First Trip
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 sm:gap-6">
            {trips.map((trip) => (
              <div
                key={trip.id}
                onClick={() => navigate(`/trip/${trip.id}`)}
                className="bg-white rounded-xl sm:rounded-2xl p-5 sm:p-6 shadow-sm hover:shadow-lg transition cursor-pointer border border-gray-100 group"
              >
                <div className="flex justify-between items-start mb-4">
                  <div className="min-w-0">
                    <h4 className="font-bold text-base sm:text-xl text-gray-900 mb-1 group-hover:text-blue-600 transition truncate">
                      {trip.destination}
                    </h4>
                    <p className="text-xs sm:text-sm text-gray-600">
                      {trip.duration_days} days trip
                    </p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm sm:text-lg font-bold text-green-600">
                      ₹{trip.budget?.toLocaleString()}
                    </p>
                    <p className="text-[10px] sm:text-xs text-gray-500">
                      Budget
                    </p>
                  </div>
                </div>

                <span
                  className={`px-3 py-1 rounded-full text-[10px] sm:text-xs font-medium ${
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
                    ? trip.status.charAt(0).toUpperCase() + trip.status.slice(1)
                    : "Planning"}
                </span>

                <p className="text-[11px] sm:text-sm text-gray-500 mt-2">
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
