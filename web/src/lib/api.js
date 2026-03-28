// frontend/src/lib/api.js
const BASE = import.meta.env.VITE_API_URL || "";

class ApiError extends Error {
    constructor(message, status, data) {
        super(message);
        this.status = status;
        this.data = data;
    }
}

async function request(path, options = {}) {
    const { body, headers: extraHeaders, auth = false, ...rest } = options;
    const headers = { ...extraHeaders };

    if (body && !(body instanceof FormData)) {
        headers["Content-Type"] = "application/json";
    }

    if (auth) {
        const token = localStorage.getItem("access_token");
        if (!token) {
            throw new ApiError("Not authenticated", 401, null);
        }
        headers["Authorization"] = `Bearer ${token}`;
    }

    let res;
    try {
        res = await fetch(`${BASE}${path}`, {
            ...rest,
            headers,
            body: body
                ? typeof body === "string"
                    ? body
                    : JSON.stringify(body)
                : undefined,
        });
    } catch (err) {
        throw new ApiError(
            "Network error. Please check your connection.",
            0,
            null
        );
    }

    // Handle 401 - try refresh
    if (res.status === 401 && auth) {
        const refreshed = await tryRefresh();
        if (refreshed) {
            headers["Authorization"] = `Bearer ${localStorage.getItem("access_token")}`;
            res = await fetch(`${BASE}${path}`, {
                ...rest,
                headers,
                body: body ? JSON.stringify(body) : undefined,
            });
        } else {
            // Refresh failed - clear auth state
            clearAuthData();
            throw new ApiError("Session expired. Please sign in again.", 401, null);
        }
    }

    if (res.status === 204) return null;

    const data = await res.json().catch(() => null);

    if (!res.ok) {
        throw new ApiError(
            data?.detail || `Request failed (${res.status})`,
            res.status,
            data
        );
    }

    return data;
}

async function tryRefresh() {
    const refresh = localStorage.getItem("refresh_token");
    if (!refresh) return false;

    try {
        const res = await fetch(`${BASE}/api/v1/auth/refresh`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ refresh_token: refresh }),
        });

        if (!res.ok) {
            clearAuthData();
            return false;
        }

        const data = await res.json();
        localStorage.setItem("access_token", data.access_token);
        localStorage.setItem("refresh_token", data.refresh_token);
        return true;
    } catch {
        clearAuthData();
        return false;
    }
}

function clearAuthData() {
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    localStorage.removeItem("user_data");
}

export const api = {
    // Auth
    register: (body) =>
        request("/api/v1/auth/register", { method: "POST", body }),
    login: (body) => request("/api/v1/auth/login", { method: "POST", body }),
    refresh: (body) =>
        request("/api/v1/auth/refresh", { method: "POST", body }),

    // Manga
    searchManga: (q, limit = 20, offset = 0) =>
        request(
            `/api/v1/manga/search?q=${encodeURIComponent(q)}&limit=${limit}&offset=${offset}`
        ),
    getPopular: (limit = 20, offset = 0) =>
        request(`/api/v1/manga/popular?limit=${limit}&offset=${offset}`),
    getLatestUpdates: (limit = 20, offset = 0) =>
        request(`/api/v1/manga/latest-updates?limit=${limit}&offset=${offset}`),
    getMangaDetail: (id) => request(`/api/v1/manga/${id}`),
    getMangaChapters: (id, lang = "en") =>
        request(`/api/v1/manga/${id}/chapters?lang=${lang}&limit=10000`),
    getMangaCharacters: (id) => request(`/api/v1/manga/${id}/characters`),

    // Chapters
    getChapterPages: (chapterId, quality = "data") =>
        request(`/api/v1/chapters/${chapterId}/pages?quality=${quality}`),

    // User
    getBookmarks: () => request("/api/v1/user/bookmarks", { auth: true }),
    addBookmark: (mangaId, body) =>
        request(`/api/v1/user/bookmarks/${mangaId}`, {
            method: "POST",
            body,
            auth: true,
        }),
    removeBookmark: (mangaId) =>
        request(`/api/v1/user/bookmarks/${mangaId}`, {
            method: "DELETE",
            auth: true,
        }),
    getHistory: () => request("/api/v1/user/history", { auth: true }),
    updateHistory: (body) =>
        request("/api/v1/user/history", { method: "POST", body, auth: true }),
};

export { ApiError };