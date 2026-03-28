// frontend/src/lib/utils.js
import { clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs) {
    return twMerge(clsx(inputs));
}

export function proxyImage(url) {
    if (!url) return null;
    const base = import.meta.env.VITE_API_URL || "";
    return `${base}/api/v1/proxy/image?url=${encodeURIComponent(url)}`;
}

export function truncate(str, length = 120) {
    if (!str) return "";
    if (str.length <= length) return str;
    return str.slice(0, length).trimEnd() + "…";
}

export function stripHtml(html) {
    if (!html) return "";
    return html.replace(/<[^>]*>/g, "").trim();
}

export function formatDate(dateStr) {
    if (!dateStr) return "";
    const d = new Date(dateStr);
    const now = new Date();
    const diff = now - d;
    const mins = Math.floor(diff / 60000);
    if (mins < 1) return "Just now";
    if (mins < 60) return `${mins}m ago`;
    const hours = Math.floor(mins / 60);
    if (hours < 24) return `${hours}h ago`;
    const days = Math.floor(hours / 24);
    if (days < 7) return `${days}d ago`;
    return d.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" });
}

export function chapterLabel(ch) {
    if (!ch) return "Chapter ?";
    const num = ch.chapter;
    const title = ch.title;
    let label = num ? `Ch. ${num}` : "Oneshot";
    if (title) label += ` — ${title}`;
    return label;
}

export function sleep(ms) {
    return new Promise((r) => setTimeout(r, ms));
}