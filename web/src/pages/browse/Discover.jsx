// frontend/src/pages/Discover.jsx
import { useState, useMemo } from "react";
import { useSearchParams } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { MangaGrid } from "@/components/manga/MangaGrid";
import { Button } from "@/components/ui/Button";
import {
    Flame,
    Sparkles,
    Loader2,
    ChevronLeft,
    ChevronRight,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { motion } from "framer-motion";

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

const TABS = [
    { key: "popular", label: "Popular", icon: Flame },
    { key: "latest", label: "Latest", icon: Sparkles },
];

function DiscoverToolbar({ activeTab, onTabChange }) {
    return (
        <div className={cn("sticky top-14 z-30", "py-3 sm:py-4")}>
            <div className="flex justify-center px-4">
                <nav
                    className={cn(
                        "inline-flex items-center",
                        "rounded-2xl",
                        "border border-border/30 dark:border-white/[0.06]",
                        "bg-background/80 dark:bg-[#1c1c1e]/80",
                        "backdrop-blur-xl",
                        "shadow-[0_4px_20px_rgba(0,0,0,0.08)]",
                        "dark:shadow-[0_4px_20px_rgba(0,0,0,0.35)]",
                        "px-1 py-0.5"
                    )}
                    role="tablist"
                    aria-label="Discover tabs"
                >
                    <div className="flex items-center">
                        {TABS.map((tab) => {
                            const isActive = activeTab === tab.key;
                            const Icon = tab.icon;
                            return (
                                <motion.button
                                    key={tab.key}
                                    onClick={() => onTabChange(tab.key)}
                                    whileTap={{ scale: 0.92 }}
                                    transition={{
                                        type: "spring",
                                        stiffness: 400,
                                        damping: 20,
                                    }}
                                    role="tab"
                                    aria-selected={isActive}
                                    className={cn(
                                        "relative flex items-center justify-center gap-1.5",
                                        "px-5 sm:px-6 py-2 rounded-xl",
                                        "text-sm font-medium",
                                        "transition-colors duration-200",
                                        "outline-none",
                                        isActive
                                            ? "text-primary"
                                            : "text-muted-foreground"
                                    )}
                                >
                                    {isActive && (
                                        <motion.div
                                            layoutId="discover-pill"
                                            className="absolute inset-0 rounded-xl bg-primary/8 dark:bg-primary/10"
                                            transition={{
                                                type: "spring",
                                                stiffness: 350,
                                                damping: 30,
                                            }}
                                        />
                                    )}
                                    <Icon
                                        className={cn(
                                            "relative z-10 h-[18px] w-[18px]",
                                            "transition-colors duration-200"
                                        )}
                                        strokeWidth={isActive ? 2.3 : 1.8}
                                    />
                                    <span
                                        className={cn(
                                            "relative z-10",
                                            "transition-colors duration-200",
                                            isActive
                                                ? "text-primary"
                                                : "text-muted-foreground/70"
                                        )}
                                    >
                                        {tab.label}
                                    </span>
                                </motion.button>
                            );
                        })}
                    </div>
                </nav>
            </div>
        </div>
    );
}

export default function Discover() {
    const [searchParams, setSearchParams] = useSearchParams();
    const tabParam = searchParams.get("tab");
    const [activeTab, setActiveTab] = useState(
        tabParam === "latest" ? "latest" : "popular"
    );
    const [offset, setOffset] = useState(0);

    const handleTabChange = (tab) => {
        setActiveTab(tab);
        setOffset(0);
        setSearchParams(
            tab === "latest" ? { tab: "latest" } : {},
            { replace: true }
        );
    };

    const { data, isLoading, isFetching } = useQuery({
        queryKey: ["discover", activeTab, offset],
        queryFn: () => {
            if (activeTab === "latest")
                return api.getLatestUpdates(LIMIT, offset);
            return api.getPopular(LIMIT, offset);
        },
        staleTime: 3 * 60 * 1000,
        keepPreviousData: true,
    });

    const uniqueData = useMemo(() => deduplicate(data?.data), [data]);
    const total = data?.total || 0;
    const totalPages = Math.ceil(total / LIMIT);
    const currentPage = Math.floor(offset / LIMIT) + 1;

    return (
        <div>
            <DiscoverToolbar
                activeTab={activeTab}
                onTabChange={handleTabChange}
            />

            <div className="mx-auto max-w-site px-4 sm:px-6 lg:px-8 py-4 md:py-6 space-y-6">
                <motion.div
                    key={activeTab}
                    initial={{ opacity: 0, y: 6 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.2 }}
                    className="text-center sm:text-left"
                >
                    <h1 className="text-xl sm:text-2xl md:text-3xl font-bold tracking-tight">
                        {activeTab === "popular"
                            ? "Popular Manga"
                            : "Latest Updates"}
                    </h1>
                    <p className="text-sm text-muted-foreground mt-1">
                        {activeTab === "popular"
                            ? "The most popular manga right now"
                            : "Recently updated manga titles"}
                    </p>
                </motion.div>

                {!isLoading && uniqueData.length > 0 && (
                    <div className="flex items-center justify-center sm:justify-start gap-3">
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

                <MangaGrid
                    manga={uniqueData}
                    loading={isLoading}
                    emptyTitle={
                        activeTab === "popular"
                            ? "No popular manga found"
                            : "No latest updates"
                    }
                    emptyDescription="Check back later for new titles"
                />

                {totalPages > 1 && !isLoading && (
                    <div className="flex items-center justify-center gap-1 mt-10">
                        <Button
                            variant="outline"
                            size="sm"
                            disabled={offset === 0 || isFetching}
                            onClick={() =>
                                setOffset(Math.max(0, offset - LIMIT))
                            }
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
        </div>
    );
}