import { useState, useRef, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, Send, Sparkles, Plane } from "lucide-react";
import { useAuth } from "../contexts/AuthContext";
import { db } from "../firebase";
import { collection, addDoc, serverTimestamp } from "firebase/firestore";

export function AIAssistant() {
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

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  // Send message + store in Firestore
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
      if (user) {
        await addDoc(collection(db, "chat_messages"), {
          user_id: user.uid,
          role: "user",
          content: input,
          created_at: serverTimestamp(),
        });
      }

      setTimeout(async () => {
        const assistantMessage = {
          id: (Date.now() + 1).toString(),
          role: "assistant",
          content: getAIResponse(input, messages.length),
        };
        setMessages((prev) => [...prev, assistantMessage]);

        if (user) {
          await addDoc(collection(db, "chat_messages"), {
            user_id: user.uid,
            role: "assistant",
            content: assistantMessage.content,
            created_at: serverTimestamp(),
          });
        }

        setLoading(false);
      }, 1000);
    } catch (error) {
      console.error("Error saving message:", error);
      setLoading(false);
    }
  }

  // Simple simulated AI response logic
  function getAIResponse(userInput, messageCount) {
    const lowerInput = userInput.toLowerCase();

    if (messageCount === 1) {
      return `Great! To create the perfect itinerary for you, I need some details:

• Where would you like to go?
• How many days do you have?
• What's your budget (in INR)?
• What are your interests? (heritage, adventure, nightlife, food, nature, etc.)
• Any food preferences or restrictions? (veg, non-veg, vegan, Jain, etc.)
• What will be your transport mode?
• Does the budget include the initial travel cost (flight, train, etc)?
• Do you have any personal preferences for this trip?

Please share these details, and I'll craft an amazing trip for you!`;
    }

    if (messageCount === 3) {
      return "Perfect! I'm analyzing your preferences and creating a personalized itinerary. This will include accommodation, transport, experiences, and a day-by-day breakdown with cost estimates. Give me a moment...";
    }

    if (messageCount === 5) {
      return "I've created your personalized itinerary! It's ready for you to view. You can save it, share it, or proceed to book your entire trip with a single click. Would you like to see your itinerary now?";
    }

    return "I'm processing your request. Please continue sharing details about your trip preferences.";
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

      <div className="max-w-5xl mx-auto px-6 py-8">
        <div className="bg-white rounded-3xl shadow-lg flex flex-col h-[calc(100vh-200px)]">
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
