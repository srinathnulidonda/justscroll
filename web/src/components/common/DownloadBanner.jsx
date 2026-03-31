// frontend/src/components/common/DownloadBanner.jsx
import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { motion, AnimatePresence } from "framer-motion";
import { Download, X } from "lucide-react";
import { cn } from "@/lib/utils";

const STORAGE_KEY = "download_banner_dismissed";

export function DownloadBanner() {
    const [visible, setVisible] = useState(false);

    useEffect(() => {
        try {
            if (sessionStorage.getItem(STORAGE_KEY) === "1") return;
        } catch {
            return;
        }

        // Brief delay so the page settles before banner appears
        const timer = setTimeout(() => setVisible(true), 1200);
        return () => clearTimeout(timer);
    }, []);

    const dismiss = () => {
        setVisible(false);
        try {
            sessionStorage.setItem(STORAGE_KEY, "1");
        } catch { }
    };

    return (
        <AnimatePresence>
            {visible && (
                <motion.div
                    initial={{ opacity: 0, y: -8, height: 0 }}
                    animate={{ opacity: 1, y: 0, height: "auto" }}
                    exit={{ opacity: 0, y: -8, height: 0 }}
                    transition={{ duration: 0.25, ease: "easeOut" }}
                    className="md:hidden overflow-hidden"
                >
                    <div
                        className={cn(
                            "flex items-center gap-3",
                            "px-3.5 py-3 rounded-xl",
                            "border border-border/50 bg-card",
                            "shadow-sm"
                        )}
                    >
                        {/* Icon */}
                        <div className="flex items-center justify-center w-10 h-10 rounded-xl bg-primary/10 flex-shrink-0">
                            <Download className="h-[18px] w-[18px] text-primary" />
                        </div>

                        {/* Text */}
                        <div className="flex-1 min-w-0">
                            <p className="text-[13px] font-semibold leading-tight text-foreground">
                                JustScroll for Android
                            </p>
                            <p className="text-[11px] text-muted-foreground mt-0.5 leading-tight">
                                A better reading experience
                            </p>
                        </div>

                        {/* CTA */}
                        <Link
                            to="/download"
                            className={cn(
                                "px-4 py-1.5 rounded-full flex-shrink-0",
                                "text-[12px] font-bold tracking-wide",
                                "bg-primary text-primary-foreground",
                                "active:scale-95",
                                "transition-transform duration-100"
                            )}
                        >
                            GET
                        </Link>

                        {/* Dismiss */}
                        <button
                            onClick={dismiss}
                            className={cn(
                                "p-1.5 -mr-1 rounded-full flex-shrink-0",
                                "text-muted-foreground/60",
                                "hover:text-foreground hover:bg-muted/60",
                                "active:scale-90",
                                "transition-all duration-100"
                            )}
                            aria-label="Dismiss"
                        >
                            <X className="h-3.5 w-3.5" />
                        </button>
                    </div>
                </motion.div>
            )}
        </AnimatePresence>
    );
}