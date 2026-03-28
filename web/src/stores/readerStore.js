// frontend/src/stores/readerStore.js
import { create } from "zustand";

const defaults = {
    quality: localStorage.getItem("reader_quality") || "data",
    mode: localStorage.getItem("reader_mode") || "single",
    showUI: true,
};

export const useReaderStore = create((set) => ({
    ...defaults,
    currentPage: 0,
    totalPages: 0,

    setQuality: (quality) => {
        localStorage.setItem("reader_quality", quality);
        set({ quality });
    },
    setMode: (mode) => {
        localStorage.setItem("reader_mode", mode);
        set({ mode });
    },
    setCurrentPage: (p) => {
        if (typeof p === "function") {
            set((s) => ({ currentPage: p(s.currentPage) }));
        } else {
            set({ currentPage: p });
        }
    },
    setTotalPages: (t) => set({ totalPages: t }),
    toggleUI: () => set((s) => ({ showUI: !s.showUI })),
    reset: () => set({ currentPage: 0, totalPages: 0, showUI: true }),
}));