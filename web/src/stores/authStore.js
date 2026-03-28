// frontend/src/stores/authStore.js
import { create } from "zustand";
import { api } from "@/lib/api";

export const useAuthStore = create((set, get) => ({
    user: null,
    isLoading: true,
    isAuthenticated: false,
    isInitialized: false,

    initialize: () => {
        // Prevent double initialization
        if (get().isInitialized) return;

        const token = localStorage.getItem("access_token");
        const userJson = localStorage.getItem("user_data");

        if (token && userJson) {
            try {
                const user = JSON.parse(userJson);
                set({
                    user,
                    isAuthenticated: true,
                    isLoading: false,
                    isInitialized: true,
                });
            } catch {
                // Clear invalid data
                localStorage.removeItem("access_token");
                localStorage.removeItem("refresh_token");
                localStorage.removeItem("user_data");
                set({
                    user: null,
                    isAuthenticated: false,
                    isLoading: false,
                    isInitialized: true,
                });
            }
        } else {
            set({
                user: null,
                isAuthenticated: false,
                isLoading: false,
                isInitialized: true,
            });
        }
    },

    login: async (username, password) => {
        const data = await api.login({ username, password });
        localStorage.setItem("access_token", data.access_token);
        localStorage.setItem("refresh_token", data.refresh_token);
        const user = { username };
        localStorage.setItem("user_data", JSON.stringify(user));
        set({ user, isAuthenticated: true, isLoading: false });
        return data;
    },

    register: async (username, email, password) => {
        const data = await api.register({ username, email, password });
        localStorage.setItem("access_token", data.access_token);
        localStorage.setItem("refresh_token", data.refresh_token);
        const user = { username, email };
        localStorage.setItem("user_data", JSON.stringify(user));
        set({ user, isAuthenticated: true, isLoading: false });
        return data;
    },

    logout: () => {
        localStorage.removeItem("access_token");
        localStorage.removeItem("refresh_token");
        localStorage.removeItem("user_data");
        set({ user: null, isAuthenticated: false, isLoading: false });
    },
}));