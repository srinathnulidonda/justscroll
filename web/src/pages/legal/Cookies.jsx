// frontend/src/pages/Cookies.jsx
import { useState, useEffect, useRef } from "react";
import { Link } from "react-router-dom";
import { ArrowLeft, Cookie, ChevronRight, AlertTriangle } from "lucide-react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";

const LAST_UPDATED = "June 15, 2025";

const cookieTypes = [
    {
        name: "Authentication Tokens",
        storage: "Local Storage",
        keys: ["access_token", "refresh_token", "user_data"],
        purpose:
            "Used to authenticate your sessions and keep you signed in. Access tokens are short-lived; refresh tokens allow seamless session renewal without re-entering your credentials.",
        duration: "Access token: ~15 minutes | Refresh token: ~7 days",
        required: true,
    },
    {
        name: "Theme Preference",
        storage: "Local Storage",
        keys: ["theme"],
        purpose:
            "Stores your preferred visual theme (light or dark mode) so the interface matches your preference every time you visit.",
        duration: "Persistent until changed",
        required: false,
    },
    {
        name: "Reader Settings",
        storage: "Local Storage",
        keys: ["reader_quality", "reader_mode", "reader_bg", "reader_autohide", "reader_direction"],
        purpose:
            "Saves your manga reader preferences including image quality (high/data saver), reading mode (single page/continuous scroll), background color, toolbar behavior, and page direction (LTR/RTL).",
        duration: "Persistent until changed",
        required: false,
    },
];

const sections = [
    {
        id: "what-we-store",
        number: "1",
        title: "What We Store",
        content: [
            {
                text: 'JustScroll primarily uses browser local storage rather than traditional HTTP cookies. Local storage allows us to save your preferences directly on your device without transmitting them with every request.',
            },
        ],
    },
    {
        id: "third-party",
        number: "2",
        title: "Third-Party Cookies",
        content: [
            {
                text: "JustScroll does not use any third-party cookies, tracking pixels, or analytics scripts such as Google Analytics, Facebook Pixel, or similar services. We do not track you across other websites.",
            },
        ],
    },
    {
        id: "managing",
        number: "3",
        title: "Managing Your Data",
        content: [
            { text: "You can manage or clear local storage data at any time:" },
            {
                list: [
                    'Clear all data — Use your browser\'s "Clear browsing data" feature and select "Cookies and site data" or "Local storage"',
                    "Selective clearing — Open browser DevTools (F12) → Application tab → Local Storage → select and delete specific keys",
                    "Sign out — Signing out of JustScroll will automatically clear authentication tokens",
                ],
            },
        ],
    },
    {
        id: "contact",
        number: "4",
        title: "Contact",
        content: [
            {
                text: "If you have questions about our use of local storage or this Cookie Policy, please contact us at srinathnulidonda.dev@gmail.com.",
            },
        ],
    },
];

function MobileCookieTable() {
    return (
        <div className="overflow-x-auto -mx-4 sm:mx-0">
            <div className="min-w-[600px] sm:min-w-0">
                <table className="w-full text-sm">
                    <thead>
                        <tr className="border-b border-border">
                            <th className="text-left py-3 px-4 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Key</th>
                            <th className="text-left py-3 px-4 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Type</th>
                            <th className="text-left py-3 px-4 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Purpose</th>
                            <th className="text-left py-3 px-4 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Required</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-border/50">
                        {cookieTypes.flatMap((cookie) =>
                            cookie.keys.map((key, j) => (
                                <tr key={key} className="hover:bg-muted/30 transition-colors">
                                    <td className="py-2.5 px-4">
                                        <code className="text-xs bg-muted px-1.5 py-0.5 rounded font-mono">{key}</code>
                                    </td>
                                    <td className="py-2.5 px-4 text-xs text-muted-foreground">{cookie.storage}</td>
                                    <td className="py-2.5 px-4 text-xs text-muted-foreground">{j === 0 ? cookie.name : "↑"}</td>
                                    <td className="py-2.5 px-4">
                                        <span className={cn(
                                            "inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium",
                                            cookie.required ? "bg-primary/10 text-primary" : "bg-muted text-muted-foreground"
                                        )}>
                                            {cookie.required ? "Essential" : "Preference"}
                                        </span>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
}

function DesktopReferenceTable() {
    return (
        <div className="rounded-xl border border-border/50 bg-card overflow-hidden">
            <div className="overflow-x-auto">
                <table className="w-full text-sm min-w-[550px]">
                    <thead>
                        <tr className="border-b border-border bg-muted/30">
                            <th className="text-left py-3 px-4 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Storage Key</th>
                            <th className="text-left py-3 px-4 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Category</th>
                            <th className="text-left py-3 px-4 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Group</th>
                            <th className="text-left py-3 px-4 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Type</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-border/30">
                        {cookieTypes.flatMap((item) =>
                            item.keys.map((key, j) => (
                                <tr key={key} className="hover:bg-muted/20 transition-colors">
                                    <td className="py-2.5 px-4">
                                        <code className="text-[12px] bg-muted px-1.5 py-0.5 rounded font-mono">{key}</code>
                                    </td>
                                    <td className="py-2.5 px-4">
                                        <span className={cn(
                                            "inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium",
                                            item.required ? "bg-primary/10 text-primary" : "bg-muted text-muted-foreground"
                                        )}>
                                            {item.category || (item.required ? "Essential" : "Preference")}
                                        </span>
                                    </td>
                                    <td className="py-2.5 px-4 text-[13px] text-muted-foreground">{j === 0 ? item.name : "—"}</td>
                                    <td className="py-2.5 px-4 text-[13px] text-muted-foreground">Local Storage</td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
}

function StorageCard({ cookie }) {
    return (
        <div className={cn(
            "rounded-xl border bg-card p-4 lg:p-5 space-y-3",
            cookie.required ? "border-primary/20" : "border-border/50"
        )}>
            <div className="flex items-center justify-between gap-3">
                <h3 className="text-sm lg:text-base font-semibold">{cookie.name}</h3>
                <span className={cn(
                    "inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] lg:text-[11px] font-medium flex-shrink-0",
                    cookie.required ? "bg-primary/10 text-primary" : "bg-muted text-muted-foreground"
                )}>
                    {cookie.required ? "Essential" : "Preference"}
                </span>
            </div>
            <p className="text-sm text-muted-foreground leading-relaxed">{cookie.purpose}</p>
            <div className="flex flex-wrap gap-1.5">
                {cookie.keys.map((key) => (
                    <code key={key} className="text-[11px] bg-muted px-2 py-0.5 rounded font-mono text-muted-foreground">{key}</code>
                ))}
            </div>
            <p className="text-xs text-muted-foreground">
                <span className="font-medium text-foreground">Duration:</span> {cookie.duration}
            </p>
        </div>
    );
}

function TableOfContents({ activeId }) {
    const allSections = [
        ...sections.slice(0, 1),
        { id: "storage-details", title: "Storage Details" },
        ...sections.slice(1),
        { id: "reference-table", title: "Reference Table" },
    ];
    return (
        <nav className="space-y-1" aria-label="Table of contents">
            {allSections.map((s, i) => (
                <a
                    key={s.id}
                    href={`#${s.id}`}
                    className={cn(
                        "flex items-center gap-2 px-3 py-2 rounded-lg text-[13px] transition-all duration-150",
                        activeId === s.id
                            ? "bg-primary/10 text-primary font-medium"
                            : "text-muted-foreground hover:text-foreground hover:bg-muted/50"
                    )}
                >
                    <span className="text-[11px] font-mono text-muted-foreground/60 w-5">
                        {String(i + 1).padStart(2, "0")}
                    </span>
                    {s.title}
                </a>
            ))}
        </nav>
    );
}

function DesktopSection({ section, index }) {
    return (
        <section id={section.id} className="scroll-mt-24">
            <div className="flex items-center gap-3 mb-4">
                <span className="flex items-center justify-center w-8 h-8 rounded-lg bg-muted text-xs font-mono font-semibold text-muted-foreground">
                    {String(index + 1).padStart(2, "0")}
                </span>
                <h2 className="text-xl font-semibold tracking-tight">{section.title}</h2>
            </div>
            <div className="space-y-4 pl-11">
                {section.content.map((block, i) => (
                    <div key={i}>
                        {block.text && (
                            <p className="text-[15px] text-muted-foreground leading-[1.8]">{block.text}</p>
                        )}
                        {block.list && (
                            <ul className="space-y-2 text-[15px] text-muted-foreground">
                                {block.list.map((item, j) => (
                                    <li key={j} className="flex gap-2.5 leading-[1.75]">
                                        <ChevronRight className="h-4 w-4 text-primary/50 flex-shrink-0 mt-[5px]" />
                                        <span>{item}</span>
                                    </li>
                                ))}
                            </ul>
                        )}
                    </div>
                ))}
            </div>
        </section>
    );
}

export default function Cookies() {
    const [activeId, setActiveId] = useState("what-we-store");
    const observerRef = useRef(null);

    useEffect(() => {
        const ids = [...sections.map((s) => s.id), "storage-details", "reference-table"];
        observerRef.current = new IntersectionObserver(
            (entries) => {
                const visible = entries
                    .filter((e) => e.isIntersecting)
                    .sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top);
                if (visible.length > 0) setActiveId(visible[0].target.id);
            },
            { rootMargin: "-100px 0px -60% 0px", threshold: 0 }
        );
        ids.forEach((id) => {
            const el = document.getElementById(id);
            if (el) observerRef.current.observe(el);
        });
        return () => observerRef.current?.disconnect();
    }, []);

    return (
        <div className="min-h-screen">
            {/* ─── MOBILE ─── */}
            <div className="lg:hidden">
                <div className="mx-auto max-w-site px-4 sm:px-6 lg:px-8 py-8">
                    <motion.div
                        initial={{ opacity: 0, y: 12 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.3 }}
                    >
                        <Link
                            to="/"
                            className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors mb-8"
                        >
                            <ArrowLeft className="h-4 w-4" />
                            Back to Home
                        </Link>

                        <div className="flex items-start gap-4 mb-8">
                            <div className="flex items-center justify-center w-12 h-12 rounded-2xl bg-primary/10 flex-shrink-0">
                                <Cookie className="h-6 w-6 text-primary" />
                            </div>
                            <div>
                                <h1 className="text-2xl sm:text-3xl font-bold tracking-tight">
                                    Cookie Policy
                                </h1>
                                <p className="text-sm text-muted-foreground mt-1">
                                    Last updated: {LAST_UPDATED}
                                </p>
                            </div>
                        </div>

                        <div className="rounded-xl border border-border/50 bg-card p-4 sm:p-5 mb-8">
                            <p className="text-sm sm:text-[15px] text-muted-foreground leading-relaxed">
                                JustScroll uses browser local storage (similar to cookies) to
                                enhance your experience. Unlike traditional cookies, local
                                storage data is never sent to our servers automatically — it
                                stays on your device. This policy explains what data we store
                                and why.
                            </p>
                        </div>

                        <div className="space-y-8">
                            {/* What we store */}
                            <div className="space-y-3">
                                <h2 className="text-lg font-semibold">1. What We Store</h2>
                                <p className="text-sm text-muted-foreground leading-relaxed">
                                    JustScroll primarily uses{" "}
                                    <strong className="text-foreground">browser local storage</strong>{" "}
                                    rather than traditional HTTP cookies. Local storage allows us to
                                    save your preferences directly on your device without transmitting
                                    them with every request.
                                </p>
                            </div>

                            {/* Storage Details */}
                            <div className="space-y-4">
                                <h2 className="text-lg font-semibold">2. Storage Details</h2>
                                {cookieTypes.map((cookie, i) => (
                                    <StorageCard key={i} cookie={cookie} />
                                ))}
                            </div>

                            {/* Table */}
                            <div className="space-y-3">
                                <h2 className="text-lg font-semibold">3. Complete Reference</h2>
                                <div className="rounded-xl border border-border/50 bg-card overflow-hidden">
                                    <MobileCookieTable />
                                </div>
                            </div>

                            {/* Third-party */}
                            <div className="space-y-3">
                                <h2 className="text-lg font-semibold">4. Third-Party Cookies</h2>
                                <p className="text-sm text-muted-foreground leading-relaxed">
                                    JustScroll does <strong className="text-foreground">not</strong> use
                                    any third-party cookies, tracking pixels, or analytics scripts such
                                    as Google Analytics, Facebook Pixel, or similar services. We do not
                                    track you across other websites.
                                </p>
                            </div>

                            {/* Managing */}
                            <div className="space-y-3">
                                <h2 className="text-lg font-semibold">5. Managing Your Data</h2>
                                <p className="text-sm text-muted-foreground leading-relaxed">
                                    You can manage or clear local storage data at any time:
                                </p>
                                <ul className="list-disc list-inside space-y-1.5 text-sm text-muted-foreground ml-1">
                                    <li>
                                        <strong className="text-foreground">Clear all data:</strong>{" "}
                                        Use your browser's "Clear browsing data" feature
                                    </li>
                                    <li>
                                        <strong className="text-foreground">Selective clearing:</strong>{" "}
                                        DevTools (F12) → Application → Local Storage
                                    </li>
                                    <li>
                                        <strong className="text-foreground">Sign out:</strong>{" "}
                                        Automatically clears authentication tokens
                                    </li>
                                </ul>
                                <div className="rounded-xl border border-amber-500/20 bg-amber-500/5 p-4">
                                    <p className="text-sm text-amber-600 dark:text-amber-400">
                                        <strong>Note:</strong> Clearing essential storage data will sign
                                        you out. Clearing preference data will reset your theme and
                                        reader settings to defaults.
                                    </p>
                                </div>
                            </div>

                            {/* Contact */}
                            <div className="space-y-3">
                                <h2 className="text-lg font-semibold">6. Contact</h2>
                                <p className="text-sm text-muted-foreground leading-relaxed">
                                    If you have questions about our use of local storage or this
                                    Cookie Policy, please contact us at{" "}
                                    <strong className="text-foreground">srinathnulidonda.dev@gmail.com</strong>.
                                </p>
                            </div>
                        </div>
                    </motion.div>
                </div>
            </div>

            {/* ─── DESKTOP ─── */}
            <div className="hidden lg:block">
                <div className="border-b border-border/50">
                    <div className="mx-auto max-w-site px-4 sm:px-6 lg:px-8 py-14">
                        <motion.div
                            initial={{ opacity: 0, y: 8 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.3 }}
                        >
                            <Link
                                to="/"
                                className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors mb-6"
                            >
                                <ArrowLeft className="h-3.5 w-3.5" />
                                Home
                            </Link>

                            <div className="flex items-start gap-4">
                                <div className="flex items-center justify-center w-12 h-12 rounded-2xl bg-primary/10 flex-shrink-0">
                                    <Cookie className="h-5 w-5 text-primary" />
                                </div>
                                <div>
                                    <h1 className="text-4xl font-bold tracking-tight">Cookie Policy</h1>
                                    <p className="mt-2 text-sm text-muted-foreground">
                                        Last updated: {LAST_UPDATED}
                                    </p>
                                </div>
                            </div>

                            <p className="mt-6 max-w-3xl text-[15px] text-muted-foreground leading-[1.75]">
                                This policy explains how JustScroll uses browser local storage to
                                save your preferences and manage authentication. We believe in full
                                transparency about the data stored on your device.
                            </p>
                        </motion.div>
                    </div>
                </div>

                <div className="mx-auto max-w-site px-4 sm:px-6 lg:px-8 py-12">
                    <div className="grid grid-cols-12 gap-12">
                        <aside className="col-span-3">
                            <div className="sticky top-20">
                                <p className="text-[11px] font-semibold text-muted-foreground uppercase tracking-widest mb-3 px-3">
                                    On this page
                                </p>
                                <TableOfContents activeId={activeId} />
                                <div className="mt-6 mx-3 pt-6 border-t border-border/40">
                                    <div className="flex flex-col gap-2 text-[13px]">
                                        <Link to="/privacy" className="text-muted-foreground hover:text-foreground transition-colors">
                                            Privacy Policy →
                                        </Link>
                                        <Link to="/terms" className="text-muted-foreground hover:text-foreground transition-colors">
                                            Terms of Service →
                                        </Link>
                                    </div>
                                </div>
                            </div>
                        </aside>

                        <motion.div
                            initial={{ opacity: 0, y: 8 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.4, delay: 0.1 }}
                            className="col-span-9 space-y-12"
                        >
                            {/* What We Store */}
                            <DesktopSection section={sections[0]} index={0} />

                            {/* Storage Details — cards */}
                            <section id="storage-details" className="scroll-mt-24">
                                <div className="flex items-center gap-3 mb-4">
                                    <span className="flex items-center justify-center w-8 h-8 rounded-lg bg-muted text-xs font-mono font-semibold text-muted-foreground">
                                        02
                                    </span>
                                    <h2 className="text-xl font-semibold tracking-tight">Storage Details</h2>
                                </div>
                                <div className="grid grid-cols-3 gap-4 pl-11">
                                    {cookieTypes.map((cookie, i) => (
                                        <StorageCard key={i} cookie={cookie} />
                                    ))}
                                </div>
                            </section>

                            {/* Third-party */}
                            <DesktopSection section={sections[1]} index={2} />

                            {/* Managing */}
                            <DesktopSection section={sections[2]} index={3} />

                            {/* Warning */}
                            <div className="pl-11">
                                <div className="flex gap-3 rounded-xl border border-amber-500/20 bg-amber-500/5 p-5">
                                    <AlertTriangle className="h-5 w-5 text-amber-500 flex-shrink-0 mt-0.5" />
                                    <div className="space-y-1">
                                        <p className="text-sm font-medium text-amber-600 dark:text-amber-400">Important</p>
                                        <p className="text-[14px] text-amber-600/80 dark:text-amber-400/80 leading-relaxed">
                                            Clearing essential storage data (authentication tokens) will
                                            immediately sign you out. Clearing preference data will reset
                                            your visual theme and reader configuration to default values.
                                            Your server-side account data remains unaffected.
                                        </p>
                                    </div>
                                </div>
                            </div>

                            {/* Reference Table */}
                            <section id="reference-table" className="scroll-mt-24">
                                <div className="flex items-center gap-3 mb-4">
                                    <span className="flex items-center justify-center w-8 h-8 rounded-lg bg-muted text-xs font-mono font-semibold text-muted-foreground">
                                        05
                                    </span>
                                    <h2 className="text-xl font-semibold tracking-tight">Complete Reference</h2>
                                </div>
                                <div className="pl-11">
                                    <DesktopReferenceTable />
                                </div>
                            </section>

                            {/* Contact */}
                            <DesktopSection section={sections[3]} index={5} />

                            {/* Bottom */}
                            <div className="pt-8 mt-8 border-t border-border/40 flex items-center justify-between">
                                <p className="text-xs text-muted-foreground/60">
                                    © {new Date().getFullYear()} JustScroll. All rights reserved.
                                </p>
                                <div className="flex items-center gap-4 text-xs">
                                    <Link to="/privacy" className="text-muted-foreground hover:text-foreground transition-colors">
                                        Privacy Policy
                                    </Link>
                                    <Link to="/terms" className="text-muted-foreground hover:text-foreground transition-colors">
                                        Terms of Service
                                    </Link>
                                    <a href="mailto:srinathnulidonda.dev@gmail.com" className="text-primary hover:underline">
                                        Contact
                                    </a>
                                </div>
                            </div>
                        </motion.div>
                    </div>
                </div>
            </div>
        </div>
    );
}