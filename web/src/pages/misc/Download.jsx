// frontend/src/pages/misc/Download.jsx
import { Link } from "react-router-dom";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";
import { Download, ExternalLink, ArrowLeft, Smartphone, Monitor } from "lucide-react";

const VERSION = "1.0.0";
const RELEASE = "December 2025";

const DOWNLOADS = [
    {
        label: "ARM64 APK",
        note: "Recommended · Modern devices (2018+)",
        size: "19.5 MB",
        url: "https://github.com/srinathnulidonda/justscroll/releases/download/v1.0.0/justscroll-v1.0.0-arm64.apk",
        primary: true,
    },
    {
        label: "Legacy APK",
        note: "Older Android devices",
        size: "22.1 MB",
        url: "https://github.com/srinathnulidonda/justscroll/releases/download/v1.0.0/justscroll-v1.0.0-legacy.apk",
    },
    {
        label: "Google Drive Mirror",
        note: "Alternative download source",
        url: "https://drive.google.com/file/d/1itP7SCk5OTgMyM0O15-Dq-hyTtrDqJKP/view?usp=sharing",
        external: true,
    },
];

const REQUIREMENTS = [
    { label: "Android", value: "5.0+" },
    { label: "Storage", value: "~50 MB" },
    { label: "Architecture", value: "ARM64 / ARMv7" },
];

const INSTALL_STEPS = [
    "Download the APK file above",
    'Open Settings → Security → Enable "Unknown sources"',
    "Tap the downloaded file to install",
];

export default function DownloadPage() {
    return (
        <div className="mx-auto max-w-xl px-4 sm:px-6 py-8 sm:py-14">
            <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.25 }}
                className="space-y-8"
            >
                {/* Back */}
                <Link
                    to="/"
                    className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
                >
                    <ArrowLeft className="h-3.5 w-3.5" />
                    Home
                </Link>

                {/* Header */}
                <div className="space-y-2">
                    <div className="flex items-center gap-3">
                        <div className="flex items-center justify-center w-11 h-11 rounded-xl bg-primary/10 flex-shrink-0">
                            <Smartphone className="h-5 w-5 text-primary" />
                        </div>
                        <div>
                            <h1 className="text-xl sm:text-2xl font-bold tracking-tight">
                                Download for Android
                            </h1>
                            <p className="text-xs sm:text-sm text-muted-foreground mt-0.5">
                                v{VERSION} · {RELEASE}
                            </p>
                        </div>
                    </div>
                </div>

                {/* Downloads */}
                <div className="space-y-2">
                    {DOWNLOADS.map((item) => (
                        <a
                            key={item.label}
                            href={item.url}
                            target={item.external ? "_blank" : undefined}
                            rel={item.external ? "noopener noreferrer" : undefined}
                            className={cn(
                                "flex items-center gap-3 w-full p-3.5 sm:p-4 rounded-xl border",
                                "transition-all duration-150 active:scale-[0.99]",
                                item.primary
                                    ? "bg-primary text-primary-foreground border-primary hover:bg-primary/90"
                                    : "bg-card border-border/50 hover:border-border hover:bg-muted/40"
                            )}
                        >
                            <Download
                                className={cn(
                                    "h-4.5 w-4.5 flex-shrink-0",
                                    item.primary ? "text-primary-foreground/80" : "text-muted-foreground"
                                )}
                            />
                            <div className="flex-1 min-w-0">
                                <div className="flex items-center gap-2">
                                    <p className={cn(
                                        "text-sm font-medium",
                                        !item.primary && "text-foreground"
                                    )}>
                                        {item.label}
                                    </p>
                                    {item.size && (
                                        <span className={cn(
                                            "text-[11px]",
                                            item.primary
                                                ? "text-primary-foreground/60"
                                                : "text-muted-foreground/70"
                                        )}>
                                            {item.size}
                                        </span>
                                    )}
                                </div>
                                <p className={cn(
                                    "text-xs mt-0.5",
                                    item.primary ? "text-primary-foreground/70" : "text-muted-foreground"
                                )}>
                                    {item.note}
                                </p>
                            </div>
                            {item.external && (
                                <ExternalLink className="h-3.5 w-3.5 text-muted-foreground flex-shrink-0" />
                            )}
                        </a>
                    ))}
                </div>

                {/* Requirements + Install — Side by side on sm+ */}
                <div className="grid sm:grid-cols-2 gap-3">
                    {/* Requirements */}
                    <div className="rounded-xl border border-border/50 bg-card p-4">
                        <p className="text-[11px] font-semibold text-muted-foreground uppercase tracking-wider mb-3">
                            Requirements
                        </p>
                        <dl className="space-y-2">
                            {REQUIREMENTS.map((req) => (
                                <div key={req.label} className="flex items-center justify-between">
                                    <dt className="text-sm text-muted-foreground">{req.label}</dt>
                                    <dd className="text-sm font-medium">{req.value}</dd>
                                </div>
                            ))}
                        </dl>
                    </div>

                    {/* Install */}
                    <div className="rounded-xl border border-border/50 bg-card p-4">
                        <p className="text-[11px] font-semibold text-muted-foreground uppercase tracking-wider mb-3">
                            Install
                        </p>
                        <ol className="space-y-2">
                            {INSTALL_STEPS.map((step, i) => (
                                <li
                                    key={i}
                                    className="flex items-start gap-2.5 text-sm text-muted-foreground"
                                >
                                    <span className="text-[11px] font-mono text-muted-foreground/50 mt-px flex-shrink-0">
                                        {i + 1}.
                                    </span>
                                    <span className="leading-snug">{step}</span>
                                </li>
                            ))}
                        </ol>
                    </div>
                </div>

                {/* Web alternative + Source */}
                <div className="flex items-center justify-between pt-2">
                    <Link
                        to="/"
                        className="inline-flex items-center gap-1.5 text-xs text-muted-foreground hover:text-foreground transition-colors"
                    >
                        <Monitor className="h-3 w-3" />
                        Continue on web
                    </Link>
                    <a
                        href="https://github.com/srinathnulidonda/justscroll/releases/tag/v1.0.0"
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center gap-1.5 text-xs text-muted-foreground hover:text-foreground transition-colors"
                    >
                        All releases
                        <ExternalLink className="h-3 w-3" />
                    </a>
                </div>
            </motion.div>
        </div>
    );
}