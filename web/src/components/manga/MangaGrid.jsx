// frontend/src/components/manga/MangaGrid.jsx
import { MangaCard } from "./MangaCard";
import { MangaGridSkeleton } from "@/components/ui/Skeleton";
import { EmptyState } from "@/components/common/EmptyState";
import { SearchX } from "lucide-react";

export function MangaGrid({
    manga,
    loading,
    emptyTitle,
    emptyDescription,
    emptyAction,
    emptyActionLabel,
}) {
    if (loading) {
        return <MangaGridSkeleton />;
    }

    if (!manga || manga.length === 0) {
        return (
            <EmptyState
                icon={SearchX}
                title={emptyTitle || "No manga found"}
                description={emptyDescription || "Try adjusting your search or filters"}
                action={emptyAction}
                actionLabel={emptyActionLabel}
            />
        );
    }

    return (
        <div className="grid grid-cols-2 xs:grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 gap-3 sm:gap-4 md:gap-5">
            {manga.map((m) => (
                <MangaCard key={m.id} manga={m} />
            ))}
        </div>
    );
}