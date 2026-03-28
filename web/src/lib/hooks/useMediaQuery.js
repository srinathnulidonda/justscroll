// frontend/src/lib/hooks/useMediaQuery.js
import { useState, useEffect } from "react";

export function useMediaQuery(query) {
    const [matches, setMatches] = useState(false);
    useEffect(() => {
        const mql = window.matchMedia(query);
        setMatches(mql.matches);
        const handler = (e) => setMatches(e.matches);
        mql.addEventListener("change", handler);
        return () => mql.removeEventListener("change", handler);
    }, [query]);
    return matches;
}

export function useIsMobile() {
    return useMediaQuery("(max-width: 768px)");
}

export function useIsDesktop() {
    return useMediaQuery("(min-width: 1024px)");
}