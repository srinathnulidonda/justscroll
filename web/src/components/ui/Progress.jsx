// frontend/src/components/ui/Progress.jsx
import { cn } from "@/lib/utils";

export function Progress({ value = 0, max = 100, className }) {
    const pct = Math.min(100, Math.max(0, (value / max) * 100));
    return (
        <div
            className={cn("h-1.5 w-full overflow-hidden rounded-full bg-muted", className)}
            role="progressbar"
            aria-valuenow={value}
            aria-valuemin={0}
            aria-valuemax={max}
        >
            <div
                className="h-full rounded-full bg-primary transition-all duration-500 ease-out"
                style={{ width: `${pct}%` }}
            />
        </div>
    );
}