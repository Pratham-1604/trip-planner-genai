import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import {
  ArrowLeft,
  ChevronLeft,
  ChevronRight,
  Save,
  Share2,
  MapPin,
  IndianRupee,
  Plane,
  Clock,
  FileDown,
} from "lucide-react";
import jsPDF from "jspdf";
import autoTable from "jspdf-autotable";

export default function ActivityDetail() {
  const { itineraryId, activityIndex } = useParams();
  const navigate = useNavigate();
  const [currentIndex, setCurrentIndex] = useState(
    parseInt(activityIndex || "0")
  );
  const [activities, setActivities] = useState([]);

  useEffect(() => {
    loadActivities();
  }, []);

  function loadActivities() {
    const mockActivities = [
      {
        time: "14:00",
        title: "Kamakhya Mandir",
        description:
          "A powerful Shakti Peeth, this revered temple on Nilachal Hill offers spectacular views and deep spiritual significance.",
        location: "Nilachal Hill, Guwahati",
        cost: 500,
        type: "afternoon",
      },
      {
        time: "17:00",
        title: "Sunset at Brahmaputra",
        description:
          "Experience the breathtaking sunset over the mighty Brahmaputra River. Take a river cruise to witness the golden hues reflecting on the water.",
        location: "Brahmaputra Riverfront",
        cost: 800,
        type: "evening",
      },
      {
        time: "19:30",
        title: "Traditional Assamese Dinner",
        description:
          "Savor authentic Assamese cuisine at a local restaurant. Try dishes like Masor Tenga, Khar, and finish with Pitha.",
        location: "Paradise Restaurant",
        cost: 600,
        type: "evening",
      },
    ];
    setActivities(mockActivities);
  }

  const generatePDF = () => {
    const doc = new jsPDF();
    doc.setFont("helvetica", "bold");
    doc.setFontSize(18);
    doc.text("Trip Itinerary - Activity Details", 14, 20);
    doc.setFontSize(12);
    doc.setFont("helvetica", "normal");

    autoTable(doc, {
      startY: 30,
      head: [["#", "Title", "Time", "Location", "Cost", "Description"]],
      body: activities.map((a, i) => [
        i + 1,
        a.title,
        a.time,
        a.location,
        `₹${a.cost}`,
        a.description,
      ]),
      styles: { cellPadding: 3, valign: "middle", fontSize: 10 },
      headStyles: { fillColor: [33, 150, 243] },
      columnStyles: {
        0: { cellWidth: 10 },
        1: { cellWidth: 40 },
        2: { cellWidth: 20 },
        3: { cellWidth: 35 },
        4: { cellWidth: 20 },
        5: { cellWidth: "auto" },
      },
    });

    doc.save("Trip_Activities.pdf");
  };

  const currentActivity = activities[currentIndex];
  const totalActivities = activities.length;

  function handlePrevious() {
    if (currentIndex > 0) setCurrentIndex(currentIndex - 1);
  }

  function handleNext() {
    if (currentIndex < totalActivities - 1) setCurrentIndex(currentIndex + 1);
  }

  if (!currentActivity) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-gray-600">Loading...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
      {/* 🔹 Navbar */}
      <nav className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 py-3 sm:py-4">
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              <button
                onClick={() => navigate(-1)}
                className="p-2 hover:bg-gray-100 rounded-lg transition"
              >
                <ArrowLeft className="w-5 h-5 text-gray-600" />
              </button>
              <div className="flex items-center gap-3">
                <div className="bg-blue-600 p-2 rounded-xl">
                  <Plane className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h1 className="text-lg sm:text-xl font-bold text-gray-900">
                    Activity Details
                  </h1>
                  <p className="text-sm text-gray-600">
                    Afternoon Explorations
                  </p>
                </div>
              </div>
            </div>

            {/* Buttons (wrap on small screens) */}
            <div className="flex flex-wrap gap-2 sm:gap-3">
              <button className="flex items-center gap-1 sm:gap-2 px-3 sm:px-5 py-2 sm:py-2.5 bg-green-600 hover:bg-green-700 rounded-xl transition text-white text-sm sm:text-base font-medium">
                <Save className="w-4 h-4" /> Save
              </button>
              <button className="flex items-center gap-1 sm:gap-2 px-3 sm:px-5 py-2 sm:py-2.5 bg-blue-600 hover:bg-blue-700 rounded-xl transition text-white text-sm sm:text-base font-medium">
                <Share2 className="w-4 h-4" /> Share
              </button>
              <button
                onClick={generatePDF}
                className="flex items-center gap-1 sm:gap-2 px-3 sm:px-5 py-2 sm:py-2.5 bg-purple-600 hover:bg-purple-700 rounded-xl transition text-white text-sm sm:text-base font-medium"
              >
                <FileDown className="w-4 h-4" /> PDF
              </button>
            </div>
          </div>
        </div>
      </nav>

      {/* 🔹 Activity Card */}
      <div className="max-w-5xl mx-auto px-4 sm:px-6 py-6 sm:py-10">
        <div className="bg-white rounded-3xl shadow-xl overflow-hidden">
          <div className="bg-gradient-to-br from-blue-500 to-blue-600 h-64 sm:h-80 flex items-center justify-center relative">
            <div className="text-center">
              <div className="w-24 h-24 sm:w-32 sm:h-32 bg-white/10 backdrop-blur-sm rounded-2xl sm:rounded-3xl mx-auto mb-4 flex items-center justify-center border-4 border-white/20">
                <span className="text-6xl sm:text-7xl">🏛️</span>
              </div>
              <p className="text-white/80 text-xs sm:text-sm font-medium">
                Image not available
              </p>
            </div>
            <div className="absolute top-4 right-4 sm:top-6 sm:right-6 bg-white/20 backdrop-blur-sm px-3 sm:px-4 py-1.5 sm:py-2 rounded-full">
              <span className="text-white font-semibold text-xs sm:text-sm uppercase">
                {currentActivity.type}
              </span>
            </div>
          </div>

          {/* 🔹 Activity Info */}
          <div className="p-6 sm:p-10">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6 mb-8">
              <div className="flex-1">
                <h2 className="text-2xl sm:text-4xl font-bold text-gray-900 mb-3 sm:mb-4">
                  {currentActivity.title}
                </h2>
                <div className="flex flex-wrap items-center gap-3 sm:gap-6 text-gray-600 text-sm sm:text-base">
                  <div className="flex items-center gap-2">
                    <Clock className="w-4 sm:w-5 h-4 sm:h-5" />
                    <span className="font-medium">{currentActivity.time}</span>
                  </div>
                  {currentActivity.location && (
                    <>
                      <span className="hidden sm:inline text-gray-300">•</span>
                      <div className="flex items-center gap-2">
                        <MapPin className="w-4 sm:w-5 h-4 sm:h-5" />
                        <span className="font-medium">
                          {currentActivity.location}
                        </span>
                      </div>
                    </>
                  )}
                </div>
              </div>

              {currentActivity.cost && (
                <div className="bg-green-50 rounded-2xl px-4 sm:px-6 py-3 sm:py-4 text-center">
                  <div className="flex items-center justify-center gap-1 text-green-600 font-bold text-xl sm:text-2xl">
                    <IndianRupee className="w-5 sm:w-6 h-5 sm:h-6" />
                    <span>{currentActivity.cost.toLocaleString()}</span>
                  </div>
                  <p className="text-xs sm:text-sm text-green-700 mt-1">
                    Estimated Cost
                  </p>
                </div>
              )}
            </div>

            {/* Description */}
            <p className="text-gray-700 leading-relaxed text-base sm:text-lg mb-8">
              {currentActivity.description}
            </p>

            <div className="mt-8 sm:mt-10 bg-blue-50 rounded-2xl p-6 sm:p-8 border-l-4 border-blue-600">
              <h3 className="font-bold text-lg sm:text-xl text-gray-900 mb-2 sm:mb-3">
                What to Expect
              </h3>
              <p className="text-gray-700 leading-relaxed text-sm sm:text-base">
                After visiting <strong>{currentActivity.title}</strong>, explore
                nearby attractions, try local food, or simply soak in the
                atmosphere. Capture the moments!
              </p>
            </div>
          </div>
        </div>

        {/* 🔹 Navigation Buttons */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4 mt-8">
          <button
            onClick={handlePrevious}
            disabled={currentIndex === 0}
            className="w-full sm:w-auto flex items-center justify-center gap-2 px-6 sm:px-8 py-3 bg-white hover:bg-gray-50 rounded-2xl transition disabled:opacity-50 disabled:cursor-not-allowed shadow-lg border border-gray-200"
          >
            <ChevronLeft className="w-5 h-5" />
            <span className="font-semibold text-sm sm:text-base">Previous</span>
          </button>

          <div className="text-center">
            <div className="text-xs sm:text-sm text-gray-500 mb-1">
              Activity
            </div>
            <div className="text-lg sm:text-2xl font-bold text-gray-900">
              {currentIndex + 1} <span className="text-gray-400">of</span>{" "}
              {totalActivities}
            </div>
          </div>

          <button
            onClick={handleNext}
            disabled={currentIndex === totalActivities - 1}
            className="w-full sm:w-auto flex items-center justify-center gap-2 px-6 sm:px-8 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl transition disabled:opacity-50 disabled:cursor-not-allowed shadow-lg"
          >
            <span className="font-semibold text-sm sm:text-base">Next</span>
            <ChevronRight className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
}
