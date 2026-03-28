// frontend/src/components/common/Toast.jsx
import { useEffect, useState } from "react";
import { useToastStore } from "@/stores/toastStore";
import { motion, AnimatePresence, useMotionValue, useTransform, animate } from "framer-motion";
import { X, CheckCircle2, AlertCircle, AlertTriangle, Info } from "lucide-react";
import { cn } from "@/lib/utils";

const icons = {
    success: CheckCircle2,
    error: AlertCircle,
    warning: AlertTriangle,
    info: Info,
};

const colors = {
    success: {
        bg: "bg-emerald-500/8 dark:bg-emerald-500/10",
        border: "border-emerald-500/20",
        icon: "text-emerald-500",
        progress: "bg-emerald-500",
    },
    error: {
        bg: "bg-red-500/8 dark:bg-red-500/10",
        border: "border-red-500/20",
        icon: "text-red-500",
        progress: "bg-red-500",
    },
    warning: {
        bg: "bg-amber-500/8 dark:bg-amber-500/10",
        border: "border-amber-500/20",
        icon: "text-amber-500",
        progress: "bg-amber-500",
    },
    info: {
        bg: "bg-primary/8 dark:bg-primary/10",
        border: "border-primary/20",
        icon: "text-primary",
        progress: "bg-primary",
    },
};

function ToastProgress({ duration, type }) {
    const progress = useMotionValue(100);

    useEffect(() => {
        if (duration <= 0) return;
        const controls = animate(progress, 0, {
            duration: duration / 1000,
            ease: "linear",
        });
        return () => controls.stop();
    }, [duration]);

    const width = useTransform(progress, (v) => `${v}%`);

    if (duration <= 0) return null;

    return (
        <div className="absolute bottom-0 left-0 right-0 h-0.5 overflow-hidden rounded-b-xl">
            <motion.div
                className={cn("h-full rounded-full opacity-60", colors[type]?.progress || colors.info.progress)}
                style={{ width }}
            />
        </div>
    );
}

function ToastItem({ toast: t, onRemove }) {
    const Icon = icons[t.type] || Info;
    const style = colors[t.type] || colors.info;
    const x = useMotionValue(0);
    const opacity = useTransform(x, [-100, 0, 100], [0, 1, 0]);

    return (
        <motion.div
            layout
            initial={{ opacity: 0, y: 16, scale: 0.96 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, scale: 0.94, transition: { duration: 0.15 } }}
            transition={{ type: "spring", stiffness: 400, damping: 28 }}
            drag="x"
            dragConstraints={{ left: 0, right: 0 }}
            dragElastic={0.6}
            onDragEnd={(_, info) => {
                if (Math.abs(info.offset.x) > 80) {
                    onRemove(t.id);
                }
            }}
            style={{ x, opacity }}
            className={cn(
                "pointer-events-auto relative",
                "flex items-start gap-2.5",
                "rounded-xl border p-3 sm:p-3.5",
                "bg-background/95 backdrop-blur-xl",
                "shadow-[0_4px_24px_rgba(0,0,0,0.08)]",
                "dark:shadow-[0_4px_24px_rgba(0,0,0,0.3)]",
                "cursor-grab active:cursor-grabbing",
                style.bg,
                style.border
            )}
            role="alert"
        >
            {/* Icon */}
            <div
                className={cn(
                    "flex items-center justify-center flex-shrink-0",
                    "w-7 h-7 rounded-lg",
                    style.bg
                )}
            >
                <Icon className={cn("h-4 w-4", style.icon)} />
            </div>

            {/* Content */}
            <div className="flex-1 min-w-0 pt-0.5">
                <p className="text-[13px] font-semibold leading-tight">{t.title}</p>
                {t.description && (
                    <p className="text-xs text-muted-foreground mt-0.5 leading-relaxed">
                        {t.description}
                    </p>
                )}
            </div>

            {/* Close */}
            <button
                onClick={() => onRemove(t.id)}
                className={cn(
                    "flex-shrink-0 rounded-lg p-1",
                    "text-muted-foreground/50",
                    "hover:text-foreground hover:bg-muted/50",
                    "transition-colors duration-150"
                )}
                aria-label="Dismiss"
            >
                <X className="h-3.5 w-3.5" />
            </button>

            {/* Progress bar */}
            <ToastProgress duration={t.duration} type={t.type} />
        </motion.div>
    );
}

export function ToastContainer() {
    const toasts = useToastStore((s) => s.toasts);
    const removeToast = useToastStore((s) => s.removeToast);

    return (
        <div
            className={cn(
                "fixed z-[100] flex flex-col gap-2",
                "pointer-events-none",
                // Mobile: full width bottom
                "bottom-20 left-3 right-3",
                // Desktop: right corner
                "sm:bottom-5 sm:left-auto sm:right-5 sm:max-w-[360px] sm:w-full"
            )}
            aria-live="polite"
        >
            <AnimatePresence mode="popLayout">
                {toasts.map((t) => (
                    <ToastItem key={t.id} toast={t} onRemove={removeToast} />
                ))}
            </AnimatePresence>
        </div>
    );
}