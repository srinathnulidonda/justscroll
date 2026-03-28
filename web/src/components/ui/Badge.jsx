// frontend/src/components/ui/Badge.jsx
import { cn } from "@/lib/utils";

const variantStyles = {
    default: "bg-primary/10 text-primary border-primary/20",
    secondary: "bg-secondary text-secondary-foreground border-transparent",
    success: "bg-emerald-500/10 text-emerald-500 border-emerald-500/20",
    warning: "bg-amber-500/10 text-amber-500 border-amber-500/20",
    destructive: "bg-destructive/10 text-destructive border-destructive/20",
    outline: "border-border text-foreground",
};

export function Badge({ className, variant = "default", children, ...props }) {
    return (
        <span
            className={cn(
                "inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-medium transition-colors",
                variantStyles[variant],
                className
            )}
            {...props}
        >
            {children}
        </span>
    );
}