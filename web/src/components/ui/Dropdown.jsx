// frontend/src/components/ui/Dropdown.jsx
import * as DropdownPrimitive from "@radix-ui/react-dropdown-menu";
import { forwardRef } from "react";
import { cn } from "@/lib/utils";
import { Check, ChevronRight } from "lucide-react";

const DropdownMenu = DropdownPrimitive.Root;
const DropdownMenuTrigger = DropdownPrimitive.Trigger;
const DropdownMenuGroup = DropdownPrimitive.Group;
const DropdownMenuSub = DropdownPrimitive.Sub;

const DropdownMenuContent = forwardRef(({ className, sideOffset = 6, ...props }, ref) => (
    <DropdownPrimitive.Portal>
        <DropdownPrimitive.Content
            ref={ref}
            sideOffset={sideOffset}
            className={cn(
                "z-50 min-w-[8rem] overflow-hidden rounded-xl border border-border bg-popover p-1 text-popover-foreground shadow-large",
                "data-[state=open]:animate-scale-in data-[state=closed]:animate-fade-out",
                className
            )}
            {...props}
        />
    </DropdownPrimitive.Portal>
));

const DropdownMenuItem = forwardRef(({ className, ...props }, ref) => (
    <DropdownPrimitive.Item
        ref={ref}
        className={cn(
            "relative flex cursor-pointer select-none items-center rounded-lg px-2.5 py-2 text-sm outline-none",
            "transition-colors focus:bg-accent focus:text-accent-foreground",
            "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
            className
        )}
        {...props}
    />
));

const DropdownMenuSeparator = forwardRef(({ className, ...props }, ref) => (
    <DropdownPrimitive.Separator ref={ref} className={cn("-mx-1 my-1 h-px bg-border", className)} {...props} />
));

const DropdownMenuLabel = forwardRef(({ className, ...props }, ref) => (
    <DropdownPrimitive.Label ref={ref} className={cn("px-2.5 py-1.5 text-xs font-semibold text-muted-foreground", className)} {...props} />
));

DropdownMenuContent.displayName = "DropdownMenuContent";
DropdownMenuItem.displayName = "DropdownMenuItem";
DropdownMenuSeparator.displayName = "DropdownMenuSeparator";
DropdownMenuLabel.displayName = "DropdownMenuLabel";

export {
    DropdownMenu, DropdownMenuTrigger, DropdownMenuContent,
    DropdownMenuItem, DropdownMenuSeparator, DropdownMenuLabel,
    DropdownMenuGroup, DropdownMenuSub,
};