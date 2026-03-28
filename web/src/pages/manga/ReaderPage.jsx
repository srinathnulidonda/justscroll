// frontend/src/pages/ReaderPage.jsx
import { useParams, useSearchParams, useNavigate } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { useReaderStore } from "@/stores/readerStore";
import { ReaderView } from "@/components/manga/ReaderView";
import { EmptyState } from "@/components/common/EmptyState";
import { AlertCircle, Loader2 } from "lucide-react";

function ReaderSkeleton() {
    return (
        <div className="flex flex-col items-center justify-center min-h-screen bg-black">
            <Loader2 className="h-8 w-8 text-white/40 animate-spin" />
            <p className="text-sm text-white/30 mt-3">Loading chapter…</p>
        </div>
    );
}

export default function ReaderPage() {
    const { chapterId } = useParams();
    const [searchParams] = useSearchParams();
    const mangaId = searchParams.get("manga") || "";
    const navigate = useNavigate();
    const { quality } = useReaderStore();

    const {
        data: pagesData,
        isLoading: loadingPages,
        error: pagesError,
    } = useQuery({
        queryKey: ["pages", chapterId, quality],
        queryFn: () => api.getChapterPages(chapterId, quality),
        staleTime: 10 * 60 * 1000,
        retry: 1,
    });

    const { data: chaptersData } = useQuery({
        queryKey: ["chapters", mangaId],
        queryFn: () => api.getMangaChapters(mangaId),
        enabled: !!mangaId,
        staleTime: 10 * 60 * 1000,
    });

    const { data: mangaData } = useQuery({
        queryKey: ["manga", mangaId],
        queryFn: () => api.getMangaDetail(mangaId),
        enabled: !!mangaId,
        staleTime: 30 * 60 * 1000,
    });

    if (loadingPages) return <ReaderSkeleton />;

    if (pagesError || !pagesData?.pages?.length) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-black px-4">
                <EmptyState
                    icon={AlertCircle}
                    title="Unable to load chapter"
                    description="This chapter may not be available or is an external chapter."
                    action={() =>
                        navigate(mangaId ? `/manga/${mangaId}` : "/")
                    }
                    actionLabel="Go Back"
                />
            </div>
        );
    }

    const currentChapter = chaptersData?.data?.find(
        (c) => c.id === chapterId
    );

    return (
        <ReaderView
            pages={pagesData.pages}
            chapterId={chapterId}
            chapters={chaptersData?.data || []}
            mangaTitle={mangaData?.title || ""}
            chapterTitle={currentChapter?.title || ""}
            chapterNumber={currentChapter?.chapter || ""}
            mangaId={mangaId}
        />
    );
}