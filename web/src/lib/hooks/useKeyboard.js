// frontend/src/lib/hooks/useKeyboard.js
import { useEffect } from "react";

export function useKeyboard(keyMap, deps = []) {
    useEffect(() => {
        function handler(e) {
            const key = e.key.toLowerCase();
            const combo = `${e.metaKey || e.ctrlKey ? "mod+" : ""}${e.shiftKey ? "shift+" : ""}${key}`;

            if (keyMap[combo]) {
                e.preventDefault();
                keyMap[combo](e);
            } else if (keyMap[key]) {
                if (e.target.tagName === "INPUT" || e.target.tagName === "TEXTAREA" || e.target.isContentEditable)
                    return;
                keyMap[key](e);
            }
        }
        window.addEventListener("keydown", handler);
        return () => window.removeEventListener("keydown", handler);
    }, deps);
}