import { Routes, Route, Navigate } from "react-router-dom";
import { useAuth } from "../contexts/AuthContext";

import Login from "../pages/Login";
import Signup from "../pages/Signup";
import Home from "../pages/Home";
import AIAssistant from "../pages/AIAssistant";
import TripItinerary from "../pages/TripItinerary";
import ActivityDetail from "../pages/ActivityDetail";
import Discovery from "../pages/Discovery";

// 🔒 ProtectedRoute — only accessible if logged in
function ProtectedRoute({ children }) {
  const { user, loading } = useAuth();

  // 🧪 Temporarily disable auth for testing
  return <>{children}</>;

  // ✅ Uncomment this when you want to restore auth checks
  /*
  if (loading) {
    return (
      <div className="min-h-screen bg-gray-100 flex items-center justify-center">
        <div className="text-gray-600">Loading...</div>
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/login" />;
  }

  return <>{children}</>;
  */
}

// 🌐 PublicRoute — redirect if user already logged in
function PublicRoute({ children }) {
  // 🧪 Skip auth for testing
  return <>{children}</>;

  // ✅ Uncomment this when re-enabling auth
  /*
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-100 flex items-center justify-center">
        <div className="text-gray-600">Loading...</div>
      </div>
    );
  }

  if (user) {
    return <Navigate to="/" />;
  }

  return <>{children}</>;
  */
}

export default function AppRoutes() {
  return (
    <Routes>
      {/* 🧭 Public Routes (Commented for testing) */}
      {/*
      <Route
        path="/login"
        element={
          <PublicRoute>
            <Login />
          </PublicRoute>
        }
      />
      <Route
        path="/signup"
        element={
          <PublicRoute>
            <Signup />
          </PublicRoute>
        }
      />
      */}

      {/* 🏠 Protected Routes (open for testing) */}
      <Route
        path="/"
        element={
          <ProtectedRoute>
            <Home />
          </ProtectedRoute>
        }
      />
      <Route
        path="/assistant"
        element={
          <ProtectedRoute>
            <AIAssistant />
          </ProtectedRoute>
        }
      />
      <Route
        path="/plan"
        element={
          <ProtectedRoute>
            <AIAssistant />
          </ProtectedRoute>
        }
      />
      <Route
        path="/trip/:tripId"
        element={
          <ProtectedRoute>
            <TripItinerary />
          </ProtectedRoute>
        }
      />

      <Route
        path="/discovery"
        element={
          <ProtectedRoute>
            <Discovery/>
          </ProtectedRoute>
        }
      />
      <Route
        path="/itinerary"
        element={
          <ProtectedRoute>
            <TripItinerary />
          </ProtectedRoute>
        }
      />
      <Route
        path="/activity/:itineraryId/:activityIndex"
        element={
          <ProtectedRoute>
            <ActivityDetail />
          </ProtectedRoute>
        }
      />

      {/* 🚫 Catch-all */}
      <Route path="*" element={<Navigate to="/" />} />
    </Routes>
  );
}
