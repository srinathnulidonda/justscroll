// frontend/src/stores/themeStore.js
import { create } from "zustand";

function getInitialTheme() {
    const stored = localStorage.getItem("theme");
    if (stored === "light" || stored === "dark") return stored;
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
}

function applyTheme(theme) {
    document.documentElement.classList.toggle("dark", theme === "dark");
    document.querySelector('meta[name="theme-color"]')?.setAttribute("content", theme === "dark" ? "#09090b" : "#ffffff");
}

export const useThemeStore = create((set) => {
    const initial = getInitialTheme();
    applyTheme(initial);

    return {
        theme: initial,
        toggle: () =>
            set((s) => {
                const next = s.theme === "dark" ? "light" : "dark";
                localStorage.setItem("theme", next);
                applyTheme(next);
                return { theme: next };
            }),
        setTheme: (theme) => {
            localStorage.setItem("theme", theme);
            applyTheme(theme);
            set({ theme });
        },
    };
});