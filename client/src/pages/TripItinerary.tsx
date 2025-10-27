import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Save, Share2, Coffee, Sun, Moon, MapPin, IndianRupee, Plane } from 'lucide-react';
import { supabase, Trip, Itinerary } from '../lib/supabase';
import { useAuth } from '../contexts/AuthContext';

export function TripItinerary() {
  const { tripId } = useParams();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [trip, setTrip] = useState<Trip | null>(null);
  const [itineraries, setItineraries] = useState<Itinerary[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (tripId) {
      loadTripData();
    } else {
      loadMockData();
    }
  }, [tripId]);

  async function loadTripData() {
    try {
      const { data: tripData, error: tripError } = await supabase
        .from('trips')
        .select('*')
        .eq('id', tripId)
        .maybeSingle();

      if (tripError) throw tripError;

      const { data: itineraryData, error: itineraryError } = await supabase
        .from('itineraries')
        .select('*')
        .eq('trip_id', tripId)
        .order('day_number', { ascending: true });

      if (itineraryError) throw itineraryError;

      setTrip(tripData);
      setItineraries(itineraryData || []);
    } catch (error) {
      console.error('Error loading trip:', error);
      loadMockData();
    } finally {
      setLoading(false);
    }
  }

  function loadMockData() {
    const mockTrip: Trip = {
      id: 'mock-1',
      user_id: user?.id || '',
      title: 'Gujarat Heritage Tour',
      destination: 'Gujarat',
      duration_days: 7,
      budget: 22000,
      start_date: null,
      end_date: null,
      status: 'planning',
      preferences: {},
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    const mockItineraries: Itinerary[] = [
      {
        id: '1',
        trip_id: 'mock-1',
        day_number: 1,
        date: null,
        daily_budget: 3500,
        activities: [
          {
            time: '09:00',
            title: 'Arrival at Dwarkadhish',
            description:
              'Arrive at Dwarkadhish (Dwarka) International Airport - DXI). Check into your pre-booked accommodation recommended for solo travelers. Budget approximately INR 2600 for the hotel.',
            location: 'Dwarka International Airport',
            cost: 2600,
            type: 'morning',
          },
          {
            time: '14:00',
            title: 'Visit Dwarkadhish Temple',
            description:
              'Visit the majestic Dwarkadhish Mandir. Allow ample time for the spiritual experience and enjoy the panoramic views of the Arabian Sea. Explore the intricate architecture. Suggested time: 2-3 hours. Consider trying local street food near Fancy Bazaar or Pani Bazaar to get a feel for the local cuisine. Budget for some souvenirs.',
            location: 'Dwarkadhish Temple',
            cost: 500,
            type: 'afternoon',
          },
          {
            time: '19:00',
            title: 'Traditional Assamese Meal',
            description:
              'Enjoy a traditional Assamese thali for dinner at a local restaurant. Explore local food options if you\'re feeling adventurous. Allow some time to relax at your accommodation.',
            location: 'Local Restaurant',
            cost: 400,
            type: 'evening',
          },
        ],
        created_at: new Date().toISOString(),
      },
      {
        id: '2',
        trip_id: 'mock-1',
        day_number: 2,
        date: null,
        daily_budget: 2500,
        activities: [
          {
            time: '08:00',
            title: 'Morning Exploration',
            description:
              'Start your day with a visit to local markets. Experience the vibrant culture and pick up some traditional handicrafts.',
            location: 'Local Markets',
            cost: 1000,
            type: 'morning',
          },
          {
            time: '14:00',
            title: 'Heritage Sites',
            description:
              'Visit UNESCO World Heritage sites in the area. Take a guided tour to learn about the rich history and culture.',
            location: 'Heritage Site',
            cost: 1200,
            type: 'afternoon',
          },
          {
            time: '19:00',
            title: 'Evening Leisure',
            description:
              'Relax and enjoy the evening at your hotel. Try local cuisine at nearby restaurants.',
            location: 'Hotel',
            cost: 300,
            type: 'evening',
          },
        ],
        created_at: new Date().toISOString(),
      },
    ];

    setTrip(mockTrip);
    setItineraries(mockItineraries);
    setLoading(false);
  }

  function getTimeIcon(type: string) {
    switch (type) {
      case 'morning':
        return <Sun className="w-4 h-4" />;
      case 'afternoon':
        return <Coffee className="w-4 h-4" />;
      case 'evening':
      case 'night':
        return <Moon className="w-4 h-4" />;
      default:
        return <MapPin className="w-4 h-4" />;
    }
  }

  async function handleSaveItinerary() {
    alert('Itinerary saved successfully!');
  }

  function handleShareItinerary() {
    alert('Share functionality coming soon!');
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
      <nav className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center gap-4">
            <button
              onClick={() => navigate('/')}
              className="p-2 hover:bg-gray-100 rounded-lg transition"
            >
              <ArrowLeft className="w-5 h-5 text-gray-600" />
            </button>
            <div className="flex items-center gap-3">
              <div className="bg-blue-600 p-2 rounded-xl">
                <Plane className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">Trip Itinerary</h1>
                <p className="text-sm text-gray-600">{trip?.destination || 'Your Journey'}</p>
              </div>
            </div>
          </div>
        </div>
      </nav>

      <div className="max-w-6xl mx-auto px-6 py-8">
        <div className="bg-gradient-to-r from-blue-600 to-blue-700 text-white rounded-3xl p-8 mb-8 shadow-xl">
          <div className="flex justify-between items-center">
            <div>
              <h2 className="text-3xl font-bold mb-2">{trip?.destination}</h2>
              <p className="text-xl text-blue-100">{trip?.duration_days} Days Adventure</p>
            </div>
            <div className="text-right">
              <div className="text-4xl font-bold">₹{trip?.budget.toLocaleString()}</div>
              <div className="text-lg text-blue-100">Total Budget</div>
            </div>
          </div>
        </div>

        <div className="flex gap-4 mb-8">
          <button
            onClick={handleSaveItinerary}
            className="flex items-center gap-2 bg-green-600 text-white px-8 py-4 rounded-2xl font-semibold hover:bg-green-700 transition shadow-lg"
          >
            <Save className="w-5 h-5" />
            Save Itinerary
          </button>
          <button
            onClick={handleShareItinerary}
            className="flex items-center gap-2 bg-blue-600 text-white px-8 py-4 rounded-2xl font-semibold hover:bg-blue-700 transition shadow-lg"
          >
            <Share2 className="w-5 h-5" />
            Share Visual Story
          </button>
          <button
            onClick={() => navigate('/itinerary')}
            className="flex items-center gap-2 bg-orange-600 text-white px-8 py-4 rounded-2xl font-semibold hover:bg-orange-700 transition shadow-lg ml-auto"
          >
            <Plane className="w-5 h-5" />
            Book Trip
          </button>
        </div>

        <div className="space-y-6">
          {itineraries.map((itinerary) => (
            <div key={itinerary.id} className="bg-white rounded-3xl shadow-lg overflow-hidden border border-gray-100">
              <div className="bg-gradient-to-r from-blue-500 to-blue-600 text-white px-8 py-5 flex justify-between items-center">
                <h3 className="text-2xl font-bold">Day {itinerary.day_number}</h3>
                <span className="text-lg bg-white/20 px-5 py-2 rounded-full font-semibold">
                  ₹{itinerary.daily_budget.toLocaleString()}
                </span>
              </div>

              <div className="p-8 space-y-6">
                {itinerary.activities.map((activity, idx) => (
                  <div
                    key={idx}
                    onClick={() => navigate(`/activity/${itinerary.id}/${idx}`)}
                    className="cursor-pointer hover:shadow-lg transition rounded-2xl p-6 border border-gray-200 hover:border-blue-300 group"
                  >
                    <div className="flex gap-5">
                      <div className="flex-shrink-0">
                        <div className="w-14 h-14 bg-blue-100 rounded-2xl flex items-center justify-center text-blue-600 group-hover:bg-blue-600 group-hover:text-white transition">
                          {getTimeIcon(activity.type)}
                        </div>
                      </div>
                      <div className="flex-1">
                        <div className="flex items-center gap-3 mb-2">
                          <span className="text-sm font-bold text-blue-600 uppercase tracking-wide">
                            {activity.type}
                          </span>
                          <span className="text-gray-400">•</span>
                          <span className="text-sm text-gray-600 font-medium">{activity.time}</span>
                        </div>
                        <h4 className="font-bold text-xl text-gray-900 mb-3 group-hover:text-blue-600 transition">{activity.title}</h4>
                        <p className="text-gray-600 leading-relaxed mb-4 line-clamp-2">
                          {activity.description}
                        </p>
                        <div className="flex items-center justify-between">
                          {activity.location && (
                            <div className="flex items-center gap-2 text-gray-500">
                              <MapPin className="w-4 h-4" />
                              <span className="text-sm">{activity.location}</span>
                            </div>
                          )}
                          {activity.cost && (
                            <div className="flex items-center gap-1 text-lg font-bold text-green-600">
                              <IndianRupee className="w-5 h-5" />
                              {activity.cost.toLocaleString()}
                            </div>
                          )}
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
