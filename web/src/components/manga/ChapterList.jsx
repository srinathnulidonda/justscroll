// frontend/src/components/manga/ChapterList.jsx
import { useState, useMemo } from "react";
import { Link } from "react-router-dom";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import { Skeleton } from "@/components/ui/Skeleton";
import { EmptyState } from "@/components/common/EmptyState";
import {
    Search,
    FileX,
    ArrowUpDown,
    BookOpen,
    ExternalLink,
} from "lucide-react";
import { chapterLabel, formatDate, cn } from "@/lib/utils";

const INITIAL_COUNT = 20;
const LOAD_MORE_COUNT = 20;

export function ChapterList({ chapters, loading, mangaId }) {
    const [search, setSearch] = useState("");
    const [sortAsc, setSortAsc] = useState(false);
    const [visibleCount, setVisibleCount] = useState(INITIAL_COUNT);

    const filtered = useMemo(() => {
        let list = chapters || [];
        if (search.trim()) {
            const q = search.toLowerCase();
            list = list.filter(
                (ch) =>
                    ch.chapter?.toLowerCase().includes(q) ||
                    ch.title?.toLowerCase().includes(q) ||
                    ch.scanlation_group?.toLowerCase().includes(q)
            );
        }
        if (sortAsc) list = [...list].reverse();
        return list;
    }, [chapters, search, sortAsc]);

    const visibleChapters = filtered.slice(0, visibleCount);
    const hasMore = visibleCount < filtered.length;

    if (loading) {
        return (
            <div className="space-y-1.5">
                {Array.from({ length: 8 }).map((_, i) => (
                    <Skeleton key={i} className="h-14 sm:h-16 rounded-lg" />
                ))}
            </div>
        );
    }

    return (
        <div className="space-y-3">
            {/* Toolbar */}
            <div className="flex items-center gap-2">
                <div className="flex-1">
                    <Input
                        placeholder="Search chapters…"
                        value={search}
                        onChange={(e) => {
                            setSearch(e.target.value);
                            setVisibleCount(INITIAL_COUNT);
                        }}
                        icon={Search}
                        className="h-8 sm:h-9 text-[13px] sm:text-sm"
                    />
                </div>
                <Button
                    variant="outline"
                    size="icon-sm"
                    onClick={() => setSortAsc(!sortAsc)}
                    aria-label={sortAsc ? "Sort descending" : "Sort ascending"}
                    className="h-8 w-8 sm:h-9 sm:w-9"
                >
                    <ArrowUpDown className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                </Button>
                <Badge variant="secondary" className="whitespace-nowrap text-[10px] sm:text-xs h-6 sm:h-7">
                    {chapters?.length || 0}
                </Badge>
            </div>

            {/* Empty */}
            {!filtered.length ? (
                <EmptyState
                    icon={FileX}
                    title="No chapters available"
                    description={
                        search
                            ? "Try a different search term"
                            : "This title may be external-only or hasn't been uploaded yet."
                    }
                />
            ) : (
                <>
                    {/* Chapter list — no fixed height, no ScrollArea */}
                    <div className="space-y-1">
                        {visibleChapters.map((ch) => {
                            const readable =
                                ch.readable !== false && ch.pages > 0;
                            return (
                                <div key={ch.id}>
                                    {readable ? (
                                        <Link
                                            to={`/read/${ch.id}?manga=${mangaId}`}
                                            className={cn(
                                                "flex items-center gap-2.5 sm:gap-3",
                                                "rounded-lg px-2.5 sm:px-3 py-2.5 sm:py-3",
                                                "text-[13px] sm:text-sm",
                                                "hover:bg-accent",
                                                "active:scale-[0.99]",
                                                "transition-all duration-150",
                                                "group"
                                            )}
                                        >
                                            <div
                                                className={cn(
                                                    "flex items-center justify-center flex-shrink-0",
                                                    "w-7 h-7 sm:w-8 sm:h-8 rounded-lg",
                                                    "bg-primary/5 group-hover:bg-primary/10",
                                                    "transition-colors duration-150"
                                                )}
                                            >
                                                <BookOpen className="h-3.5 w-3.5 sm:h-4 sm:w-4 text-muted-foreground group-hover:text-primary transition-colors" />
                                            </div>
                                            <div className="flex-1 min-w-0">
                                                <p className="font-medium truncate group-hover:text-primary transition-colors">
                                                    {chapterLabel(ch)}
                                                </p>
                                                <div className="flex items-center gap-1.5 sm:gap-2 text-[10px] sm:text-xs text-muted-foreground mt-0.5">
                                                    {ch.scanlation_group && (
                                                        <span className="truncate max-w-[100px] sm:max-w-[150px]">
                                                            {ch.scanlation_group}
                                                        </span>
                                                    )}
                                                    {ch.pages > 0 && (
                                                        <span>{ch.pages}p</span>
                                                    )}
                                                    {ch.published_at && (
                                                        <span>
                                                            {formatDate(ch.published_at)}
                                                        </span>
                                                    )}
                                                </div>
                                            </div>
                                        </Link>
                                    ) : (
                                        <div
                                            className={cn(
                                                "flex items-center gap-2.5 sm:gap-3",
                                                "rounded-lg px-2.5 sm:px-3 py-2.5 sm:py-3",
                                                "text-[13px] sm:text-sm",
                                                "opacity-40 cursor-not-allowed"
                                            )}
                                        >
                                            <div className="flex items-center justify-center flex-shrink-0 w-7 h-7 sm:w-8 sm:h-8 rounded-lg bg-muted">
                                                <ExternalLink className="h-3.5 w-3.5 sm:h-4 sm:w-4 text-muted-foreground" />
                                            </div>
                                            <div className="flex-1 min-w-0">
                                                <p className="font-medium truncate">
                                                    {chapterLabel(ch)}
                                                </p>
                                                <p className="text-[10px] sm:text-xs text-muted-foreground mt-0.5">
                                                    External / Unavailable
                                                </p>
                                            </div>
                                        </div>
                                    )}
                                </div>
                            );
                        })}
                    </div>

                    {/* Load more */}
                    {hasMore && (
                        <div className="flex justify-center pt-2 pb-1">
                            <Button
                                variant="outline"
                                size="sm"
                                onClick={() =>
                                    setVisibleCount((c) => c + LOAD_MORE_COUNT)
                                }
                                className="text-xs sm:text-sm rounded-xl"
                            >
                                Load more ({filtered.length - visibleCount} remaining)
                            </Button>
                        </div>
                    )}
                </>
            )}
        </div>
    );
}