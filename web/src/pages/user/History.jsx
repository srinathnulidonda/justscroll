// frontend/src/pages/History.jsx
import { useQuery } from "@tanstack/react-query";
import { Link, useNavigate } from "react-router-dom";
import { api } from "@/lib/api";
import { useAuthStore } from "@/stores/authStore";
import { EmptyState } from "@/components/common/EmptyState";
import { Skeleton } from "@/components/ui/Skeleton";
import { Clock, BookOpen, ArrowRight } from "lucide-react";
import { formatDate, cn } from "@/lib/utils";
import { motion } from "framer-motion";

export default function History() {
    const navigate = useNavigate();
    const { isAuthenticated } = useAuthStore();

    const { data, isLoading } = useQuery({
        queryKey: ["history"],
        queryFn: () => api.getHistory(),
        enabled: isAuthenticated,
    });

    if (!isAuthenticated) {
        return (
            <div className="mx-auto max-w-site px-4 sm:px-6 lg:px-8 py-6 md:py-10">
                <EmptyState
                    icon={Clock}
                    title="Sign in to view history"
                    description="Your reading progress will be saved automatically"
                    action={() => navigate("/login")}
                    actionLabel="Sign In"
                />
            </div>
        );
    }

    const history = data?.data || [];

    return (
        <div className="mx-auto max-w-site px-4 sm:px-6 lg:px-8 py-6 md:py-10 space-y-6">
            <div>
                <h1 className="text-2xl md:text-3xl font-bold">Reading History</h1>
                <p className="text-muted-foreground text-sm mt-1">
                    {history.length} {history.length === 1 ? "entry" : "entries"}
                </p>
            </div>

            {isLoading ? (
                <div className="space-y-3">
                    {Array.from({ length: 8 }).map((_, i) => (
                        <Skeleton key={i} className="h-16 rounded-xl" />
                    ))}
                </div>
            ) : history.length === 0 ? (
                <EmptyState
                    icon={Clock}
                    title="No reading history"
                    description="Start reading manga and your progress will appear here"
                    action={() => navigate("/discover")}
                    actionLabel="Browse Manga"
                />
            ) : (
                <div className="space-y-2">
                    {history.map((entry, i) => (
                        <motion.div
                            key={entry.id}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: i * 0.03 }}
                        >
                            <Link
                                to={`/read/${entry.chapter_id}?manga=${entry.manga_id}`}
                                className="flex items-center gap-4 rounded-xl border border-border/50 bg-card p-4 hover:border-border hover:bg-accent/30 transition-all group"
                            >
                                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 flex-shrink-0">
                                    <BookOpen className="h-5 w-5 text-primary" />
                                </div>
                                <div className="flex-1 min-w-0">
                                    <p className="text-sm font-medium truncate group-hover:text-primary transition-colors">
                                        {entry.manga_title}
                                    </p>
                                    <div className="flex items-center gap-2 text-xs text-muted-foreground mt-0.5">
                                        {entry.chapter_number && <span>Ch. {entry.chapter_number}</span>}
                                        <span>Page {entry.page_number}</span>
                                        <span>·</span>
                                        <span>{formatDate(entry.updated_at)}</span>
                                    </div>
                                </div>
                                <ArrowRight className="h-4 w-4 text-muted-foreground flex-shrink-0 group-hover:text-primary transition-colors" />
                            </Link>
                        </motion.div>
                    ))}
                </div>
            )}
        </div>
    );
}