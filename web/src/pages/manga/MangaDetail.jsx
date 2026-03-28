// frontend/src/pages/MangaDetail.jsx
import { useParams, useNavigate } from "react-router-dom";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { useAuthStore } from "@/stores/authStore";
import { toast } from "@/stores/toastStore";
import { OptimizedImage } from "@/components/common/OptimizedImage";
import { ChapterList } from "@/components/manga/ChapterList";
import { CharacterGrid } from "@/components/manga/CharacterCard";
import { ShareSheet } from "@/components/common/ShareSheet";
import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/Tabs";
import { EmptyState } from "@/components/common/EmptyState";
import { SOURCES, STATUS_MAP } from "@/lib/constants";
import { stripHtml, cn, proxyImage } from "@/lib/utils";
import {
    BookmarkPlus,
    BookmarkCheck,
    BookOpen,
    Star,
    Users,
    Calendar,
    User,
    Palette,
    AlertCircle,
    ChevronDown,
    ChevronUp,
    Eye,
    Hash,
    Globe,
    ArrowLeft,
    Share2,
} from "lucide-react";
import { useState, useEffect, useRef } from "react";
import { motion } from "framer-motion";

/* ───────── Skeleton ───────── */

function DetailSkeleton() {
    return (
        <div className="animate-pulse">
            <div className="relative h-44 sm:h-64 md:h-72 lg:h-80 bg-muted" />
            <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
                <div className="relative -mt-16 sm:-mt-24 md:-mt-28 flex flex-col sm:flex-row gap-4 sm:gap-8 lg:gap-10">
                    <div className="w-28 sm:w-48 md:w-56 lg:w-64 aspect-[2/3] rounded-xl bg-muted/80 border-4 border-background flex-shrink-0 mx-auto sm:mx-0" />
                    <div className="flex-1 pt-1 sm:pt-8 space-y-4">
                        <div className="h-6 sm:h-8 lg:h-9 w-3/4 bg-muted rounded mx-auto sm:mx-0" />
                        <div className="h-4 lg:h-5 w-1/3 bg-muted rounded mx-auto sm:mx-0" />
                        <div className="flex gap-2 justify-center sm:justify-start">
                            <div className="h-5 lg:h-6 w-16 bg-muted rounded-full" />
                            <div className="h-5 lg:h-6 w-14 bg-muted rounded-full" />
                        </div>
                        <div className="h-16 lg:h-20 w-full bg-muted rounded" />
                        <div className="flex gap-3 justify-center sm:justify-start pt-2">
                            <div className="h-9 sm:h-10 lg:h-11 w-36 bg-muted rounded-xl" />
                            <div className="h-9 sm:h-10 lg:h-11 w-28 bg-muted rounded-xl" />
                        </div>
                    </div>
                </div>
                <div className="grid grid-cols-3 sm:grid-cols-4 gap-2 sm:gap-3 lg:gap-4 mt-6 lg:mt-8">
                    {Array.from({ length: 4 }).map((_, i) => (
                        <div key={i} className="h-16 sm:h-20 lg:h-24 bg-muted rounded-xl" />
                    ))}
                </div>
            </div>
        </div>
    );
}

/* ───────── Stat Card ───────── */

function StatItem({ icon: Icon, label, value, color }) {
    if (!value) return null;
    return (
        <div
            className={cn(
                "flex flex-col items-center justify-center",
                "p-2.5 sm:p-4 lg:p-5 rounded-xl lg:rounded-2xl",
                "border border-border/40 bg-card",
                "hover:border-border/60 hover:shadow-soft",
                "transition-all duration-200",
                "text-center"
            )}
        >
            <Icon
                className={cn(
                    "h-3.5 w-3.5 sm:h-4 sm:w-4 lg:h-5 lg:w-5 mb-1 lg:mb-2",
                    color || "text-muted-foreground"
                )}
            />
            <span className="text-xs sm:text-base lg:text-lg font-bold leading-none">
                {value}
            </span>
            <span className="text-[9px] sm:text-[11px] lg:text-xs text-muted-foreground mt-0.5 lg:mt-1">
                {label}
            </span>
        </div>
    );
}

/* ───────── Info Row ───────── */

function InfoRow({ icon: Icon, label, value }) {
    if (!value) return null;
    return (
        <div className="flex items-center gap-2.5 lg:gap-3 py-2 lg:py-2.5 border-b border-border/20 last:border-0">
            <div
                className={cn(
                    "flex items-center justify-center flex-shrink-0",
                    "w-7 h-7 lg:w-9 lg:h-9 rounded-lg lg:rounded-xl",
                    "bg-muted"
                )}
            >
                <Icon className="h-3.5 w-3.5 lg:h-4 lg:w-4 text-muted-foreground" />
            </div>
            <div className="flex-1 min-w-0">
                <p className="text-[10px] lg:text-[11px] text-muted-foreground leading-none">
                    {label}
                </p>
                <p className="text-[13px] lg:text-sm font-medium truncate mt-0.5">
                    {value}
                </p>
            </div>
        </div>
    );
}

/* ───────── Tag Chip ───────── */

function TagChip({ tag, onClick }) {
    return (
        <button
            onClick={onClick}
            className={cn(
                "inline-flex items-center",
                "px-2 lg:px-3 py-0.5 lg:py-1 rounded-md lg:rounded-lg",
                "text-[11px] lg:text-xs font-medium",
                "bg-muted/60 text-muted-foreground",
                "border border-border/20",
                "hover:bg-accent hover:text-accent-foreground hover:border-border/50",
                "active:scale-95",
                "transition-all duration-150"
            )}
        >
            {tag}
        </button>
    );
}

/* ───────── Expandable Description ───────── */

function ExpandableDescription({ text }) {
    const [expanded, setExpanded] = useState(false);
    const [needsExpand, setNeedsExpand] = useState(false);
    const textRef = useRef(null);

    useEffect(() => {
        if (textRef.current) {
            setNeedsExpand(
                textRef.current.scrollHeight > textRef.current.clientHeight
            );
        }
    }, [text]);

    if (!text) return null;

    return (
        <div className="relative">
            <div
                ref={textRef}
                className={cn(
                    "text-[13px] sm:text-sm lg:text-[15px] text-muted-foreground leading-relaxed lg:leading-7",
                    "transition-all duration-300 ease-out",
                    !expanded && "line-clamp-3 sm:line-clamp-4"
                )}
            >
                {text}
            </div>
            {!expanded && needsExpand && (
                <div className="absolute bottom-0 left-0 right-0 h-6 bg-gradient-to-t from-card to-transparent pointer-events-none" />
            )}
            {needsExpand && (
                <button
                    onClick={() => setExpanded(!expanded)}
                    className={cn(
                        "flex items-center gap-1 mt-1.5",
                        "text-[11px] sm:text-xs lg:text-sm font-medium text-primary",
                        "hover:text-primary/80",
                        "transition-colors duration-150"
                    )}
                >
                    {expanded ? (
                        <>
                            Show less <ChevronUp className="h-3 w-3" />
                        </>
                    ) : (
                        <>
                            Read more <ChevronDown className="h-3 w-3" />
                        </>
                    )}
                </button>
            )}
        </div>
    );
}

/* ───────── Hero Banner ───────── */

function HeroBanner({ coverUrl, children }) {
    const proxiedUrl = proxyImage(coverUrl);
    return (
        <div className="relative overflow-hidden">
            <div className="absolute inset-0">
                {proxiedUrl && (
                    <img
                        src={proxiedUrl}
                        alt=""
                        className="w-full h-full object-cover scale-110 blur-2xl opacity-25 dark:opacity-15"
                        aria-hidden="true"
                    />
                )}
                <div className="absolute inset-0 bg-gradient-to-b from-background/50 via-background/70 to-background" />
            </div>
            <div className="relative">{children}</div>
        </div>
    );
}

/* ───────── Main Component ───────── */

export default function MangaDetail() {
    const { id } = useParams();
    const navigate = useNavigate();
    const { isAuthenticated } = useAuthStore();
    const queryClient = useQueryClient();
    const [shareOpen, setShareOpen] = useState(false);

    const { data: manga, isLoading, error } = useQuery({
        queryKey: ["manga", id],
        queryFn: () => api.getMangaDetail(id),
        staleTime: 10 * 60 * 1000,
    });

    const { data: chaptersData, isLoading: loadingChapters } = useQuery({
        queryKey: ["chapters", id],
        queryFn: () => api.getMangaChapters(id),
        enabled: !!id && !id.startsWith("mal-") && !id.startsWith("cv-"),
        staleTime: 5 * 60 * 1000,
    });

    const { data: charactersData, isLoading: loadingCharacters } = useQuery({
        queryKey: ["characters", id],
        queryFn: () => api.getMangaCharacters(id),
        staleTime: 60 * 60 * 1000,
    });

    const { data: bookmarks } = useQuery({
        queryKey: ["bookmarks"],
        queryFn: () => api.getBookmarks(),
        enabled: isAuthenticated,
    });

    const isBookmarked = bookmarks?.data?.some((b) => b.manga_id === id);

    const bookmarkMutation = useMutation({
        mutationFn: () => {
            if (isBookmarked) return api.removeBookmark(id);
            return api.addBookmark(id, {
                manga_title: manga?.title || "Unknown",
                cover_url: manga?.cover_url || null,
            });
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ["bookmarks"] });
            toast.success(isBookmarked ? "Bookmark removed" : "Bookmarked!");
        },
        onError: (err) =>
            toast.error(err.message || "Failed to update bookmark"),
    });

    const chapters = chaptersData?.data || [];
    const firstReadable = chapters.find(
        (ch) => ch.readable !== false && ch.pages > 0
    );

    if (isLoading) return <DetailSkeleton />;

    if (error || !manga) {
        return (
            <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-12">
                <EmptyState
                    icon={AlertCircle}
                    title="Manga not found"
                    description="This title may have been removed or the link is invalid."
                    action={() => navigate(-1)}
                    actionLabel="Go Back"
                />
            </div>
        );
    }

    const sourceInfo = SOURCES[manga.source] || SOURCES.mangadex;
    const statusInfo = STATUS_MAP[manga.status];
    const description = stripHtml(manga.description);
    const shareUrl =
        typeof window !== "undefined" ? window.location.href : "";

    const stats = [
        manga.score && {
            icon: Star,
            label: "Score",
            value: Number(manga.score).toFixed(1),
            color: "text-amber-500",
        },
        manga.members && {
            icon: Users,
            label: "Members",
            value:
                manga.members >= 1000
                    ? `${(manga.members / 1000).toFixed(1)}K`
                    : manga.members.toString(),
            color: "text-blue-500",
        },
        chapters.length > 0 && {
            icon: Hash,
            label: "Chapters",
            value: chapters.length.toString(),
            color: "text-emerald-500",
        },
        manga.year && {
            icon: Calendar,
            label: "Year",
            value: manga.year.toString(),
            color: "text-violet-500",
        },
    ].filter(Boolean);

    return (
        <>
            <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ duration: 0.3 }}
            >
                {/* ── Hero Section ── */}
                <HeroBanner coverUrl={manga.cover_url}>
                    {/* Top bar */}
                    <div className="mx-auto max-w-7xl px-3 sm:px-6 lg:px-8 pt-3 sm:pt-4 lg:pt-5 pb-1">
                        <div className="flex items-center justify-between">
                            <button
                                onClick={() => navigate(-1)}
                                className={cn(
                                    "flex items-center gap-1",
                                    "px-2.5 py-1.5 rounded-full",
                                    "text-[13px] font-medium",
                                    "bg-background/60 backdrop-blur-lg",
                                    "border border-border/30",
                                    "hover:bg-background/80",
                                    "active:scale-95",
                                    "transition-all duration-150"
                                )}
                            >
                                <ArrowLeft className="h-3.5 w-3.5" />
                                <span className="hidden sm:inline text-sm">
                                    Back
                                </span>
                            </button>
                            <button
                                onClick={() => setShareOpen(true)}
                                className={cn(
                                    "flex items-center justify-center",
                                    "w-8 h-8 rounded-full",
                                    "bg-background/60 backdrop-blur-lg",
                                    "border border-border/30",
                                    "hover:bg-background/80",
                                    "active:scale-95",
                                    "transition-all duration-150"
                                )}
                                aria-label="Share"
                            >
                                <Share2 className="h-3.5 w-3.5" />
                            </button>
                        </div>
                    </div>

                    {/* Cover + Title */}
                    <div className="mx-auto max-w-7xl px-3 sm:px-6 lg:px-8 pb-5 sm:pb-6 lg:pb-8 pt-3 sm:pt-4 lg:pt-6">
                        <div className="flex flex-col sm:flex-row gap-4 sm:gap-8 lg:gap-10 items-center sm:items-end">
                            {/* Cover */}
                            <motion.div
                                initial={{ opacity: 0, y: 16 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ duration: 0.4, delay: 0.1 }}
                            >
                                <div
                                    className={cn(
                                        "w-28 xs:w-32 sm:w-48 md:w-56 lg:w-64 flex-shrink-0",
                                        "rounded-xl lg:rounded-2xl overflow-hidden",
                                        "shadow-[0_6px_32px_rgba(0,0,0,0.25)]",
                                        "ring-1 ring-white/10 dark:ring-white/5"
                                    )}
                                >
                                    <OptimizedImage
                                        src={manga.cover_url}
                                        alt={manga.title}
                                        containerClassName="aspect-[2/3]"
                                        className="rounded-xl lg:rounded-2xl"
                                    />
                                </div>
                            </motion.div>

                            {/* Info */}
                            <motion.div
                                initial={{ opacity: 0, y: 16 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ duration: 0.4, delay: 0.2 }}
                                className="flex-1 flex flex-col space-y-2.5 lg:space-y-3.5 text-center sm:text-left w-full"
                            >
                                {/* Badges */}
                                <div className="flex flex-wrap items-center justify-center sm:justify-start gap-1.5 lg:gap-2">
                                    <Badge
                                        className={cn(
                                            sourceInfo.color,
                                            "text-[10px] lg:text-[11px] px-2 lg:px-2.5 py-0 lg:py-0.5"
                                        )}
                                    >
                                        {sourceInfo.label}
                                    </Badge>
                                    {statusInfo && (
                                        <Badge
                                            className={cn(
                                                statusInfo.color,
                                                "text-[10px] lg:text-[11px] px-2 lg:px-2.5 py-0 lg:py-0.5"
                                            )}
                                        >
                                            {statusInfo.label}
                                        </Badge>
                                    )}
                                    {manga.content_rating && (
                                        <Badge
                                            variant="outline"
                                            className="text-[10px] lg:text-[11px] px-2 lg:px-2.5 py-0 lg:py-0.5 capitalize"
                                        >
                                            {manga.content_rating}
                                        </Badge>
                                    )}
                                </div>

                                {/* Title */}
                                <h1 className="text-lg xs:text-xl sm:text-2xl md:text-3xl lg:text-4xl font-bold tracking-tight leading-tight">
                                    {manga.title}
                                </h1>

                                {/* Creators */}
                                <div className="flex flex-wrap items-center justify-center sm:justify-start gap-x-3 lg:gap-x-4 gap-y-0.5 text-[13px] lg:text-sm text-muted-foreground">
                                    {manga.author && (
                                        <span className="inline-flex items-center gap-1 lg:gap-1.5">
                                            <User className="h-3 w-3 lg:h-3.5 lg:w-3.5" />
                                            {manga.author}
                                        </span>
                                    )}
                                    {manga.artist &&
                                        manga.artist !== manga.author && (
                                            <span className="inline-flex items-center gap-1 lg:gap-1.5">
                                                <Palette className="h-3 w-3 lg:h-3.5 lg:w-3.5" />
                                                {manga.artist}
                                            </span>
                                        )}
                                </div>

                                {/* Quick score on desktop */}
                                {manga.score && (
                                    <div className="hidden lg:flex items-center gap-2 text-sm text-muted-foreground">
                                        <div className="flex items-center gap-1 text-amber-500">
                                            <Star className="h-4 w-4 fill-amber-500" />
                                            <span className="font-bold text-base">
                                                {Number(manga.score).toFixed(1)}
                                            </span>
                                        </div>
                                        {manga.members && (
                                            <>
                                                <span className="text-border">·</span>
                                                <span>
                                                    {manga.members.toLocaleString()} members
                                                </span>
                                            </>
                                        )}
                                    </div>
                                )}

                                {/* Actions */}
                                <div className="flex flex-wrap items-center justify-center sm:justify-start gap-2 lg:gap-3 pt-1 lg:pt-2">
                                    {firstReadable && (
                                        <Button
                                            size="md"
                                            onClick={() =>
                                                navigate(
                                                    `/read/${firstReadable.id}?manga=${id}`
                                                )
                                            }
                                            className={cn(
                                                "rounded-xl gap-1.5 shadow-md shadow-primary/20",
                                                "text-[13px] h-9",
                                                "sm:text-sm sm:h-10",
                                                "lg:text-base lg:h-11 lg:px-6 lg:gap-2"
                                            )}
                                        >
                                            <BookOpen className="h-3.5 w-3.5 sm:h-4 sm:w-4 lg:h-[18px] lg:w-[18px]" />
                                            Start Reading
                                        </Button>
                                    )}
                                    {isAuthenticated && (
                                        <Button
                                            variant={
                                                isBookmarked
                                                    ? "secondary"
                                                    : "outline"
                                            }
                                            size="md"
                                            loading={
                                                bookmarkMutation.isPending
                                            }
                                            onClick={() =>
                                                bookmarkMutation.mutate()
                                            }
                                            className={cn(
                                                "rounded-xl gap-1.5",
                                                "text-[13px] h-9",
                                                "sm:text-sm sm:h-10",
                                                "lg:text-base lg:h-11 lg:px-6 lg:gap-2"
                                            )}
                                        >
                                            {isBookmarked ? (
                                                <>
                                                    <BookmarkCheck className="h-3.5 w-3.5 sm:h-4 sm:w-4 lg:h-[18px] lg:w-[18px]" />
                                                    Saved
                                                </>
                                            ) : (
                                                <>
                                                    <BookmarkPlus className="h-3.5 w-3.5 sm:h-4 sm:w-4 lg:h-[18px] lg:w-[18px]" />
                                                    Save
                                                </>
                                            )}
                                        </Button>
                                    )}
                                    {!isAuthenticated && (
                                        <Button
                                            variant="outline"
                                            size="md"
                                            onClick={() =>
                                                navigate("/login", {
                                                    state: {
                                                        from: {
                                                            pathname: `/manga/${id}`,
                                                        },
                                                    },
                                                })
                                            }
                                            className={cn(
                                                "rounded-xl gap-1.5",
                                                "text-[13px] h-9",
                                                "sm:text-sm sm:h-10",
                                                "lg:text-base lg:h-11 lg:px-6 lg:gap-2"
                                            )}
                                        >
                                            <BookmarkPlus className="h-3.5 w-3.5 sm:h-4 sm:w-4 lg:h-[18px] lg:w-[18px]" />
                                            Save
                                        </Button>
                                    )}
                                </div>
                            </motion.div>
                        </div>
                    </div>
                </HeroBanner>

                {/* ── Main Content ── */}
                <div className="mx-auto max-w-7xl px-3 sm:px-6 lg:px-8">
                    {/* Stats */}
                    {stats.length > 0 && (
                        <motion.div
                            initial={{ opacity: 0, y: 12 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.3, delay: 0.25 }}
                            className={cn(
                                "grid gap-2 sm:gap-3 lg:gap-4 mt-5 sm:mt-6 lg:mt-8",
                                stats.length <= 2 && "grid-cols-2 max-w-xs lg:max-w-sm",
                                stats.length === 3 && "grid-cols-3 max-w-lg lg:max-w-xl",
                                stats.length >= 4 && "grid-cols-4"
                            )}
                        >
                            {stats.map((stat) => (
                                <StatItem key={stat.label} {...stat} />
                            ))}
                        </motion.div>
                    )}

                    {/* Two Column Layout */}
                    <motion.div
                        initial={{ opacity: 0, y: 12 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.3, delay: 0.3 }}
                        className="grid grid-cols-1 lg:grid-cols-12 gap-4 sm:gap-6 lg:gap-8 mt-5 sm:mt-8 lg:mt-10"
                    >
                        {/* Left: Synopsis + Tags */}
                        <div className="lg:col-span-8 space-y-4 sm:space-y-5 lg:space-y-6">
                            {description && (
                                <div className="rounded-xl lg:rounded-2xl border border-border/40 bg-card p-3.5 sm:p-5 lg:p-6">
                                    <h3 className="text-[10px] sm:text-xs lg:text-sm font-semibold text-muted-foreground uppercase tracking-wider mb-2.5 lg:mb-3">
                                        Synopsis
                                    </h3>
                                    <ExpandableDescription text={description} />
                                </div>
                            )}
                            {manga.tags?.length > 0 && (
                                <div className="rounded-xl lg:rounded-2xl border border-border/40 bg-card p-3.5 sm:p-5 lg:p-6">
                                    <h3 className="text-[10px] sm:text-xs lg:text-sm font-semibold text-muted-foreground uppercase tracking-wider mb-2.5 lg:mb-3">
                                        Genres & Tags
                                    </h3>
                                    <div className="flex flex-wrap gap-1.5 lg:gap-2">
                                        {manga.tags.map((tag) => (
                                            <TagChip
                                                key={tag}
                                                tag={tag}
                                                onClick={() =>
                                                    navigate(
                                                        `/search?q=${encodeURIComponent(tag)}`
                                                    )
                                                }
                                            />
                                        ))}
                                    </div>
                                </div>
                            )}
                        </div>

                        {/* Right: Info */}
                        <div className="lg:col-span-4 space-y-4 sm:space-y-5 lg:space-y-6">
                            <div className="rounded-xl lg:rounded-2xl border border-border/40 bg-card p-3.5 sm:p-5 lg:p-6">
                                <h3 className="text-[10px] sm:text-xs lg:text-sm font-semibold text-muted-foreground uppercase tracking-wider mb-2 lg:mb-3">
                                    Information
                                </h3>
                                <InfoRow
                                    icon={User}
                                    label="Author"
                                    value={manga.author}
                                />
                                {manga.artist &&
                                    manga.artist !== manga.author && (
                                        <InfoRow
                                            icon={Palette}
                                            label="Artist"
                                            value={manga.artist}
                                        />
                                    )}
                                <InfoRow
                                    icon={Eye}
                                    label="Status"
                                    value={
                                        statusInfo?.label || manga.status
                                    }
                                />
                                <InfoRow
                                    icon={Calendar}
                                    label="Year"
                                    value={manga.year?.toString()}
                                />
                                <InfoRow
                                    icon={Globe}
                                    label="Source"
                                    value={sourceInfo.label}
                                />
                                {manga.content_rating && (
                                    <InfoRow
                                        icon={Eye}
                                        label="Rating"
                                        value={
                                            manga.content_rating
                                                .charAt(0)
                                                .toUpperCase() +
                                            manga.content_rating.slice(1)
                                        }
                                    />
                                )}
                            </div>
                        </div>
                    </motion.div>

                    {/* ── Tabs ── */}
                    <motion.div
                        initial={{ opacity: 0, y: 12 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.3, delay: 0.35 }}
                        className="mt-6 sm:mt-8 lg:mt-10 mb-8 sm:mb-12 lg:mb-16"
                    >
                        <Tabs defaultValue="chapters">
                            <div className="overflow-x-auto scrollbar-none -mx-3 px-3 sm:mx-0 sm:px-0">
                                <TabsList className="w-full sm:w-auto">
                                    <TabsTrigger
                                        value="chapters"
                                        className="flex-1 sm:flex-none gap-1.5 text-[13px] sm:text-sm lg:text-base lg:px-6 lg:py-2.5"
                                    >
                                        <BookOpen className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                                        Chapters
                                        {chapters.length > 0 && (
                                            <span className="ml-0.5 px-1.5 py-0.5 rounded-md bg-muted text-[9px] sm:text-[10px] lg:text-[11px] font-semibold">
                                                {chapters.length}
                                            </span>
                                        )}
                                    </TabsTrigger>
                                    <TabsTrigger
                                        value="characters"
                                        className="flex-1 sm:flex-none gap-1.5 text-[13px] sm:text-sm lg:text-base lg:px-6 lg:py-2.5"
                                    >
                                        <Users className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                                        Characters
                                        {charactersData?.total > 0 && (
                                            <span className="ml-0.5 px-1.5 py-0.5 rounded-md bg-muted text-[9px] sm:text-[10px] lg:text-[11px] font-semibold">
                                                {charactersData.total}
                                            </span>
                                        )}
                                    </TabsTrigger>
                                </TabsList>
                            </div>

                            <TabsContent value="chapters">
                                {id.startsWith("mal-") ||
                                    id.startsWith("cv-") ? (
                                    <EmptyState
                                        icon={BookOpen}
                                        title="Chapters unavailable"
                                        description="This source doesn't provide chapter reading. Try finding this title on MangaDex."
                                    />
                                ) : (
                                    <ChapterList
                                        chapters={chapters}
                                        loading={loadingChapters}
                                        mangaId={id}
                                    />
                                )}
                            </TabsContent>

                            <TabsContent value="characters">
                                <CharacterGrid
                                    characters={charactersData?.data}
                                    loading={loadingCharacters}
                                />
                                {!loadingCharacters &&
                                    !charactersData?.data?.length && (
                                        <EmptyState
                                            icon={Users}
                                            title="No characters available"
                                            description="Character data isn't available for this title."
                                        />
                                    )}
                            </TabsContent>
                        </Tabs>
                    </motion.div>
                </div>
            </motion.div>

            {/* Share Sheet */}
            <ShareSheet
                open={shareOpen}
                onClose={() => setShareOpen(false)}
                url={shareUrl}
                title={manga?.title || ""}
            />
        </>
    );
}