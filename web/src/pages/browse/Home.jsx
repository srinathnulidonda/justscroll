// frontend/src/pages/Home.jsx
import { useState, useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import { useNavigate } from "react-router-dom";
import { api } from "@/lib/api";
import { MangaGrid } from "@/components/manga/MangaGrid";
import { GenreToolbar } from "@/components/common/GenreToolbar";
import { Button } from "@/components/ui/Button";
import { ArrowRight, X } from "lucide-react";
import { cn } from "@/lib/utils";

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

function filterByGenre(items, genre) {
    if (!genre || genre === "all") return items;
    if (!items) return [];
    const genreLower = genre.toLowerCase().replace(/-/g, " ");
    return items.filter((item) => {
        const tags = item.tags || [];
        return tags.some((tag) => {
            const tagLower = (tag || "").toLowerCase();
            return (
                tagLower === genreLower ||
                tagLower.includes(genreLower) ||
                genreLower.includes(tagLower)
            );
        });
    });
}

function Section({ title, action, children }) {
    return (
        <section className="space-y-4">
            <div className="flex items-center justify-between">
                <h2 className="text-base sm:text-lg md:text-xl font-bold">
                    {title}
                </h2>
                {action}
            </div>
            {children}
        </section>
    );
}

export default function Home() {
    const navigate = useNavigate();
    const [activeGenre, setActiveGenre] = useState("all");

    const { data: popular, isLoading: loadingPopular } = useQuery({
        queryKey: ["home-popular"],
        queryFn: () => api.getPopular(30),
        staleTime: 5 * 60 * 1000,
        cacheTime: 10 * 60 * 1000,
    });

    const { data: latest, isLoading: loadingLatest } = useQuery({
        queryKey: ["home-latest"],
        queryFn: () => api.getLatestUpdates(20),
        staleTime: 3 * 60 * 1000,
        cacheTime: 10 * 60 * 1000,
    });

    const allPopular = useMemo(() => deduplicate(popular?.data), [popular]);
    const allLatest = useMemo(() => deduplicate(latest?.data), [latest]);

    const filteredPopular = useMemo(
        () => filterByGenre(allPopular, activeGenre),
        [allPopular, activeGenre]
    );

    const filteredLatest = useMemo(
        () => filterByGenre(allLatest, activeGenre),
        [allLatest, activeGenre]
    );

    const isFiltered = activeGenre !== "all";
    const totalResults = filteredPopular.length + filteredLatest.length;
    const hasResults = totalResults > 0;
    const genreLabel = activeGenre.replace(/-/g, " ");

    return (
        <div>
            {/* Sticky Genre Toolbar */}
            <GenreToolbar
                activeGenre={activeGenre}
                onGenreChange={setActiveGenre}
            />

            {/* Content */}
            <div className="mx-auto max-w-7xl px-4 sm:px-6 py-4 sm:py-6 md:py-8 space-y-6 sm:space-y-8 md:space-y-12">
                {/* Active filter indicator */}
                {isFiltered && (
                    <div className="flex items-center justify-between gap-2">
                        <p className="text-xs sm:text-sm text-muted-foreground leading-tight">
                            <span className="capitalize font-medium text-foreground">
                                {genreLabel}
                            </span>
                            {!loadingPopular && (
                                <span className="text-muted-foreground">
                                    {" "}
                                    · {totalResults}{" "}
                                    {totalResults === 1 ? "result" : "results"}
                                </span>
                            )}
                        </p>
                        <button
                            onClick={() => setActiveGenre("all")}
                            className={cn(
                                "flex items-center gap-1 flex-shrink-0",
                                "px-2 py-1 rounded-md",
                                "text-[11px] sm:text-xs",
                                "text-muted-foreground",
                                "hover:text-foreground hover:bg-muted",
                                "active:scale-95",
                                "transition-all duration-150"
                            )}
                        >
                            <X className="h-3 w-3" />
                            <span className="hidden xs:inline">Clear</span>
                        </button>
                    </div>
                )}

                {/* No results */}
                {isFiltered &&
                    !loadingPopular &&
                    !loadingLatest &&
                    !hasResults && (
                        <div className="flex flex-col items-center justify-center py-12 sm:py-16 text-center px-4">
                            <p className="text-sm sm:text-base font-medium mb-1">
                                No {genreLabel} manga found
                            </p>
                            <p className="text-xs sm:text-sm text-muted-foreground mb-4">
                                Try a different genre
                            </p>
                            <Button
                                variant="outline"
                                size="sm"
                                onClick={() => setActiveGenre("all")}
                            >
                                Show all
                            </Button>
                        </div>
                    )}

                {/* Popular Section */}
                {(filteredPopular.length > 0 ||
                    loadingPopular ||
                    !isFiltered) && (
                        <Section
                            title="Popular Now"
                            action={
                                <Button
                                    variant="ghost"
                                    size="sm"
                                    onClick={() => navigate("/discover")}
                                    className="gap-1 text-xs sm:text-sm text-muted-foreground hover:text-foreground"
                                >
                                    <span className="hidden xs:inline">
                                        View all
                                    </span>
                                    <span className="xs:hidden">All</span>
                                    <ArrowRight className="h-3 w-3 sm:h-3.5 sm:w-3.5" />
                                </Button>
                            }
                        >
                            <MangaGrid
                                manga={isFiltered ? filteredPopular : allPopular}
                                loading={loadingPopular}
                                emptyTitle={
                                    isFiltered
                                        ? `No popular ${genreLabel} manga`
                                        : "No popular manga found"
                                }
                                emptyDescription="Try a different genre or check back later"
                            />
                        </Section>
                    )}

                {/* Latest Updates Section */}
                {(filteredLatest.length > 0 ||
                    loadingLatest ||
                    !isFiltered) && (
                        <Section
                            title="Latest Updates"
                            action={
                                <Button
                                    variant="ghost"
                                    size="sm"
                                    onClick={() =>
                                        navigate("/discover?tab=latest")
                                    }
                                    className="gap-1 text-xs sm:text-sm text-muted-foreground hover:text-foreground"
                                >
                                    <span className="hidden xs:inline">
                                        View all
                                    </span>
                                    <span className="xs:hidden">All</span>
                                    <ArrowRight className="h-3 w-3 sm:h-3.5 sm:w-3.5" />
                                </Button>
                            }
                        >
                            <MangaGrid
                                manga={isFiltered ? filteredLatest : allLatest}
                                loading={loadingLatest}
                                emptyTitle={
                                    isFiltered
                                        ? `No latest ${genreLabel} manga`
                                        : "No latest updates"
                                }
                                emptyDescription="Try a different genre or check back later"
                            />
                        </Section>
                    )}
            </div>
        </div>
    );
}