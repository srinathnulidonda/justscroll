// frontend/src/components/common/GenreToolbar.jsx
import { useRef, useState, useEffect } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { cn } from "@/lib/utils";

const GENRES = [
    { key: "all", label: "All" },
    { key: "action", label: "Action" },
    { key: "adventure", label: "Adventure" },
    { key: "comedy", label: "Comedy" },
    { key: "drama", label: "Drama" },
    { key: "fantasy", label: "Fantasy" },
    { key: "horror", label: "Horror" },
    { key: "mystery", label: "Mystery" },
    { key: "romance", label: "Romance" },
    { key: "sci-fi", label: "Sci-Fi" },
    { key: "slice-of-life", label: "Slice of Life" },
    { key: "sports", label: "Sports" },
    { key: "supernatural", label: "Supernatural" },
    { key: "thriller", label: "Thriller" },
    { key: "isekai", label: "Isekai" },
    { key: "mecha", label: "Mecha" },
    { key: "psychological", label: "Psychological" },
    { key: "shounen", label: "Shounen" },
    { key: "shoujo", label: "Shoujo" },
    { key: "seinen", label: "Seinen" },
    { key: "josei", label: "Josei" },
    { key: "martial-arts", label: "Martial Arts" },
    { key: "historical", label: "Historical" },
    { key: "music", label: "Music" },
    { key: "school", label: "School Life" },
];

export function GenreToolbar({ activeGenre, onGenreChange }) {
    const scrollRef = useRef(null);
    const activeRef = useRef(null);
    const [showLeftArrow, setShowLeftArrow] = useState(false);
    const [showRightArrow, setShowRightArrow] = useState(false);

    const checkArrows = () => {
        const el = scrollRef.current;
        if (!el) return;
        setShowLeftArrow(el.scrollLeft > 5);
        setShowRightArrow(el.scrollLeft < el.scrollWidth - el.clientWidth - 5);
    };

    useEffect(() => {
        checkArrows();
        const el = scrollRef.current;
        if (!el) return;
        el.addEventListener("scroll", checkArrows, { passive: true });
        window.addEventListener("resize", checkArrows);
        return () => {
            el.removeEventListener("scroll", checkArrows);
            window.removeEventListener("resize", checkArrows);
        };
    }, []);

    useEffect(() => {
        if (activeRef.current) {
            activeRef.current.scrollIntoView({
                behavior: "smooth",
                block: "nearest",
                inline: "center",
            });
        }
    }, [activeGenre]);

    const scroll = (direction) => {
        const el = scrollRef.current;
        if (!el) return;
        el.scrollBy({
            left: direction === "left" ? -200 : 200,
            behavior: "smooth",
        });
    };

    return (
        <div
            className={cn(
                "sticky top-14 z-30",
                "bg-background/90 backdrop-blur-xl",
                "border-b border-border/40"
            )}
        >
            <div className="mx-auto max-w-site relative">
                {showLeftArrow && (
                    <button
                        onClick={() => scroll("left")}
                        className={cn(
                            "hidden md:flex",
                            "absolute left-0 top-0 bottom-0 z-10",
                            "items-center justify-center w-10",
                            "bg-gradient-to-r from-background via-background/80 to-transparent",
                            "text-muted-foreground hover:text-foreground"
                        )}
                        aria-label="Scroll left"
                    >
                        <ChevronLeft className="h-4 w-4" />
                    </button>
                )}

                <div
                    ref={scrollRef}
                    className={cn(
                        "flex items-center",
                        "gap-1 sm:gap-1.5",
                        "px-3 sm:px-4 md:px-6 lg:px-8",
                        "py-2 sm:py-2.5",
                        "overflow-x-auto scrollbar-none",
                        "-webkit-overflow-scrolling-touch"
                    )}
                    role="tablist"
                    aria-label="Filter by genre"
                >
                    {GENRES.map((genre) => {
                        const isActive = activeGenre === genre.key;
                        return (
                            <button
                                key={genre.key}
                                ref={isActive ? activeRef : null}
                                role="tab"
                                aria-selected={isActive}
                                onClick={() => onGenreChange(genre.key)}
                                className={cn(
                                    "flex-shrink-0",
                                    "px-2.5 sm:px-3 md:px-3.5",
                                    "py-1 sm:py-1.5",
                                    "rounded-full",
                                    "text-[11px] sm:text-xs md:text-[13px]",
                                    "font-medium whitespace-nowrap",
                                    "border transition-all duration-200",
                                    "active:scale-95",
                                    isActive
                                        ? "bg-primary text-primary-foreground border-primary shadow-sm"
                                        : "bg-transparent text-muted-foreground border-border/50 hover:text-foreground hover:border-foreground/20 hover:bg-muted/40"
                                )}
                            >
                                {genre.label}
                            </button>
                        );
                    })}
                </div>

                {showRightArrow && (
                    <button
                        onClick={() => scroll("right")}
                        className={cn(
                            "hidden md:flex",
                            "absolute right-0 top-0 bottom-0 z-10",
                            "items-center justify-center w-10",
                            "bg-gradient-to-l from-background via-background/80 to-transparent",
                            "text-muted-foreground hover:text-foreground"
                        )}
                        aria-label="Scroll right"
                    >
                        <ChevronRight className="h-4 w-4" />
                    </button>
                )}
            </div>
        </div>
    );
}