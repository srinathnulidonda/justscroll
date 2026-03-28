// frontend/src/components/manga/ReaderView.jsx
import { useState, useEffect, useCallback, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { motion, AnimatePresence } from "framer-motion";
import { useReaderStore } from "@/stores/readerStore";
import { useAuthStore } from "@/stores/authStore";
import { api } from "@/lib/api";
import { proxyImage, cn } from "@/lib/utils";
import { Button } from "@/components/ui/Button";
import {
    ArrowLeft,
    ChevronLeft,
    ChevronRight,
    Settings2,
    Maximize,
    Minimize,
    ZoomIn,
    ZoomOut,
    RotateCcw,
    Sun,
    Moon,
    Monitor,
    Eye,
    EyeOff,
    Image as ImageIcon,
    AlignJustify,
    BookOpen,
    Loader2,
    X,
    Zap,
    Columns,
    ChevronDown,
    Check,
} from "lucide-react";

/* ────────── Settings Panel ────────── */

function SettingSection({ title, children }) {
    return (
        <div className="space-y-2">
            <p className="text-[11px] font-semibold text-muted-foreground uppercase tracking-wider">
                {title}
            </p>
            {children}
        </div>
    );
}

function SettingOption({ icon: Icon, label, active, onClick }) {
    return (
        <button
            onClick={onClick}
            className={cn(
                "flex items-center gap-2",
                "w-full px-3 py-2.5 rounded-xl",
                "text-[13px] font-medium",
                "transition-all duration-150",
                "active:scale-[0.98]",
                active
                    ? "bg-primary text-primary-foreground"
                    : "bg-muted/50 text-muted-foreground hover:bg-muted hover:text-foreground"
            )}
        >
            <Icon className="h-4 w-4 flex-shrink-0" />
            <span className="flex-1 text-left">{label}</span>
            {active && <Check className="h-3.5 w-3.5 flex-shrink-0" />}
        </button>
    );
}

function SettingsPanel({
    open,
    onClose,
    quality,
    setQuality,
    mode,
    setMode,
    bgColor,
    setBgColor,
    autoHide,
    setAutoHide,
    direction,
    setDirection,
}) {
    return (
        <AnimatePresence>
            {open && (
                <>
                    {/* Backdrop */}
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        onClick={onClose}
                        className="fixed inset-0 z-40 bg-black/60"
                    />

                    {/* Panel */}
                    <motion.div
                        initial={{ y: "100%" }}
                        animate={{ y: 0 }}
                        exit={{ y: "100%" }}
                        transition={{
                            type: "spring",
                            stiffness: 400,
                            damping: 34,
                        }}
                        className={cn(
                            "fixed z-50",
                            "bottom-0 left-0 right-0",
                            "sm:bottom-auto sm:top-0 sm:right-0 sm:left-auto",
                            "sm:w-80 sm:h-full",
                            "rounded-t-2xl sm:rounded-none sm:rounded-l-2xl",
                            "bg-background border-t sm:border-l sm:border-t-0 border-border/50",
                            "shadow-[0_-8px_40px_rgba(0,0,0,0.4)]",
                            "sm:shadow-[-8px_0_40px_rgba(0,0,0,0.4)]",
                            "overflow-y-auto max-h-[85vh] sm:max-h-full"
                        )}
                        style={{
                            paddingBottom: "env(safe-area-inset-bottom)",
                        }}
                    >
                        {/* Handle (mobile) */}
                        <div className="flex justify-center pt-3 pb-1 sm:hidden">
                            <div className="w-9 h-1 rounded-full bg-muted-foreground/20" />
                        </div>

                        {/* Header */}
                        <div className="flex items-center justify-between px-5 pt-3 sm:pt-5 pb-4">
                            <h3 className="text-base font-semibold">
                                Reader Settings
                            </h3>
                            <button
                                onClick={onClose}
                                className="flex items-center justify-center w-8 h-8 rounded-full text-muted-foreground hover:bg-muted hover:text-foreground transition-colors"
                            >
                                <X className="h-4 w-4" />
                            </button>
                        </div>

                        <div className="px-5 pb-6 space-y-5">
                            {/* Quality */}
                            <SettingSection title="Image Quality">
                                <div className="grid grid-cols-2 gap-2">
                                    <SettingOption
                                        icon={ImageIcon}
                                        label="High"
                                        active={quality === "data"}
                                        onClick={() => setQuality("data")}
                                    />
                                    <SettingOption
                                        icon={Zap}
                                        label="Data Saver"
                                        active={quality === "dataSaver"}
                                        onClick={() => setQuality("dataSaver")}
                                    />
                                </div>
                            </SettingSection>

                            {/* Reading Mode */}
                            <SettingSection title="Reading Mode">
                                <div className="grid grid-cols-2 gap-2">
                                    <SettingOption
                                        icon={Columns}
                                        label="Single Page"
                                        active={mode === "single"}
                                        onClick={() => setMode("single")}
                                    />
                                    <SettingOption
                                        icon={AlignJustify}
                                        label="Long Strip"
                                        active={mode === "continuous"}
                                        onClick={() => setMode("continuous")}
                                    />
                                </div>
                            </SettingSection>

                            {/* Direction (only for single page) */}
                            {mode === "single" && (
                                <SettingSection title="Page Direction">
                                    <div className="grid grid-cols-2 gap-2">
                                        <SettingOption
                                            icon={ChevronRight}
                                            label="Left → Right"
                                            active={direction === "ltr"}
                                            onClick={() => setDirection("ltr")}
                                        />
                                        <SettingOption
                                            icon={ChevronLeft}
                                            label="Right → Left"
                                            active={direction === "rtl"}
                                            onClick={() => setDirection("rtl")}
                                        />
                                    </div>
                                </SettingSection>
                            )}

                            {/* Background */}
                            <SettingSection title="Background">
                                <div className="grid grid-cols-3 gap-2">
                                    <SettingOption
                                        icon={Moon}
                                        label="Black"
                                        active={bgColor === "black"}
                                        onClick={() => setBgColor("black")}
                                    />
                                    <SettingOption
                                        icon={Monitor}
                                        label="Dark"
                                        active={bgColor === "dark"}
                                        onClick={() => setBgColor("dark")}
                                    />
                                    <SettingOption
                                        icon={Sun}
                                        label="White"
                                        active={bgColor === "white"}
                                        onClick={() => setBgColor("white")}
                                    />
                                </div>
                            </SettingSection>

                            {/* Toolbar behavior */}
                            <SettingSection title="Toolbar">
                                <div className="grid grid-cols-2 gap-2">
                                    <SettingOption
                                        icon={EyeOff}
                                        label="Auto Hide"
                                        active={autoHide}
                                        onClick={() => setAutoHide(true)}
                                    />
                                    <SettingOption
                                        icon={Eye}
                                        label="Always Show"
                                        active={!autoHide}
                                        onClick={() => setAutoHide(false)}
                                    />
                                </div>
                            </SettingSection>
                        </div>
                    </motion.div>
                </>
            )}
        </AnimatePresence>
    );
}

/* ────────── Progress Bar ────────── */

function ReaderProgress({ current, total, onSeek }) {
    const pct = total > 0 ? ((current + 1) / total) * 100 : 0;

    return (
        <div className="w-full group">
            <div
                className="relative h-1 group-hover:h-1.5 w-full bg-white/10 rounded-full cursor-pointer transition-all duration-150"
                onClick={(e) => {
                    const rect = e.currentTarget.getBoundingClientRect();
                    const x = e.clientX - rect.left;
                    const page = Math.floor((x / rect.width) * total);
                    onSeek(Math.max(0, Math.min(total - 1, page)));
                }}
            >
                <div
                    className="h-full bg-primary rounded-full transition-all duration-300 ease-out relative"
                    style={{ width: `${pct}%` }}
                >
                    <div className="absolute right-0 top-1/2 -translate-y-1/2 w-3 h-3 rounded-full bg-primary opacity-0 group-hover:opacity-100 transition-opacity shadow-lg shadow-primary/30" />
                </div>
            </div>
        </div>
    );
}

/* ────────── Page Image ────────── */

function PageImage({ src, alt, zoom, onLoad }) {
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(false);

    return (
        <div className="relative flex items-center justify-center w-full h-full">
            {loading && !error && (
                <div className="absolute inset-0 flex items-center justify-center">
                    <Loader2 className="h-6 w-6 text-white/30 animate-spin" />
                </div>
            )}
            {error ? (
                <div className="flex flex-col items-center gap-2 text-white/40">
                    <ImageIcon className="h-8 w-8" />
                    <p className="text-xs">Failed to load</p>
                </div>
            ) : (
                <img
                    src={src}
                    alt={alt}
                    onLoad={() => {
                        setLoading(false);
                        onLoad?.();
                    }}
                    onError={() => {
                        setLoading(false);
                        setError(true);
                    }}
                    className={cn(
                        "max-h-screen max-w-full object-contain select-none",
                        "transition-all duration-200",
                        loading ? "opacity-0" : "opacity-100"
                    )}
                    style={{ transform: `scale(${zoom})` }}
                    draggable={false}
                />
            )}
        </div>
    );
}

/* ────────── Continuous Page ────────── */

function ContinuousPageImage({ src, alt, index }) {
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(false);

    return (
        <div className="relative w-full">
            {loading && !error && (
                <div className="flex items-center justify-center py-20">
                    <Loader2 className="h-5 w-5 text-white/20 animate-spin" />
                </div>
            )}
            {error ? (
                <div className="flex flex-col items-center justify-center py-16 gap-2 text-white/30">
                    <ImageIcon className="h-6 w-6" />
                    <p className="text-[11px]">Page {index + 1} failed</p>
                </div>
            ) : (
                <img
                    src={src}
                    alt={alt}
                    loading={index < 3 ? "eager" : "lazy"}
                    onLoad={() => setLoading(false)}
                    onError={() => {
                        setLoading(false);
                        setError(true);
                    }}
                    className={cn(
                        "w-full h-auto select-none",
                        loading ? "opacity-0 h-0" : "opacity-100"
                    )}
                    draggable={false}
                />
            )}
        </div>
    );
}

/* ────────── Chapter Selector ────────── */

function ChapterSelector({
    chapters,
    currentId,
    mangaId,
    onSelect,
    open,
    onClose,
}) {
    if (!open) return null;

    return (
        <AnimatePresence>
            {open && (
                <>
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        onClick={onClose}
                        className="fixed inset-0 z-40 bg-black/60"
                    />
                    <motion.div
                        initial={{ y: "100%" }}
                        animate={{ y: 0 }}
                        exit={{ y: "100%" }}
                        transition={{
                            type: "spring",
                            stiffness: 400,
                            damping: 34,
                        }}
                        className={cn(
                            "fixed bottom-0 left-0 right-0 z-50",
                            "max-h-[70vh] overflow-y-auto",
                            "rounded-t-2xl",
                            "bg-background border-t border-border/50",
                            "shadow-[0_-8px_40px_rgba(0,0,0,0.4)]"
                        )}
                        style={{
                            paddingBottom: "env(safe-area-inset-bottom)",
                        }}
                    >
                        <div className="flex justify-center pt-3 pb-1">
                            <div className="w-9 h-1 rounded-full bg-muted-foreground/20" />
                        </div>
                        <div className="px-5 pt-2 pb-4">
                            <h3 className="text-base font-semibold mb-3">
                                Chapters
                            </h3>
                            <div className="space-y-1">
                                {chapters.map((ch) => {
                                    const isCurrent = ch.id === currentId;
                                    const readable =
                                        ch.readable !== false && ch.pages > 0;
                                    if (!readable) return null;
                                    return (
                                        <button
                                            key={ch.id}
                                            onClick={() => {
                                                onSelect(ch.id);
                                                onClose();
                                            }}
                                            className={cn(
                                                "flex items-center gap-3 w-full",
                                                "px-3 py-2.5 rounded-xl text-left",
                                                "text-[13px] transition-colors",
                                                isCurrent
                                                    ? "bg-primary/10 text-primary"
                                                    : "hover:bg-muted/50 text-foreground"
                                            )}
                                        >
                                            <BookOpen
                                                className={cn(
                                                    "h-4 w-4 flex-shrink-0",
                                                    isCurrent
                                                        ? "text-primary"
                                                        : "text-muted-foreground"
                                                )}
                                            />
                                            <div className="flex-1 min-w-0">
                                                <p className="font-medium truncate">
                                                    {ch.chapter
                                                        ? `Ch. ${ch.chapter}`
                                                        : "Oneshot"}
                                                    {ch.title &&
                                                        ` — ${ch.title}`}
                                                </p>
                                            </div>
                                            {isCurrent && (
                                                <span className="text-[10px] font-semibold text-primary bg-primary/10 px-2 py-0.5 rounded-full">
                                                    Current
                                                </span>
                                            )}
                                        </button>
                                    );
                                })}
                            </div>
                        </div>
                    </motion.div>
                </>
            )}
        </AnimatePresence>
    );
}

/* ────────── Main ReaderView ────────── */

const BG_COLORS = {
    black: "bg-black",
    dark: "bg-zinc-900",
    white: "bg-white",
};

export function ReaderView({
    pages,
    chapterId,
    chapters,
    mangaTitle,
    chapterTitle,
    chapterNumber,
    mangaId,
}) {
    const navigate = useNavigate();

    const {
        currentPage,
        setCurrentPage,
        setTotalPages,
        quality,
        setQuality,
        mode,
        setMode,
        showUI,
        toggleUI,
    } = useReaderStore();

    const [settingsOpen, setSettingsOpen] = useState(false);
    const [chaptersOpen, setChaptersOpen] = useState(false);
    const [isFullscreen, setIsFullscreen] = useState(false);
    const [zoom, setZoom] = useState(1);
    const [bgColor, setBgColor] = useState(
        () => localStorage.getItem("reader_bg") || "black"
    );
    const [autoHide, setAutoHide] = useState(
        () => localStorage.getItem("reader_autohide") !== "false"
    );
    const [direction, setDirection] = useState(
        () => localStorage.getItem("reader_direction") || "ltr"
    );

    const containerRef = useRef(null);
    const lastScrollY = useRef(0);
    const hideTimer = useRef(null);
    const { isAuthenticated } = useAuthStore();

    const totalPages = pages?.length || 0;

    // Chapter navigation
    const currentChapterIndex =
        chapters?.findIndex((c) => c.id === chapterId) ?? -1;
    const prevChapter =
        currentChapterIndex > 0 ? chapters[currentChapterIndex - 1] : null;
    const nextChapter =
        currentChapterIndex < (chapters?.length || 0) - 1
            ? chapters[currentChapterIndex + 1]
            : null;

    const chapterDisplay = chapterNumber
        ? `Ch. ${chapterNumber}`
        : chapterTitle || "Chapter";

    // Persist settings
    useEffect(() => {
        localStorage.setItem("reader_bg", bgColor);
    }, [bgColor]);
    useEffect(() => {
        localStorage.setItem("reader_autohide", autoHide.toString());
    }, [autoHide]);
    useEffect(() => {
        localStorage.setItem("reader_direction", direction);
    }, [direction]);

    // Reset on chapter change
    useEffect(() => {
        setCurrentPage(0);
        setTotalPages(totalPages);
        setZoom(1);
    }, [pages, chapterId]);

    // Save reading progress
    useEffect(() => {
        if (isAuthenticated && mangaId && chapterId) {
            api.updateHistory({
                manga_id: mangaId,
                chapter_id: chapterId,
                manga_title: mangaTitle || "Unknown",
                chapter_number: chapterNumber || null,
                page_number: currentPage + 1,
            }).catch(() => { });
        }
    }, [chapterId, currentPage]);

    // Auto-hide toolbar
    useEffect(() => {
        if (!autoHide || !showUI) return;
        clearTimeout(hideTimer.current);
        hideTimer.current = setTimeout(() => {
            if (!settingsOpen && !chaptersOpen) {
                useReaderStore.setState({ showUI: false });
            }
        }, 4000);
        return () => clearTimeout(hideTimer.current);
    }, [showUI, currentPage, autoHide, settingsOpen, chaptersOpen]);

    // Scroll-based toolbar visibility (continuous mode)
    useEffect(() => {
        if (mode !== "continuous" || !autoHide) return;
        const handleScroll = () => {
            const y = window.scrollY;
            if (y < lastScrollY.current - 30) {
                useReaderStore.setState({ showUI: true });
            } else if (y > lastScrollY.current + 50 && !settingsOpen) {
                useReaderStore.setState({ showUI: false });
            }
            lastScrollY.current = y;
        };
        window.addEventListener("scroll", handleScroll, { passive: true });
        return () => window.removeEventListener("scroll", handleScroll);
    }, [mode, autoHide, settingsOpen]);

    // Navigate pages
    const goPage = useCallback(
        (dir) => {
            if (mode === "continuous") return;
            const actualDir = direction === "rtl" ? -dir : dir;
            setCurrentPage((p) => {
                const next = p + actualDir;
                if (next < 0) {
                    if (prevChapter)
                        navigate(`/read/${prevChapter.id}?manga=${mangaId}`);
                    return p;
                }
                if (next >= totalPages) {
                    if (nextChapter)
                        navigate(`/read/${nextChapter.id}?manga=${mangaId}`);
                    return p;
                }
                return next;
            });
        },
        [
            totalPages,
            prevChapter,
            nextChapter,
            mangaId,
            navigate,
            mode,
            direction,
        ]
    );

    // Keyboard
    useEffect(() => {
        function handleKey(e) {
            if (
                e.target.tagName === "INPUT" ||
                e.target.tagName === "TEXTAREA"
            )
                return;
            switch (e.key) {
                case "ArrowLeft":
                    e.preventDefault();
                    goPage(-1);
                    break;
                case "ArrowRight":
                case " ":
                    e.preventDefault();
                    goPage(1);
                    break;
                case "ArrowUp":
                    if (mode === "single") {
                        e.preventDefault();
                        goPage(-1);
                    }
                    break;
                case "ArrowDown":
                    if (mode === "single") {
                        e.preventDefault();
                        goPage(1);
                    }
                    break;
                case "f":
                    e.preventDefault();
                    toggleFullscreen();
                    break;
                case "s":
                    e.preventDefault();
                    setSettingsOpen((o) => !o);
                    break;
                case "Escape":
                    e.preventDefault();
                    if (settingsOpen) {
                        setSettingsOpen(false);
                    } else {
                        navigate(mangaId ? `/manga/${mangaId}` : "/");
                    }
                    break;
            }
        }
        window.addEventListener("keydown", handleKey);
        return () => window.removeEventListener("keydown", handleKey);
    }, [goPage, mangaId, navigate, settingsOpen, mode]);

    // Fullscreen
    const toggleFullscreen = () => {
        if (!document.fullscreenElement) {
            containerRef.current?.requestFullscreen?.();
            setIsFullscreen(true);
        } else {
            document.exitFullscreen?.();
            setIsFullscreen(false);
        }
    };

    useEffect(() => {
        const handler = () => setIsFullscreen(!!document.fullscreenElement);
        document.addEventListener("fullscreenchange", handler);
        return () =>
            document.removeEventListener("fullscreenchange", handler);
    }, []);

    const currentSrc = pages?.[currentPage]
        ? proxyImage(pages[currentPage])
        : null;

    const handleTap = (e) => {
        if (settingsOpen || chaptersOpen) return;
        if (e.target.closest("button") || e.target.closest("a")) return;
        toggleUI();
    };

    const goToChapter = (id) => {
        navigate(`/read/${id}?manga=${mangaId}`);
    };

    return (
        <div
            ref={containerRef}
            className={cn(
                "relative flex flex-col min-h-screen select-none",
                BG_COLORS[bgColor] || "bg-black"
            )}
            onClick={handleTap}
        >
            {/* ──── Top Toolbar ──── */}
            <AnimatePresence>
                {showUI && (
                    <motion.header
                        initial={{ y: "-100%", opacity: 0 }}
                        animate={{ y: 0, opacity: 1 }}
                        exit={{ y: "-100%", opacity: 0 }}
                        transition={{
                            type: "spring",
                            stiffness: 400,
                            damping: 30,
                        }}
                        className={cn(
                            "fixed inset-x-0 top-0 z-30",
                            "bg-gradient-to-b from-black/90 via-black/70 to-transparent",
                            "pb-4"
                        )}
                        style={{
                            paddingTop: "env(safe-area-inset-top)",
                        }}
                    >
                        <div className="flex items-center gap-2 px-3 sm:px-4 h-12 sm:h-14">
                            {/* Back */}
                            <button
                                onClick={(e) => {
                                    e.stopPropagation();
                                    navigate(
                                        mangaId ? `/manga/${mangaId}` : "/"
                                    );
                                }}
                                className="flex items-center justify-center w-9 h-9 rounded-full text-white/80 hover:text-white hover:bg-white/10 transition-colors"
                            >
                                <ArrowLeft className="h-5 w-5" />
                            </button>

                            {/* Title */}
                            <div className="flex-1 min-w-0 px-1">
                                <p className="text-[13px] sm:text-sm font-medium text-white truncate">
                                    {mangaTitle}
                                </p>
                                <p className="text-[10px] sm:text-[11px] text-white/50 truncate">
                                    {chapterDisplay}
                                    {chapterTitle &&
                                        chapterNumber &&
                                        ` — ${chapterTitle}`}
                                </p>
                            </div>

                            {/* Actions */}
                            <div className="flex items-center gap-0.5">
                                {/* Chapter selector */}
                                {chapters.length > 1 && (
                                    <button
                                        onClick={(e) => {
                                            e.stopPropagation();
                                            setChaptersOpen(true);
                                        }}
                                        className="flex items-center gap-1 px-2.5 py-1.5 rounded-lg text-white/60 hover:text-white hover:bg-white/10 transition-colors"
                                    >
                                        <BookOpen className="h-4 w-4" />
                                        <ChevronDown className="h-3 w-3" />
                                    </button>
                                )}

                                {/* Zoom */}
                                <button
                                    onClick={(e) => {
                                        e.stopPropagation();
                                        setZoom((z) =>
                                            z >= 2 ? 1 : z + 0.25
                                        );
                                    }}
                                    className="flex items-center justify-center w-9 h-9 rounded-full text-white/60 hover:text-white hover:bg-white/10 transition-colors"
                                >
                                    {zoom > 1 ? (
                                        <ZoomOut className="h-5 w-5" />
                                    ) : (
                                        <ZoomIn className="h-5 w-5" />
                                    )}
                                </button>

                                {zoom > 1 && (
                                    <button
                                        onClick={(e) => {
                                            e.stopPropagation();
                                            setZoom(1);
                                        }}
                                        className="flex items-center justify-center w-9 h-9 rounded-full text-white/60 hover:text-white hover:bg-white/10 transition-colors"
                                    >
                                        <RotateCcw className="h-4 w-4" />
                                    </button>
                                )}

                                {/* Fullscreen (desktop) */}
                                <button
                                    onClick={(e) => {
                                        e.stopPropagation();
                                        toggleFullscreen();
                                    }}
                                    className="hidden sm:flex items-center justify-center w-9 h-9 rounded-full text-white/60 hover:text-white hover:bg-white/10 transition-colors"
                                >
                                    {isFullscreen ? (
                                        <Minimize className="h-5 w-5" />
                                    ) : (
                                        <Maximize className="h-5 w-5" />
                                    )}
                                </button>

                                {/* Settings */}
                                <button
                                    onClick={(e) => {
                                        e.stopPropagation();
                                        setSettingsOpen(true);
                                    }}
                                    className="flex items-center justify-center w-9 h-9 rounded-full text-white/60 hover:text-white hover:bg-white/10 transition-colors"
                                >
                                    <Settings2 className="h-5 w-5" />
                                </button>
                            </div>
                        </div>
                    </motion.header>
                )}
            </AnimatePresence>

            {/* ──── Main Content ──── */}
            <div className="flex-1 flex items-center justify-center">
                {mode === "single" ? (
                    <div className="relative w-full h-screen flex items-center justify-center">
                        {/* Tap zones */}
                        <button
                            onClick={(e) => {
                                e.stopPropagation();
                                goPage(-1);
                            }}
                            className={cn(
                                "absolute top-0 bottom-0 z-10 w-1/3",
                                direction === "rtl" ? "right-0" : "left-0",
                                "focus:outline-none"
                            )}
                            style={{
                                cursor:
                                    direction === "rtl"
                                        ? "e-resize"
                                        : "w-resize",
                            }}
                            aria-label="Previous page"
                        />
                        <button
                            onClick={(e) => {
                                e.stopPropagation();
                                goPage(1);
                            }}
                            className={cn(
                                "absolute top-0 bottom-0 z-10 w-1/3",
                                direction === "rtl" ? "left-0" : "right-0",
                                "focus:outline-none"
                            )}
                            style={{
                                cursor:
                                    direction === "rtl"
                                        ? "w-resize"
                                        : "e-resize",
                            }}
                            aria-label="Next page"
                        />

                        {/* Page */}
                        {currentSrc && (
                            <div className="flex items-center justify-center w-full h-full p-2">
                                <PageImage
                                    key={`${chapterId}-${currentPage}`}
                                    src={currentSrc}
                                    alt={`Page ${currentPage + 1}`}
                                    zoom={zoom}
                                />
                            </div>
                        )}
                    </div>
                ) : (
                    /* Continuous / Long strip */
                    <div className="w-full max-w-3xl mx-auto pt-16">
                        {pages?.map((page, i) => (
                            <ContinuousPageImage
                                key={`${chapterId}-${i}`}
                                src={proxyImage(page)}
                                alt={`Page ${i + 1}`}
                                index={i}
                            />
                        ))}

                        {/* End of chapter */}
                        <div className="py-16 px-4 text-center space-y-4">
                            <p className="text-sm text-white/30">
                                End of {chapterDisplay}
                            </p>
                            <div className="flex items-center justify-center gap-3">
                                {prevChapter && (
                                    <Button
                                        variant="outline"
                                        size="sm"
                                        onClick={(e) => {
                                            e.stopPropagation();
                                            goToChapter(prevChapter.id);
                                        }}
                                        className="text-white border-white/20 hover:bg-white/10 text-xs"
                                    >
                                        <ChevronLeft className="h-3.5 w-3.5 mr-1" />
                                        Previous
                                    </Button>
                                )}
                                {nextChapter && (
                                    <Button
                                        variant="primary"
                                        size="md"
                                        onClick={(e) => {
                                            e.stopPropagation();
                                            goToChapter(nextChapter.id);
                                        }}
                                    >
                                        Next Chapter
                                        <ChevronRight className="h-4 w-4 ml-1" />
                                    </Button>
                                )}
                            </div>
                        </div>
                    </div>
                )}
            </div>

            {/* ──── Bottom Toolbar ──── */}
            <AnimatePresence>
                {showUI && mode === "single" && (
                    <motion.footer
                        initial={{ y: "100%", opacity: 0 }}
                        animate={{ y: 0, opacity: 1 }}
                        exit={{ y: "100%", opacity: 0 }}
                        transition={{
                            type: "spring",
                            stiffness: 400,
                            damping: 30,
                        }}
                        className={cn(
                            "fixed inset-x-0 bottom-0 z-30",
                            "bg-gradient-to-t from-black/90 via-black/70 to-transparent",
                            "pt-6"
                        )}
                        style={{
                            paddingBottom:
                                "max(env(safe-area-inset-bottom), 12px)",
                        }}
                    >
                        <div className="px-4 sm:px-6 space-y-3">
                            {/* Progress bar */}
                            <ReaderProgress
                                current={currentPage}
                                total={totalPages}
                                onSeek={(p) => setCurrentPage(p)}
                            />

                            {/* Controls */}
                            <div className="flex items-center justify-between">
                                {/* Prev page */}
                                <button
                                    onClick={(e) => {
                                        e.stopPropagation();
                                        goPage(-1);
                                    }}
                                    disabled={
                                        currentPage === 0 && !prevChapter
                                    }
                                    className={cn(
                                        "flex items-center gap-1",
                                        "px-3 py-1.5 rounded-lg",
                                        "text-[13px] font-medium text-white/70",
                                        "hover:text-white hover:bg-white/10",
                                        "disabled:opacity-30 disabled:pointer-events-none",
                                        "transition-colors"
                                    )}
                                >
                                    <ChevronLeft className="h-4 w-4" />
                                    <span className="hidden xs:inline">
                                        Prev
                                    </span>
                                </button>

                                {/* Page indicator */}
                                <div className="flex items-center gap-3">
                                    {prevChapter && (
                                        <button
                                            onClick={(e) => {
                                                e.stopPropagation();
                                                goToChapter(prevChapter.id);
                                            }}
                                            className="text-[10px] text-white/40 hover:text-white/70 transition-colors px-2 py-1 rounded hidden sm:block"
                                        >
                                            ← Prev Ch.
                                        </button>
                                    )}

                                    <span className="text-sm font-mono text-white/80 tabular-nums">
                                        <span className="text-white font-semibold">
                                            {currentPage + 1}
                                        </span>
                                        <span className="text-white/40 mx-1">
                                            /
                                        </span>
                                        <span className="text-white/50">
                                            {totalPages}
                                        </span>
                                    </span>

                                    {nextChapter && (
                                        <button
                                            onClick={(e) => {
                                                e.stopPropagation();
                                                goToChapter(nextChapter.id);
                                            }}
                                            className="text-[10px] text-white/40 hover:text-white/70 transition-colors px-2 py-1 rounded hidden sm:block"
                                        >
                                            Next Ch. →
                                        </button>
                                    )}
                                </div>

                                {/* Next page */}
                                <button
                                    onClick={(e) => {
                                        e.stopPropagation();
                                        goPage(1);
                                    }}
                                    disabled={
                                        currentPage >= totalPages - 1 &&
                                        !nextChapter
                                    }
                                    className={cn(
                                        "flex items-center gap-1",
                                        "px-3 py-1.5 rounded-lg",
                                        "text-[13px] font-medium text-white/70",
                                        "hover:text-white hover:bg-white/10",
                                        "disabled:opacity-30 disabled:pointer-events-none",
                                        "transition-colors"
                                    )}
                                >
                                    <span className="hidden xs:inline">
                                        Next
                                    </span>
                                    <ChevronRight className="h-4 w-4" />
                                </button>
                            </div>

                            {/* Chapter nav (mobile) */}
                            {(prevChapter || nextChapter) && (
                                <div className="flex items-center justify-center gap-2 sm:hidden pb-1">
                                    {prevChapter && (
                                        <button
                                            onClick={(e) => {
                                                e.stopPropagation();
                                                goToChapter(prevChapter.id);
                                            }}
                                            className="text-[11px] text-white/40 hover:text-white/70 px-2.5 py-1 rounded-lg border border-white/10 transition-colors"
                                        >
                                            ← Prev Chapter
                                        </button>
                                    )}
                                    {nextChapter && (
                                        <button
                                            onClick={(e) => {
                                                e.stopPropagation();
                                                goToChapter(nextChapter.id);
                                            }}
                                            className="text-[11px] text-white/40 hover:text-white/70 px-2.5 py-1 rounded-lg border border-white/10 transition-colors"
                                        >
                                            Next Chapter →
                                        </button>
                                    )}
                                </div>
                            )}
                        </div>
                    </motion.footer>
                )}
            </AnimatePresence>

            {/* ──── Settings Panel ──── */}
            <SettingsPanel
                open={settingsOpen}
                onClose={() => setSettingsOpen(false)}
                quality={quality}
                setQuality={setQuality}
                mode={mode}
                setMode={setMode}
                bgColor={bgColor}
                setBgColor={setBgColor}
                autoHide={autoHide}
                setAutoHide={setAutoHide}
                direction={direction}
                setDirection={setDirection}
            />

            {/* ──── Chapter Selector ──── */}
            <ChapterSelector
                chapters={chapters}
                currentId={chapterId}
                mangaId={mangaId}
                onSelect={goToChapter}
                open={chaptersOpen}
                onClose={() => setChaptersOpen(false)}
            />
        </div>
    );
}