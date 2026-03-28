// frontend/src/components/ui/Card.jsx
import { forwardRef } from "react";
import { cn } from "@/lib/utils";

const Card = forwardRef(({ className, hover, ...props }, ref) => (
    <div
        ref={ref}
        className={cn(
            "rounded-xl border border-border bg-card text-card-foreground",
            hover && "manga-card-hover cursor-pointer",
            className
        )}
        {...props}
    />
));

const CardHeader = forwardRef(({ className, ...props }, ref) => (
    <div ref={ref} className={cn("flex flex-col space-y-1.5 p-5", className)} {...props} />
));

const CardTitle = forwardRef(({ className, ...props }, ref) => (
    <h3 ref={ref} className={cn("font-semibold leading-tight tracking-tight", className)} {...props} />
));

const CardDescription = forwardRef(({ className, ...props }, ref) => (
    <p ref={ref} className={cn("text-sm text-muted-foreground", className)} {...props} />
));

const CardContent = forwardRef(({ className, ...props }, ref) => (
    <div ref={ref} className={cn("p-5 pt-0", className)} {...props} />
));

const CardFooter = forwardRef(({ className, ...props }, ref) => (
    <div ref={ref} className={cn("flex items-center p-5 pt-0", className)} {...props} />
));

Card.displayName = "Card";
CardHeader.displayName = "CardHeader";
CardTitle.displayName = "CardTitle";
CardDescription.displayName = "CardDescription";
CardContent.displayName = "CardContent";
CardFooter.displayName = "CardFooter";

export { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter };