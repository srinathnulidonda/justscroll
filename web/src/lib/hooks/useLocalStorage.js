// frontend/src/lib/hooks/useLocalStorage.js
import { useState, useCallback } from "react";

export function useLocalStorage(key, initialValue) {
    const [storedValue, setStoredValue] = useState(() => {
        try {
            const item = localStorage.getItem(key);
            return item ? JSON.parse(item) : initialValue;
        } catch {
            return initialValue;
        }
    });

    const setValue = useCallback(
        (value) => {
            const next = value instanceof Function ? value(storedValue) : value;
            setStoredValue(next);
            try {
                localStorage.setItem(key, JSON.stringify(next));
            } catch { }
        },
        [key, storedValue]
    );

    return [storedValue, setValue];
}