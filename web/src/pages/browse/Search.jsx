// frontend/src/pages/Search.jsx
import { useState, useMemo } from "react";
import { useSearchParams, useNavigate } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { MangaGrid } from "@/components/manga/MangaGrid";
import { Button } from "@/components/ui/Button";
import {
    Search as SearchIcon,
    X,
    Loader2,
    ChevronLeft,
    ChevronRight,
    Compass,
} from "lucide-react";
import { cn } from "@/lib/utils";

const LIMIT = 24;

function deduplicate(items) {
    if (!items) return [];
    const seen = new Set();
    return items.filter((item) => {
        const titleKey = (item.title || "").toLowerCase().trim();
        const idKey = item.id || "";
        if (seen.has(idKey)) return false;
        if (titleKey && seen.has(titleKey)) return false;
        seen.add(idKey);
        if (titleKey) seen.add(titleKey);
        return true;
    });
}

function generatePageNumbers(current, total) {
    if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);
    const pages = [1];
    if (current > 3) pages.push("...");
    const start = Math.max(2, current - 1);
    const end = Math.min(total - 1, current + 1);
    for (let i = start; i <= end; i++) pages.push(i);
    if (current < total - 2) pages.push("...");
    if (total > 1) pages.push(total);
    return pages;
}

export default function SearchPage() {
    const [searchParams, setSearchParams] = useSearchParams();
    const navigate = useNavigate();
    const query = searchParams.get("q") || "";
    const [searchInput, setSearchInput] = useState(query);
    const [offset, setOffset] = useState(0);

    const { data, isLoading, isFetching } = useQuery({
        queryKey: ["search", query, offset],
        queryFn: () => api.searchManga(query, LIMIT, offset),
        enabled: !!query,
        staleTime: 3 * 60 * 1000,
        keepPreviousData: true,
    });

    const uniqueData = useMemo(() => deduplicate(data?.data), [data]);
    const total = data?.total || 0;
    const totalPages = Math.ceil(total / LIMIT);
    const currentPage = Math.floor(offset / LIMIT) + 1;

    const handleSearch = (e) => {
        e.preventDefault();
        const q = searchInput.trim();
        if (q) {
            setSearchParams({ q }, { replace: true });
            setOffset(0);
        }
    };

    const handleClear = () => {
        setSearchInput("");
        setSearchParams({}, { replace: true });
        setOffset(0);
    };

    /* ---------- No query: Search prompt ---------- */
    if (!query) {
        return (
            <div className="mx-auto max-w-7xl px-4 sm:px-6 py-6 md:py-10">
                <div className="flex flex-col items-center justify-center py-16 sm:py-24 text-center">
                    <div className="mb-6 rounded-2xl bg-muted p-5">
                        <SearchIcon className="h-10 w-10 text-muted-foreground/60" />
                    </div>
                    <h1 className="text-2xl md:text-3xl font-bold mb-2">
                        Search Manga
                    </h1>
                    <p className="text-sm text-muted-foreground mb-8 max-w-sm">
                        Search across thousands of manga, manhwa, and comic
                        titles
                    </p>
                    <form
                        onSubmit={handleSearch}
                        className="w-full max-w-md relative"
                    >
                        <SearchIcon className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground pointer-events-none" />
                        <input
                            type="text"
                            value={searchInput}
                            onChange={(e) => setSearchInput(e.target.value)}
                            placeholder="Type a title and press Enter…"
                            autoFocus
                            className={cn(
                                "w-full h-12 pl-12 pr-4 rounded-xl",
                                "border border-border bg-card",
                                "text-base placeholder:text-muted-foreground/50",
                                "focus:outline-none focus:ring-2 focus:ring-ring/40 focus:border-primary/50",
                                "transition-all duration-200"
                            )}
                        />
                    </form>

                    <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => navigate("/discover")}
                        className="mt-6 gap-2 text-muted-foreground hover:text-foreground"
                    >
                        <Compass className="h-4 w-4" />
                        Or browse popular &amp; latest manga
                    </Button>
                </div>
            </div>
        );
    }

    /* ---------- Has query: Search results ---------- */
    return (
        <div className="mx-auto max-w-7xl px-4 sm:px-6 py-6 md:py-10">
            {/* Header */}
            <div className="mb-8 space-y-3">
                <h1 className="text-2xl md:text-3xl font-bold tracking-tight">
                    Search Results
                </h1>
                <div className="flex items-center gap-2 flex-wrap">
                    <div className="inline-flex items-center gap-2 rounded-lg bg-muted border border-border/50 px-3 py-1.5 text-sm">
                        <SearchIcon className="h-3.5 w-3.5 text-muted-foreground" />
                        <span className="text-muted-foreground">
                            Results for{" "}
                            <span className="font-medium text-foreground">
                                "{query}"
                            </span>
                        </span>
                        <button
                            onClick={handleClear}
                            className="ml-1 rounded p-0.5 text-muted-foreground hover:text-foreground hover:bg-accent transition-colors"
                            aria-label="Clear search"
                        >
                            <X className="h-3.5 w-3.5" />
                        </button>
                    </div>
                </div>
            </div>

            {/* Results count */}
            {!isLoading && uniqueData.length > 0 && (
                <div className="flex items-center gap-3 mb-5">
                    <p className="text-sm text-muted-foreground">
                        <span className="font-medium text-foreground">
                            {uniqueData.length}
                        </span>{" "}
                        titles
                        {totalPages > 1 && (
                            <span className="ml-1">
                                · Page {currentPage} of {totalPages}
                            </span>
                        )}
                    </p>
                    {isFetching && !isLoading && (
                        <Loader2 className="h-3.5 w-3.5 animate-spin text-muted-foreground" />
                    )}
                </div>
            )}

            {/* Grid */}
            <MangaGrid
                manga={uniqueData}
                loading={isLoading}
                emptyTitle={`No results for "${query}"`}
                emptyDescription="Try a different search term or check the spelling"
                emptyAction={handleClear}
                emptyActionLabel="Clear search"
            />

            {/* Pagination */}
            {totalPages > 1 && !isLoading && (
                <div className="flex items-center justify-center gap-1 mt-10">
                    <Button
                        variant="outline"
                        size="sm"
                        disabled={offset === 0 || isFetching}
                        onClick={() => setOffset(Math.max(0, offset - LIMIT))}
                        className="gap-1"
                    >
                        <ChevronLeft className="h-4 w-4" />
                        <span className="hidden sm:inline">Previous</span>
                    </Button>

                    <div className="flex items-center gap-1 mx-2">
                        {generatePageNumbers(currentPage, totalPages).map(
                            (page, i) =>
                                page === "..." ? (
                                    <span
                                        key={`dots-${i}`}
                                        className="px-2 py-1 text-sm text-muted-foreground"
                                    >
                                        …
                                    </span>
                                ) : (
                                    <button
                                        key={page}
                                        onClick={() =>
                                            setOffset((page - 1) * LIMIT)
                                        }
                                        disabled={isFetching}
                                        className={cn(
                                            "h-8 min-w-[2rem] rounded-lg text-sm font-medium transition-colors",
                                            page === currentPage
                                                ? "bg-primary text-primary-foreground shadow-sm"
                                                : "text-muted-foreground hover:bg-muted hover:text-foreground"
                                        )}
                                    >
                                        {page}
                                    </button>
                                )
                        )}
                    </div>

                    <Button
                        variant="outline"
                        size="sm"
                        disabled={currentPage >= totalPages || isFetching}
                        onClick={() => setOffset(offset + LIMIT)}
                        className="gap-1"
                    >
                        <span className="hidden sm:inline">Next</span>
                        <ChevronRight className="h-4 w-4" />
                    </Button>
                </div>
            )}
        </div>
    );
}