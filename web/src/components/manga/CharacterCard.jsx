// frontend/src/components/manga/CharacterCard.jsx
import { OptimizedImage } from "@/components/common/OptimizedImage";
import { Badge } from "@/components/ui/Badge";
import { cn } from "@/lib/utils";

export function CharacterCard({ character }) {
    return (
        <div className="flex items-center gap-3 rounded-xl border border-border/50 bg-card p-3 hover:border-border transition-colors">
            <OptimizedImage
                src={character.image_url}
                alt={character.name}
                aspect="1/1"
                containerClassName="h-14 w-14 rounded-full flex-shrink-0"
                className="rounded-full"
            />
            <div className="flex-1 min-w-0">
                <p className="text-sm font-medium truncate">{character.name}</p>
                <Badge
                    variant={character.role === "Main" ? "default" : "secondary"}
                    className="mt-1 text-[10px]"
                >
                    {character.role}
                </Badge>
            </div>
        </div>
    );
}

export function CharacterGrid({ characters, loading }) {
    if (loading) {
        return (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                {Array.from({ length: 6 }).map((_, i) => (
                    <div key={i} className="h-20 animate-pulse rounded-xl bg-muted" />
                ))}
            </div>
        );
    }

    if (!characters?.length) return null;

    return (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
            {characters.map((c, i) => (
                <CharacterCard key={c.mal_id || i} character={c} />
            ))}
        </div>
    );
}