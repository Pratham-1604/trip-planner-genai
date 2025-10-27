import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import { ActivityDetail } from "./pages/ActivityDetail";
import { AIAssistant } from "./pages/AIAssistant";
import { AuthProvider } from "./contexts/AuthContext";

export default function App() {
  return (
    <Router>
      <AuthProvider>
        <div className="min-h-screen bg-gray-50">
          <Routes>
            {/* 🏠 Home route */}
            <Route
              path="/"
              element={
                <div className="p-10 text-center space-y-8">
                  <h1 className="text-4xl font-bold text-blue-700">
                    Welcome to GenAI Travel Planner ✈️
                  </h1>
                  <div className="flex justify-center gap-6">
                    <Link
                      to="/assistant"
                      className="bg-blue-600 text-white px-6 py-3 rounded-xl hover:bg-blue-700 transition"
                    >
                      Open AI Assistant
                    </Link>
                    <Link
                      to="/activity/1/0"
                      className="bg-green-600 text-white px-6 py-3 rounded-xl hover:bg-green-700 transition"
                    >
                      View Activity Detail
                    </Link>
                  </div>
                </div>
              }
            />

            {/* 🤖 AI Assistant */}
            <Route path="/assistant" element={<AIAssistant />} />

            {/* 📍 Activity Details */}
            <Route
              path="/activity/:itineraryId/:activityIndex"
              element={<ActivityDetail />}
            />
          </Routes>
        </div>
      </AuthProvider>
    </Router>
  );
}
