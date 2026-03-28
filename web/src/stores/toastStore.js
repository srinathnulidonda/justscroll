// frontend/src/stores/toastStore.js
import { create } from "zustand";

let toastId = 0;

export const useToastStore = create((set) => ({
    toasts: [],

    addToast: ({ title, description, type = "info", duration = 3500 }) => {
        const id = ++toastId;

        set((s) => ({
            toasts: [
                ...s.toasts.slice(-4), // Keep max 5 toasts
                { id, title, description, type, duration },
            ],
        }));

        if (duration > 0) {
            setTimeout(() => {
                set((s) => ({ toasts: s.toasts.filter((t) => t.id !== id) }));
            }, duration);
        }

        return id;
    },

    removeToast: (id) =>
        set((s) => ({ toasts: s.toasts.filter((t) => t.id !== id) })),
}));

export function toast(opts) {
    if (typeof opts === "string")
        return useToastStore.getState().addToast({ title: opts });
    return useToastStore.getState().addToast(opts);
}

toast.success = (title, opts) =>
    toast({ title, type: "success", duration: 2500, ...opts });
toast.error = (title, opts) =>
    toast({ title, type: "error", duration: 4000, ...opts });
toast.warning = (title, opts) =>
    toast({ title, type: "warning", duration: 3500, ...opts });
toast.info = (title, opts) =>
    toast({ title, type: "info", duration: 3000, ...opts });