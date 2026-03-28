// frontend/src/components/ui/Tooltip.jsx
import * as TooltipPrimitive from "@radix-ui/react-tooltip";
import { forwardRef } from "react";
import { cn } from "@/lib/utils";

const TooltipProvider = TooltipPrimitive.Provider;
const Tooltip = TooltipPrimitive.Root;
const TooltipTrigger = TooltipPrimitive.Trigger;

const TooltipContent = forwardRef(({ className, sideOffset = 6, ...props }, ref) => (
    <TooltipPrimitive.Content
        ref={ref}
        sideOffset={sideOffset}
        className={cn(
            "z-50 overflow-hidden rounded-lg bg-foreground px-3 py-1.5 text-xs text-background shadow-medium",
            "animate-scale-in",
            className
        )}
        {...props}
    />
));

TooltipContent.displayName = "TooltipContent";

export function SimpleTooltip({ children, content, side = "top", ...props }) {
    return (
        <TooltipProvider delayDuration={200}>
            <Tooltip>
                <TooltipTrigger asChild>{children}</TooltipTrigger>
                <TooltipContent side={side} {...props}>
                    {content}
                </TooltipContent>
            </Tooltip>
        </TooltipProvider>
    );
}

export { TooltipProvider, Tooltip, TooltipTrigger, TooltipContent };