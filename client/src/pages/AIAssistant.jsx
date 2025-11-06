import { useState, useRef, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, Send, Sparkles, Plane } from "lucide-react";
import { useAuth } from "../contexts/AuthContext";
import { db } from "../firebase";
import { collection, addDoc, serverTimestamp } from "firebase/firestore";

export default function AIAssistant() {
  const [messages, setMessages] = useState([
    {
      id: "1",
      role: "assistant",
      content:
        "Hi! I'm your AI Travel planner. Tell me about your dream trip and I'll create a personalized itinerary for you!",
    },
  ]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef(null);
  const navigate = useNavigate();
  const { user } = useAuth();
  const [initialPrompt, setInitialPrompt] = useState("");  // stores the first user message
  const [needClarification, setNeedClarification] = useState(false); // controls which API to call
   const API_BASE = process.env.REACT_APP_API_URL;

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

async function handleSend() {
  if (!input.trim() || loading) return;

  const userMessage = {
    id: Date.now().toString(),
    role: "user",
    content: input,
  };

  setMessages((prev) => [...prev, userMessage]);
  setInput("");
  setLoading(true);

  try {
    let apiUrl = "";
    let body = {};

    // 🧭 Choose which API to call
    if (!needClarification) {
      apiUrl = `${API_BASE}/generate-iternary`;
      body = { prompt: input };
      setInitialPrompt(input);
    } else {
      apiUrl = `${API_BASE}/generate-final-iternary`;
      body = {
        prompt: initialPrompt,
        clarrifying_answers: input,
      };
      setNeedClarification(false);
    }

    // 🔥 Call backend API
    const response = await fetch(apiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });

    const data = await response.json();
    console.log("API Response:", data);

    // 🧩 STEP 2 — Handle response + mark if it’s final itinerary
    let replyText = "";
    let isFinal = false;

    if (data.message === "Need clarification") {
      replyText = `I need some more info:\n${data.resp}`;
      setNeedClarification(true);
    } else {
      replyText =
        typeof data === "string"
          ? data
          : JSON.stringify(data, null, 2);
      isFinal = true; // ✅ mark this as final itinerary
    }

    // Create assistant message (with optional itinerary data)
    const assistantMessage = {
      id: (Date.now() + 1).toString(),
      role: "assistant",
      content: replyText,
      isFinal, // track if final
      itineraryData: isFinal ? data : null, // keep itinerary JSON
    };

    setMessages((prev) => [...prev, assistantMessage]);

    // Optional Firestore save for messages
    if (user) {
      addDoc(collection(db, "chat_messages"), {
        user_id: user.uid,
        role: "user",
        content: input,
        created_at: serverTimestamp(),
      }).catch((err) => console.error("Firestore save error:", err));
    }

  } catch (error) {
    console.error("Error calling itinerary API:", error);
    const errorMsg = {
      id: (Date.now() + 1).toString(),
      role: "assistant",
      content: "❌ Sorry, I couldn't generate your itinerary right now.",
    };
    setMessages((prev) => [...prev, errorMsg]);
  } finally {
    setLoading(false);
  }
}

async function saveItineraryToFirestore(itineraryData) {
  if (!user) {
    alert("Please log in to save your itinerary.");
    return;
  }

  try {
    const tripRef = await addDoc(collection(db, "savedTrips"), {
      userId: user.uid,
      title: itineraryData.title || "My AI Trip",
      description:
        itineraryData.description ||
        "An AI-generated personalized itinerary.",
      itinerary: itineraryData, // store the JSON as-is
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });

    // Optionally, also add to user's savedTrips array
    await addDoc(collection(db, "users"), {
      userId: user.uid,
      savedTrips: [tripRef.id],
    });

    alert("✅ Itinerary saved successfully!");
  } catch (error) {
    console.error("Error saving itinerary:", error);
    alert("❌ Failed to save itinerary. Please try again.");
  }
}

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
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
                  AI Trip Assistant
                </h1>
                <p className="text-sm text-gray-600">
                  Powered by advanced AI technology
                </p>
              </div>
            </div>
          </div>
        </div>
      </nav>

      <div className="max-w-6xl mx-auto px-6 py-8">
        <div className="bg-white rounded-3xl shadow-lg flex flex-col min-h-[80vh] sm:min-h-[85vh] max-h-[calc(100vh-150px)]">
          <div className="flex-1 overflow-y-auto p-8 space-y-6">
            {messages.map((message) => (
              <div
                key={message.id}
                className={`flex ${
                  message.role === "user" ? "justify-end" : "justify-start"
                }`}
              >
                <div
                  className={`max-w-[70%] rounded-2xl px-6 py-4 ${
                    message.role === "user"
                      ? "bg-blue-600 text-white"
                      : "bg-gray-100 text-gray-800"
                  }`}
                >
                  {message.role === "assistant" && (
                    <div className="flex items-center gap-2 mb-3">
                      <div className="bg-blue-600 p-1.5 rounded-lg">
                        <Sparkles className="w-4 h-4 text-white" />
                      </div>
                      <span className="text-sm font-semibold text-gray-700">
                        AI Assistant
                      </span>
                    </div>
                  )}
                  <p className="whitespace-pre-wrap leading-relaxed">
                    {message.content}
                  </p>
                  {/* 💾 Show Save button if it's a final itinerary */}
                  {message.isFinal && (
                    <div className="mt-4 flex justify-end">
                      <button
                        onClick={() => saveItineraryToFirestore(message.itineraryData)}
                        className="bg-green-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-green-700 transition"
                      >
                        💾 Save Itinerary
                      </button>
                    </div>
                  )}
                  <p className="text-xs mt-2 opacity-60">
                    {new Date().toLocaleTimeString([], {
                      hour: "2-digit",
                      minute: "2-digit",
                    })}
                  </p>
                </div>
              </div>
            ))}

            {loading && (
              <div className="flex justify-start">
                <div className="bg-gray-100 rounded-2xl px-6 py-4">
                  <div className="flex items-center gap-2">
                    <div className="w-3 h-3 bg-blue-600 rounded-full animate-bounce" />
                    <div
                      className="w-3 h-3 bg-blue-600 rounded-full animate-bounce"
                      style={{ animationDelay: "0.1s" }}
                    />
                    <div
                      className="w-3 h-3 bg-blue-600 rounded-full animate-bounce"
                      style={{ animationDelay: "0.2s" }}
                    />
                  </div>
                </div>
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>

          <div className="p-6 bg-gray-50 border-t border-gray-200 rounded-b-3xl">
            <div className="flex gap-3">
              <input
                type="text"
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyPress={(e) => e.key === "Enter" && handleSend()}
                placeholder="Describe your dream trip..."
                className="flex-1 px-6 py-4 border border-gray-300 rounded-2xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none text-lg"
              />
              <button
                onClick={handleSend}
                disabled={!input.trim() || loading}
                className="bg-blue-600 text-white px-8 py-4 rounded-2xl font-semibold hover:bg-blue-700 transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
              >
                <Send className="w-5 h-5" />
                Send
              </button>
            </div>
            <p className="text-xs text-gray-500 mt-3 text-center">
              AI can make mistakes. Verify important information before booking.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
