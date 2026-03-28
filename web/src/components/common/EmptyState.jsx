// frontend/src/components/common/EmptyState.jsx
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/Button";

export function EmptyState({
    icon: Icon,
    title,
    description,
    action,
    actionLabel,
    className,
}) {
    return (
        <div className={cn("flex flex-col items-center justify-center py-16 px-4 text-center", className)}>
            {Icon && (
                <div className="mb-4 rounded-2xl bg-muted p-4">
                    <Icon className="h-8 w-8 text-muted-foreground" />
                </div>
            )}
            <h3 className="text-lg font-semibold mb-1">{title}</h3>
            {description && <p className="text-sm text-muted-foreground max-w-sm">{description}</p>}
            {action && actionLabel && (
                <Button onClick={action} variant="primary" size="lg" className="mt-6">
                    {actionLabel}
                </Button>
            )}
        </div>
    );
}