// frontend/src/components/ui/Button.jsx
import { forwardRef } from "react";
import { cn } from "@/lib/utils";
import { Loader2 } from "lucide-react";

const variants = {
    primary:
        "bg-primary text-primary-foreground hover:bg-primary/90 shadow-sm active:scale-[0.98]",
    secondary:
        "bg-secondary text-secondary-foreground hover:bg-secondary/80 active:scale-[0.98]",
    outline:
        "border border-border bg-transparent hover:bg-accent hover:text-accent-foreground active:scale-[0.98]",
    ghost:
        "hover:bg-accent hover:text-accent-foreground",
    destructive:
        "bg-destructive text-destructive-foreground hover:bg-destructive/90 shadow-sm active:scale-[0.98]",
    link: "text-primary underline-offset-4 hover:underline p-0 h-auto",
};

const sizes = {
    sm: "h-8 px-3 text-xs rounded-md gap-1.5",
    md: "h-9 px-4 text-sm rounded-lg gap-2",
    lg: "h-10 px-5 text-sm rounded-lg gap-2",
    xl: "h-12 px-8 text-base rounded-xl gap-2.5",
    icon: "h-9 w-9 rounded-lg",
    "icon-sm": "h-8 w-8 rounded-md",
    "icon-lg": "h-10 w-10 rounded-lg",
};

const Button = forwardRef(
    ({ className, variant = "primary", size = "md", loading, disabled, children, ...props }, ref) => (
        <button
            ref={ref}
            disabled={disabled || loading}
            className={cn(
                "inline-flex items-center justify-center font-medium transition-all duration-200",
                "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background",
                "disabled:pointer-events-none disabled:opacity-50",
                variants[variant],
                sizes[size],
                className
            )}
            {...props}
        >
            {loading && <Loader2 className="h-4 w-4 animate-spin" />}
            {children}
        </button>
    )
);

Button.displayName = "Button";
export { Button };