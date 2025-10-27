import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  ArrowLeft,
  ChevronLeft,
  ChevronRight,
  Save,
  Share2,
  MapPin,
  IndianRupee,
  Plane,
  Clock
} from 'lucide-react';

export function ActivityDetail() {
  const { itineraryId, activityIndex } = useParams();
  const navigate = useNavigate();
  const [currentIndex, setCurrentIndex] = useState(parseInt(activityIndex || '0'));
  const [activities, setActivities] = useState([]);

  useEffect(() => {
    loadActivities();
  }, []);

  function loadActivities() {
    const mockActivities = [
      {
        time: '14:00',
        title: 'Kamakhya Mandir',
        description:
          'A powerful Shakti Peeth, this revered temple on Nilachal Hill offers spectacular views and deep spiritual significance. The temple is one of the oldest and most revered centers of Tantric practices and is dedicated to the mother goddess Kamakhya.',
        location: 'Nilachal Hill, Guwahati',
        cost: 500,
        type: 'afternoon',
      },
      {
        time: '17:00',
        title: 'Sunset at Brahmaputra',
        description:
          'Experience the breathtaking sunset over the mighty Brahmaputra River. Take a river cruise to witness the golden hues reflecting on the water while enjoying the cool evening breeze.',
        location: 'Brahmaputra Riverfront',
        cost: 800,
        type: 'evening',
      },
      {
        time: '19:30',
        title: 'Traditional Assamese Dinner',
        description:
          'Savor authentic Assamese cuisine at a local restaurant. Try dishes like Masor Tenga (sour fish curry), Khar, and finish with Pitha (rice cakes).',
        location: 'Paradise Restaurant',
        cost: 600,
        type: 'evening',
      },
    ];

    setActivities(mockActivities);
  }

  const currentActivity = activities[currentIndex];
  const totalActivities = activities.length;

  function handlePrevious() {
    if (currentIndex > 0) {
      setCurrentIndex(currentIndex - 1);
    }
  }

  function handleNext() {
    if (currentIndex < totalActivities - 1) {
      setCurrentIndex(currentIndex + 1);
    }
  }

  if (!currentActivity) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50 flex items-center justify-center">
        <div className="text-gray-600">Loading...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
      <nav className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
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
                  <h1 className="text-xl font-bold text-gray-900">Activity Details</h1>
                  <p className="text-sm text-gray-600">Afternoon Explorations</p>
                </div>
              </div>
            </div>
            <div className="flex gap-3">
              <button className="flex items-center gap-2 px-5 py-2.5 bg-green-600 hover:bg-green-700 rounded-xl transition text-white font-medium">
                <Save className="w-4 h-4" />
                Save
              </button>
              <button className="flex items-center gap-2 px-5 py-2.5 bg-blue-600 hover:bg-blue-700 rounded-xl transition text-white font-medium">
                <Share2 className="w-4 h-4" />
                Share
              </button>
            </div>
          </div>
        </div>
      </nav>

      <div className="max-w-5xl mx-auto px-6 py-8">
        <div className="bg-white rounded-3xl shadow-xl overflow-hidden">
          <div className="bg-gradient-to-br from-blue-500 to-blue-600 h-80 flex items-center justify-center relative">
            <div className="text-center">
              <div className="w-32 h-32 bg-white/10 backdrop-blur-sm rounded-3xl mx-auto mb-4 flex items-center justify-center border-4 border-white/20">
                <span className="text-7xl">🏛️</span>
              </div>
              <p className="text-white/80 text-sm font-medium">Image not available</p>
            </div>
            <div className="absolute top-6 right-6 bg-white/20 backdrop-blur-sm px-4 py-2 rounded-full">
              <span className="text-white font-semibold text-sm uppercase">{currentActivity.type}</span>
            </div>
          </div>

          <div className="p-10">
            <div className="flex items-start justify-between mb-8">
              <div className="flex-1">
                <h2 className="text-4xl font-bold text-gray-900 mb-4">{currentActivity.title}</h2>
                <div className="flex items-center gap-6 text-gray-600">
                  <div className="flex items-center gap-2">
                    <Clock className="w-5 h-5" />
                    <span className="font-medium">{currentActivity.time}</span>
                  </div>
                  {currentActivity.location && (
                    <>
                      <span className="text-gray-300">•</span>
                      <div className="flex items-center gap-2">
                        <MapPin className="w-5 h-5" />
                        <span className="font-medium">{currentActivity.location}</span>
                      </div>
                    </>
                  )}
                </div>
              </div>
              {currentActivity.cost && (
                <div className="bg-green-50 rounded-2xl px-6 py-4 text-center">
                  <div className="flex items-center gap-1 text-green-600 font-bold text-2xl">
                    <IndianRupee className="w-6 h-6" />
                    <span>{currentActivity.cost.toLocaleString()}</span>
                  </div>
                  <p className="text-xs text-green-700 mt-1">Estimated Cost</p>
                </div>
              )}
            </div>

            <div className="prose prose-lg max-w-none">
              <p className="text-gray-700 leading-relaxed text-lg">{currentActivity.description}</p>
            </div>

            <div className="mt-10 bg-blue-50 rounded-2xl p-8 border-l-4 border-blue-600">
              <h3 className="font-bold text-xl text-gray-900 mb-3">What to Expect</h3>
              <p className="text-gray-700 leading-relaxed">
                Discover more amazing places! After visiting {currentActivity.title}, explore nearby attractions,
                try local street food, or simply soak in the vibrant atmosphere of the area. Don't forget to bring
                your camera to capture the memorable moments.
              </p>
            </div>
          </div>
        </div>

        <div className="flex items-center justify-between mt-8">
          <button
            onClick={handlePrevious}
            disabled={currentIndex === 0}
            className="flex items-center gap-2 px-8 py-4 bg-white hover:bg-gray-50 rounded-2xl transition disabled:opacity-50 disabled:cursor-not-allowed shadow-lg border border-gray-200"
          >
            <ChevronLeft className="w-5 h-5" />
            <span className="font-semibold">Previous Activity</span>
          </button>

          <div className="text-center">
            <div className="text-sm text-gray-500 mb-1">Activity</div>
            <div className="text-2xl font-bold text-gray-900">
              {currentIndex + 1} <span className="text-gray-400">of</span> {totalActivities}
            </div>
          </div>

          <button
            onClick={handleNext}
            disabled={currentIndex === totalActivities - 1}
            className="flex items-center gap-2 px-8 py-4 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl transition disabled:opacity-50 disabled:cursor-not-allowed shadow-lg"
          >
            <span className="font-semibold">Next Activity</span>
            <ChevronRight className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
}
