// frontend/src/components/manga/MangaCard.jsx
import { Link } from "react-router-dom";
import { useState } from "react";
import { STATUS_MAP } from "@/lib/constants";
import { cn, proxyImage } from "@/lib/utils";
import { ImageOff } from "lucide-react";

export function MangaCard({ manga, className }) {
    const [loaded, setLoaded] = useState(false);
    const [error, setError] = useState(false);

    const statusInfo = STATUS_MAP[manga.status];
    const imgSrc = proxyImage(manga.cover_url);
    const genres = manga.tags?.slice(0, 2) || [];
    const year = manga.year || "";
    const score = manga.score ? Number(manga.score).toFixed(1) : null;

    return (
        <Link
            to={`/manga/${manga.id}`}
            className={cn(
                "group block relative cursor-pointer",
                "rounded-lg overflow-hidden",
                "transition-transform duration-300 ease-out",
                "hover:scale-[1.03] hover:z-10",
                "focus-visible:outline-2 focus-visible:outline-primary focus-visible:outline-offset-2",
                className
            )}
            aria-label={`View ${manga.title}`}
        >
            {/* Poster Container */}
            <div className="relative w-full aspect-[2/3] bg-muted rounded-lg overflow-hidden border border-border/20 group-hover:border-border/40 transition-colors">
                {/* Image */}
                {imgSrc && !error ? (
                    <img
                        src={imgSrc}
                        alt={manga.title}
                        loading="lazy"
                        onLoad={() => setLoaded(true)}
                        onError={() => setError(true)}
                        className={cn(
                            "absolute inset-0 w-full h-full object-cover",
                            "transition-opacity duration-300",
                            loaded ? "opacity-100" : "opacity-0"
                        )}
                    />
                ) : null}

                {/* Loading/Error State */}
                {(!loaded || error || !imgSrc) && (
                    <div className="absolute inset-0 flex items-center justify-center bg-muted">
                        {error || !imgSrc ? (
                            <ImageOff className="h-8 w-8 text-muted-foreground/30" />
                        ) : (
                            <div className="w-full h-full bg-gradient-to-r from-muted via-muted-foreground/5 to-muted animate-pulse" />
                        )}
                    </div>
                )}

                {/* Status Badge (top-left) */}
                {statusInfo && (
                    <div
                        className={cn(
                            "absolute top-2 left-2 z-10",
                            "px-2 py-0.5 rounded",
                            "text-[10px] font-semibold uppercase tracking-wider",
                            "bg-black/70 text-white",
                            "backdrop-blur-sm"
                        )}
                    >
                        {statusInfo.label}
                    </div>
                )}

                {/* Rating Badge (bottom-right) */}
                {score && (
                    <div className="absolute bottom-0 inset-x-0 z-10 bg-gradient-to-t from-black/80 to-transparent p-2 pt-6">
                        <div className="flex justify-end">
                            <div
                                className={cn(
                                    "flex items-center gap-1",
                                    "px-1.5 py-0.5 rounded",
                                    "text-[11px] font-semibold",
                                    "bg-black/60 text-amber-400"
                                )}
                            >
                                <svg
                                    viewBox="0 0 24 24"
                                    className="w-3 h-3 fill-amber-400"
                                    aria-hidden="true"
                                >
                                    <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z" />
                                </svg>
                                <span>{score}</span>
                            </div>
                        </div>
                    </div>
                )}
            </div>

            {/* Card Info */}
            <div className="pt-2 pb-1 space-y-1">
                {/* Title */}
                <h3
                    className={cn(
                        "text-sm font-medium leading-tight",
                        "line-clamp-2",
                        "text-foreground",
                        "group-hover:text-primary transition-colors duration-200"
                    )}
                >
                    {manga.title}
                </h3>

                {/* Meta: year, author */}
                {(year || manga.author) && (
                    <p className="text-xs text-muted-foreground truncate">
                        {year}
                        {year && manga.author && " • "}
                        {manga.author}
                    </p>
                )}

                {/* Genre Chips */}
                {genres.length > 0 && (
                    <div className="flex flex-wrap gap-1 pt-0.5">
                        {genres.map((tag) => (
                            <span
                                key={tag}
                                className={cn(
                                    "px-1.5 py-0.5 rounded",
                                    "text-[10px]",
                                    "bg-muted text-muted-foreground",
                                    "group-hover:bg-accent group-hover:text-accent-foreground",
                                    "transition-colors duration-200"
                                )}
                            >
                                {tag}
                            </span>
                        ))}
                    </div>
                )}
            </div>
        </Link>
    );
}