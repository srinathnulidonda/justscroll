// frontend/src/pages/Bookmarks.jsx
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useNavigate } from "react-router-dom";
import { api } from "@/lib/api";
import { useAuthStore } from "@/stores/authStore";
import { toast } from "@/stores/toastStore";
import { OptimizedImage } from "@/components/common/OptimizedImage";
import { EmptyState } from "@/components/common/EmptyState";
import { Button } from "@/components/ui/Button";
import { MangaGridSkeleton } from "@/components/ui/Skeleton";
import { Bookmark, Trash2, BookOpen } from "lucide-react";
import { cn, formatDate } from "@/lib/utils";
import { motion } from "framer-motion";

export default function Bookmarks() {
    const navigate = useNavigate();
    const { isAuthenticated } = useAuthStore();
    const queryClient = useQueryClient();

    const { data, isLoading } = useQuery({
        queryKey: ["bookmarks"],
        queryFn: () => api.getBookmarks(),
        enabled: isAuthenticated,
    });

    const removeMutation = useMutation({
        mutationFn: (mangaId) => api.removeBookmark(mangaId),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ["bookmarks"] });
            toast.success("Bookmark removed");
        },
        onError: () => toast.error("Failed to remove bookmark"),
    });

    if (!isAuthenticated) {
        return (
            <div className="mx-auto max-w-site px-4 sm:px-6 lg:px-8 py-6 md:py-10">
                <EmptyState
                    icon={Bookmark}
                    title="Sign in to view bookmarks"
                    description="Create an account to save your favorite manga"
                    action={() => navigate("/login")}
                    actionLabel="Sign In"
                />
            </div>
        );
    }

    const bookmarks = data?.data || [];

    return (
        <div className="mx-auto max-w-site px-4 sm:px-6 lg:px-8 py-6 md:py-10 space-y-6">
            <div>
                <h1 className="text-2xl md:text-3xl font-bold">My Bookmarks</h1>
                <p className="text-muted-foreground text-sm mt-1">
                    {bookmarks.length} saved {bookmarks.length === 1 ? "title" : "titles"}
                </p>
            </div>

            {isLoading ? (
                <MangaGridSkeleton count={8} />
            ) : bookmarks.length === 0 ? (
                <EmptyState
                    icon={Bookmark}
                    title="No bookmarks yet"
                    description="Browse manga and bookmark titles you want to read later"
                    action={() => navigate("/discover")}
                    actionLabel="Browse Manga"
                />
            ) : (
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 2xl:grid-cols-7 gap-4 md:gap-6">
                    {bookmarks.map((bk, i) => (
                        <motion.div
                            key={bk.id}
                            initial={{ opacity: 0, y: 10 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: i * 0.03 }}
                            className="group relative"
                        >
                            <button
                                onClick={() => navigate(`/manga/${bk.manga_id}`)}
                                className="block w-full text-left manga-card-hover"
                            >
                                <div className="relative overflow-hidden rounded-xl border border-border/50 bg-card">
                                    <OptimizedImage
                                        src={bk.cover_url}
                                        alt={bk.manga_title}
                                        containerClassName="aspect-[3/4]"
                                        className="manga-card-image transition-transform duration-500"
                                    />
                                </div>
                                <div className="mt-2.5 px-0.5">
                                    <h3 className="text-sm font-medium line-clamp-2 group-hover:text-primary transition-colors">
                                        {bk.manga_title}
                                    </h3>
                                    <p className="text-xs text-muted-foreground mt-0.5">
                                        {formatDate(bk.created_at)}
                                    </p>
                                </div>
                            </button>
                            <button
                                onClick={(e) => {
                                    e.stopPropagation();
                                    removeMutation.mutate(bk.manga_id);
                                }}
                                className="absolute top-2 right-2 rounded-full bg-black/60 p-1.5 text-white opacity-0 group-hover:opacity-100 transition-opacity hover:bg-destructive"
                                aria-label="Remove bookmark"
                            >
                                <Trash2 className="h-3.5 w-3.5" />
                            </button>
                        </motion.div>
                    ))}
                </div>
            )}
        </div>
    );
}