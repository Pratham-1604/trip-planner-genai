import { createContext, useContext, useEffect, useState } from "react";
import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut as firebaseSignOut,
  onAuthStateChanged,
  updateProfile,
} from "firebase/auth";
import { doc, setDoc, getDoc } from "firebase/firestore";
import { auth, db } from "../firebase"; // make sure this path matches your firebase.jsx

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);

  // Watch Firebase auth state
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (currentUser) => {
      setUser(currentUser);
      if (currentUser) {
        await loadProfile(currentUser.uid);
      } else {
        setProfile(null);
      }
      setLoading(false);
    });

    return unsubscribe;
  }, []);

  // Load user profile from Firestore
  async function loadProfile(userId) {
    try {
      const profileRef = doc(db, "profiles", userId);
      const profileSnap = await getDoc(profileRef);
      if (profileSnap.exists()) {
        setProfile(profileSnap.data());
      } else {
        setProfile(null);
      }
    } catch (error) {
      console.error("Error loading profile:", error);
    }
  }

  // Signup
  async function signUp(email, password, fullName) {
    try {
      const userCredential = await createUserWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;

      // Update Firebase display name
      await updateProfile(user, { displayName: fullName });

      // Save profile to Firestore
      await setDoc(doc(db, "profiles", user.uid), {
        id: user.uid,
        email: user.email,
        full_name: fullName,
        created_at: new Date().toISOString(),
      });

      setUser(user);
      setProfile({ id: user.uid, email: user.email, full_name: fullName });

      return { error: null };
    } catch (error) {
      console.error("Signup error:", error);
      return { error };
    }
  }

  // Login
  async function signIn(email, password) {
    try {
      await signInWithEmailAndPassword(auth, email, password);
      return { error: null };
    } catch (error) {
      console.error("Signin error:", error);
      return { error };
    }
  }

  // Logout
  async function signOut() {
    try {
      await firebaseSignOut(auth);
      setUser(null);
      setProfile(null);
    } catch (error) {
      console.error("Signout error:", error);
    }
  }

  const value = {
    user,
    profile,
    loading,
    signUp,
    signIn,
    signOut,
  };

  return (
    <AuthContext.Provider value={value}>
      {!loading && children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}
