import { useState } from "react";
import { X, MapPin, Map, ChevronLeft, ChevronRight } from "lucide-react";
import { GoogleMapComponent } from "./GoogleMapComponent";

export function StoriesModal({ stories, onClose }) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [showMap, setShowMap] = useState(false);

  if (!stories?.length) {
    return (
      <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
        <div className="bg-white rounded-3xl shadow-xl p-8 max-w-2xl w-full text-center">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Stories</h2>
          <p className="text-gray-600 text-lg">No stories available yet</p>
          <button
            onClick={onClose}
            className="mt-6 px-4 py-2 bg-blue-600 text-white rounded-lg"
          >
            Close
          </button>
        </div>
      </div>
    );
  }

  const currentStory = stories[currentIndex];

  if (showMap) {
    return (
      <div className="fixed inset-0 bg-black/50 flex justify-center items-center z-50 p-4">
        <div className="relative bg-white rounded-3xl shadow-2xl max-w-4xl w-full h-[90vh] overflow-hidden flex flex-col">
          {/* Header */}
          <div className="flex justify-between items-center p-6 border-b">
            <h3 className="text-xl font-semibold text-gray-900 truncate">
              {currentStory.title}
            </h3>
            <button
              onClick={() => setShowMap(false)}
              className="p-2 hover:bg-gray-100 rounded-lg transition"
            >
              <X className="w-5 h-5 text-gray-600" />
            </button>
          </div>

          {/* Map Container */}
          <div className="flex-1 overflow-hidden">
            <GoogleMapComponent
              latitude={currentStory.latitude}
              longitude={currentStory.longitude}
              title={currentStory.title}
            />
          </div>
        </div>
      </div>
    );
  }

  const handleNext = () =>
    setCurrentIndex((prev) => (prev + 1) % stories.length);
  const handlePrev = () =>
    setCurrentIndex((prev) => (prev - 1 + stories.length) % stories.length);

  return (
    <div className="fixed inset-0 bg-black/50 z-50 flex justify-center items-center p-4">
      {/* Scrollable modal body */}
      <div className="relative bg-white rounded-3xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        {/* Image */}
        <div className="relative">
          <img
            src={currentStory.image}
            alt={currentStory.title}
            className="w-full aspect-video object-cover"
          />

          {/* Close */}
          <button
            onClick={onClose}
            className="absolute top-4 right-4 p-2 bg-white/90 hover:bg-white rounded-full shadow-md transition"
          >
            <X className="w-5 h-5 text-gray-700" />
          </button>

          {/* Navigation */}
          {stories.length > 1 && (
            <>
              <button
                onClick={handlePrev}
                className="absolute left-4 top-1/2 -translate-y-1/2 p-2 bg-white/90 hover:bg-white rounded-full shadow-md transition"
              >
                <ChevronLeft className="w-6 h-6 text-gray-700" />
              </button>
              <button
                onClick={handleNext}
                className="absolute right-4 top-1/2 -translate-y-1/2 p-2 bg-white/90 hover:bg-white rounded-full shadow-md transition"
              >
                <ChevronRight className="w-6 h-6 text-gray-700" />
              </button>
            </>
          )}
        </div>

        {/* Content */}
        <div className="p-6 sm:p-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-1">
            {currentStory.title}
          </h2>
          <p className="text-sm text-gray-500 mb-4">
            {currentStory.timestamp || "Day 1 • 3:00 PM"}
          </p>

          <p className="text-gray-700 text-base leading-relaxed mb-6">
            {currentStory.description}
          </p>

          <div className="flex items-center gap-2 mb-6">
            <MapPin className="w-5 h-5 text-blue-600" />
            <span className="text-gray-700 font-medium truncate">
              {currentStory.location || currentStory.title}
            </span>
          </div>

          <div className="flex flex-col sm:flex-row gap-4">
            <button
              onClick={() => setShowMap(true)}
              className="flex-1 flex items-center justify-center gap-2 bg-blue-600 text-white px-6 py-3 rounded-2xl font-semibold hover:bg-blue-700 transition shadow-md"
            >
              <Map className="w-5 h-5" />
              Show Map
            </button>

            {stories.length > 1 && (
              <div className="flex items-center justify-center gap-2 px-5 py-3 bg-gray-100 rounded-2xl text-sm font-semibold text-gray-700">
                {currentIndex + 1} / {stories.length}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
