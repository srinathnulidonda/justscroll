// frontend/src/components/ui/Skeleton.jsx
import { cn } from "@/lib/utils";

export function Skeleton({ className, ...props }) {
    return (
        <div
            className={cn(
                "bg-muted rounded-lg animate-pulse",
                className
            )}
            {...props}
        />
    );
}

export function MangaCardSkeleton() {
    return (
        <div>
            <Skeleton className="w-full aspect-[2/3] rounded-lg" />
            <div className="pt-2 space-y-2">
                <Skeleton className="h-4 w-3/4 rounded" />
                <Skeleton className="h-3 w-1/2 rounded" />
            </div>
        </div>
    );
}

export function MangaGridSkeleton({ count = 12 }) {
    return (
        <div className="grid grid-cols-2 xs:grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 gap-3 sm:gap-4 md:gap-5">
            {Array.from({ length: count }).map((_, i) => (
                <MangaCardSkeleton key={i} />
            ))}
        </div>
    );
}

export function DetailSkeleton() {
    return (
        <div className="space-y-8">
            <div className="flex flex-col md:flex-row gap-6">
                <Skeleton className="w-full md:w-56 aspect-[2/3] rounded-xl flex-shrink-0" />
                <div className="flex-1 space-y-4">
                    <Skeleton className="h-8 w-3/4 rounded" />
                    <Skeleton className="h-4 w-1/3 rounded" />
                    <div className="flex gap-2">
                        <Skeleton className="h-6 w-20 rounded-full" />
                        <Skeleton className="h-6 w-16 rounded-full" />
                    </div>
                    <Skeleton className="h-24 w-full rounded" />
                    <Skeleton className="h-10 w-36 rounded-lg" />
                </div>
            </div>
        </div>
    );
}

export function ReaderSkeleton() {
    return (
        <div className="flex items-center justify-center min-h-screen bg-black">
            <div className="w-8 h-8 border-2 border-white/20 border-t-white rounded-full animate-spin" />
        </div>
    );
}