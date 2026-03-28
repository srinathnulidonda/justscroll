// frontend/src/lib/constants.js
export const SOURCES = {
    mangadex: { label: "MangaDex", color: "bg-orange-500/10 text-orange-500" },
    mal: { label: "MyAnimeList", color: "bg-blue-500/10 text-blue-500" },
    comicvine: { label: "ComicVine", color: "bg-green-500/10 text-green-500" },
};

export const STATUS_MAP = {
    ongoing: { label: "Ongoing", color: "bg-emerald-500/10 text-emerald-400" },
    completed: { label: "Completed", color: "bg-blue-500/10 text-blue-400" },
    hiatus: { label: "Hiatus", color: "bg-amber-500/10 text-amber-400" },
    cancelled: { label: "Cancelled", color: "bg-red-500/10 text-red-400" },
    Publishing: { label: "Ongoing", color: "bg-emerald-500/10 text-emerald-400" },
    Finished: { label: "Completed", color: "bg-blue-500/10 text-blue-400" },
    "On Hiatus": { label: "Hiatus", color: "bg-amber-500/10 text-amber-400" },
};

export const QUALITY_OPTIONS = [
    { value: "data", label: "High Quality" },
    { value: "dataSaver", label: "Data Saver" },
];

export const READING_MODES = [
    { value: "single", label: "Single Page" },
    { value: "continuous", label: "Continuous Scroll" },
];