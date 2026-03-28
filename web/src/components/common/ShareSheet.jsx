// frontend/src/components/common/ShareSheet.jsx
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { cn } from "@/lib/utils";
import { toast } from "@/stores/toastStore";
import {
    Share2,
    Link2,
    Twitter,
    MessageCircle,
    Send,
    X,
    Facebook,
    Mail,
} from "lucide-react";

const SHARE_OPTIONS = [
    {
        key: "copy",
        label: "Copy Link",
        icon: Link2,
        color: "bg-muted text-foreground",
        action: (url) => {
            navigator.clipboard?.writeText(url);
            toast.success("Link copied to clipboard");
        },
    },
    {
        key: "twitter",
        label: "Twitter / X",
        icon: Twitter,
        color: "bg-[#1DA1F2]/10 text-[#1DA1F2]",
        action: (url, title) => {
            window.open(
                `https://twitter.com/intent/tweet?text=${encodeURIComponent(title)}&url=${encodeURIComponent(url)}`,
                "_blank",
                "noopener,noreferrer,width=550,height=420"
            );
        },
    },
    {
        key: "whatsapp",
        label: "WhatsApp",
        icon: MessageCircle,
        color: "bg-[#25D366]/10 text-[#25D366]",
        action: (url, title) => {
            window.open(
                `https://wa.me/?text=${encodeURIComponent(`${title} ${url}`)}`,
                "_blank",
                "noopener,noreferrer"
            );
        },
    },
    {
        key: "telegram",
        label: "Telegram",
        icon: Send,
        color: "bg-[#0088CC]/10 text-[#0088CC]",
        action: (url, title) => {
            window.open(
                `https://t.me/share/url?url=${encodeURIComponent(url)}&text=${encodeURIComponent(title)}`,
                "_blank",
                "noopener,noreferrer"
            );
        },
    },
    {
        key: "facebook",
        label: "Facebook",
        icon: Facebook,
        color: "bg-[#1877F2]/10 text-[#1877F2]",
        action: (url) => {
            window.open(
                `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(url)}`,
                "_blank",
                "noopener,noreferrer,width=550,height=420"
            );
        },
    },
    {
        key: "email",
        label: "Email",
        icon: Mail,
        color: "bg-orange-500/10 text-orange-500",
        action: (url, title) => {
            window.open(
                `mailto:?subject=${encodeURIComponent(title)}&body=${encodeURIComponent(`Check this out: ${url}`)}`,
                "_self"
            );
        },
    },
];

export function ShareSheet({ open, onClose, url, title }) {
    const handleShare = async (option) => {
        option.action(url, title);
        if (option.key !== "copy") {
            onClose();
        } else {
            setTimeout(onClose, 600);
        }
    };

    const handleNativeShare = async () => {
        try {
            await navigator.share({ title, url });
            onClose();
        } catch {
            // User cancelled or not supported
        }
    };

    const hasNativeShare = typeof navigator !== "undefined" && !!navigator.share;

    return (
        <AnimatePresence>
            {open && (
                <>
                    {/* Backdrop */}
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        transition={{ duration: 0.2 }}
                        onClick={onClose}
                        className="fixed inset-0 z-50 bg-black/40 backdrop-blur-sm"
                    />

                    {/* Sheet — Bottom on mobile, Center on desktop */}
                    <motion.div
                        initial={{ y: "100%" }}
                        animate={{ y: 0 }}
                        exit={{ y: "100%" }}
                        transition={{
                            type: "spring",
                            stiffness: 400,
                            damping: 34,
                        }}
                        className={cn(
                            "fixed z-50",
                            "bottom-0 left-0 right-0",
                            "sm:bottom-auto sm:top-1/2 sm:left-1/2",
                            "sm:-translate-x-1/2 sm:-translate-y-1/2",
                            "sm:max-w-sm sm:w-full sm:rounded-2xl",
                            "rounded-t-2xl",
                            "bg-background border border-border/50",
                            "shadow-[0_-8px_40px_rgba(0,0,0,0.15)]",
                            "dark:shadow-[0_-8px_40px_rgba(0,0,0,0.4)]",
                            "sm:shadow-[0_8px_40px_rgba(0,0,0,0.15)]",
                            "overflow-hidden"
                        )}
                        style={{
                            paddingBottom: "env(safe-area-inset-bottom)",
                        }}
                    >
                        {/* Handle */}
                        <div className="flex justify-center pt-3 pb-1 sm:hidden">
                            <div className="w-9 h-1 rounded-full bg-muted-foreground/20" />
                        </div>

                        {/* Header */}
                        <div className="flex items-center justify-between px-5 pt-3 sm:pt-5 pb-2">
                            <h3 className="text-base font-semibold">Share</h3>
                            <button
                                onClick={onClose}
                                className={cn(
                                    "flex items-center justify-center",
                                    "w-8 h-8 rounded-full",
                                    "text-muted-foreground",
                                    "hover:bg-muted hover:text-foreground",
                                    "transition-colors duration-150"
                                )}
                                aria-label="Close"
                            >
                                <X className="h-4 w-4" />
                            </button>
                        </div>

                        {/* Title preview */}
                        <div className="px-5 pb-4">
                            <p className="text-xs text-muted-foreground truncate">
                                {title}
                            </p>
                        </div>

                        {/* Native share button (mobile) */}
                        {hasNativeShare && (
                            <div className="px-5 pb-3">
                                <button
                                    onClick={handleNativeShare}
                                    className={cn(
                                        "w-full flex items-center justify-center gap-2",
                                        "px-4 py-2.5 rounded-xl",
                                        "bg-primary text-primary-foreground",
                                        "text-sm font-medium",
                                        "active:scale-[0.98]",
                                        "transition-transform duration-150"
                                    )}
                                >
                                    <Share2 className="h-4 w-4" />
                                    More Options
                                </button>
                            </div>
                        )}

                        {/* Share grid */}
                        <div className="px-5 pb-5 sm:pb-6">
                            <div className="grid grid-cols-4 gap-3">
                                {SHARE_OPTIONS.map((option) => {
                                    const Icon = option.icon;
                                    return (
                                        <motion.button
                                            key={option.key}
                                            whileTap={{ scale: 0.9 }}
                                            onClick={() => handleShare(option)}
                                            className={cn(
                                                "flex flex-col items-center gap-1.5",
                                                "py-3 rounded-xl",
                                                "hover:bg-muted/50",
                                                "active:bg-muted",
                                                "transition-colors duration-150"
                                            )}
                                        >
                                            <div
                                                className={cn(
                                                    "flex items-center justify-center",
                                                    "w-11 h-11 rounded-2xl",
                                                    option.color
                                                )}
                                            >
                                                <Icon className="h-5 w-5" />
                                            </div>
                                            <span className="text-[10px] font-medium text-muted-foreground leading-tight text-center">
                                                {option.label}
                                            </span>
                                        </motion.button>
                                    );
                                })}
                            </div>
                        </div>
                    </motion.div>
                </>
            )}
        </AnimatePresence>
    );
}