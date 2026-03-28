// frontend/src/components/ui/Input.jsx
import { forwardRef, useState } from "react";
import { cn } from "@/lib/utils";
import { Eye, EyeOff } from "lucide-react";

const Input = forwardRef(
    ({ className, label, error, helperText, icon: Icon, type, ...props }, ref) => {
        const [showPassword, setShowPassword] = useState(false);
        const isPassword = type === "password";
        const inputType = isPassword ? (showPassword ? "text" : "password") : type;

        return (
            <div className="space-y-1.5">
                {label && (
                    <label className="text-sm font-medium text-foreground/80" htmlFor={props.id}>
                        {label}
                    </label>
                )}
                <div className="relative">
                    {Icon && (
                        <Icon className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground pointer-events-none" />
                    )}
                    <input
                        ref={ref}
                        type={inputType}
                        className={cn(
                            "flex h-10 w-full rounded-lg border border-input bg-background px-3 py-2 text-sm",
                            "transition-colors duration-200",
                            "placeholder:text-muted-foreground/60",
                            "focus:outline-none focus:ring-2 focus:ring-ring/40 focus:border-primary/50",
                            "disabled:cursor-not-allowed disabled:opacity-50",
                            Icon && "pl-10",
                            isPassword && "pr-10",
                            error && "border-destructive focus:ring-destructive/40",
                            className
                        )}
                        aria-invalid={!!error}
                        aria-describedby={error ? `${props.id}-error` : undefined}
                        {...props}
                    />
                    {isPassword && (
                        <button
                            type="button"
                            tabIndex={-1}
                            onClick={() => setShowPassword(!showPassword)}
                            className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                            aria-label={showPassword ? "Hide password" : "Show password"}
                        >
                            {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                        </button>
                    )}
                </div>
                {error && (
                    <p id={`${props.id}-error`} className="text-xs text-destructive" role="alert">
                        {error}
                    </p>
                )}
                {helperText && !error && <p className="text-xs text-muted-foreground">{helperText}</p>}
            </div>
        );
    }
);

Input.displayName = "Input";
export { Input };