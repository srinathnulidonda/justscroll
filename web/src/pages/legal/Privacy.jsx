// frontend/src/pages/Privacy.jsx
import { useState, useEffect, useRef } from "react";
import { Link } from "react-router-dom";
import { ArrowLeft, Shield, ChevronRight } from "lucide-react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";

const LAST_UPDATED = "June 15, 2025";
const EFFECTIVE_DATE = "June 15, 2025";

const sections = [
    {
        id: "information-we-collect",
        number: "1",
        title: "Information We Collect",
        content: [
            {
                subtitle: "Account Information",
                text: "When you create an account, we collect your username, email address, and a securely hashed password. We never store your password in plain text.",
            },
            {
                subtitle: "Reading Data",
                text: "We collect information about your reading activity, including bookmarked manga, reading history, chapter progress, and page position. This data is used solely to provide you with a seamless reading experience across devices.",
            },
            {
                subtitle: "Automatically Collected Information",
                text: "When you use JustScroll, we may automatically collect certain technical information, including your IP address, browser type, device information, operating system, and general usage patterns. This information helps us maintain and improve the service.",
            },
            {
                subtitle: "Local Storage Data",
                text: "We use your browser's local storage to save your preferences such as theme (light/dark mode), reader settings (image quality, reading mode, page direction), and authentication tokens for session management.",
            },
        ],
    },
    {
        id: "how-we-use",
        number: "2",
        title: "How We Use Your Information",
        content: [
            {
                text: "We use the information we collect for the following purposes:",
            },
            {
                list: [
                    "To create and manage your account",
                    "To save and sync your bookmarks and reading progress",
                    "To personalize your reading experience and preferences",
                    "To authenticate your sessions and maintain security",
                    "To improve, maintain, and optimize our service",
                    "To communicate with you about service-related matters",
                    "To detect, prevent, and address technical issues or abuse",
                ],
            },
        ],
    },
    {
        id: "data-sharing",
        number: "3",
        title: "Data Sharing & Third Parties",
        content: [
            {
                text: "JustScroll does not sell, trade, or rent your personal information to third parties. We may share data only in the following circumstances:",
            },
            {
                list: [
                    "With third-party APIs (MangaDex, Jikan, ComicVine) to fetch manga content — only non-personal request data is shared",
                    "When required by law, regulation, or legal process",
                    "To protect the rights, safety, or property of JustScroll, our users, or the public",
                    "With your explicit consent",
                ],
            },
        ],
    },
    {
        id: "data-security",
        number: "4",
        title: "Data Security",
        content: [
            {
                text: "We implement industry-standard security measures to protect your personal information, including:",
            },
            {
                list: [
                    "Secure password hashing using bcrypt",
                    "JWT-based authentication with access and refresh tokens",
                    "HTTPS encryption for all data in transit",
                    "Regular security audits and updates",
                ],
            },
            {
                text: "While we strive to protect your data, no method of transmission over the internet or electronic storage is 100% secure. We cannot guarantee absolute security.",
            },
        ],
    },
    {
        id: "data-retention",
        number: "5",
        title: "Data Retention",
        content: [
            {
                text: "We retain your personal information for as long as your account is active or as needed to provide you with our services. If you delete your account, we will delete or anonymize your personal data within 30 days, except where we are required to retain it by law.",
            },
            {
                text: "Reading history and bookmark data are retained for the lifetime of your account to ensure a continuous experience.",
            },
        ],
    },
    {
        id: "your-rights",
        number: "6",
        title: "Your Rights",
        content: [
            {
                text: "Depending on your jurisdiction, you may have the following rights regarding your personal data:",
            },
            {
                list: [
                    "Access — Request a copy of the personal data we hold about you",
                    "Correction — Request correction of inaccurate or incomplete data",
                    "Deletion — Request deletion of your personal data and account",
                    "Portability — Request your data in a structured, machine-readable format",
                    "Objection — Object to certain processing of your personal data",
                    "Withdrawal — Withdraw consent at any time where processing is based on consent",
                ],
            },
            {
                text: 'To exercise any of these rights, please contact us at the email provided in the "Contact" section below.',
            },
        ],
    },
    {
        id: "childrens-privacy",
        number: "7",
        title: "Children's Privacy",
        content: [
            {
                text: "JustScroll is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If we discover that we have collected data from a child under 13, we will delete it promptly. If you believe a child under 13 has provided us with personal data, please contact us immediately.",
            },
        ],
    },
    {
        id: "image-proxying",
        number: "8",
        title: "Image Proxying",
        content: [
            {
                text: "JustScroll uses a server-side image proxy to serve manga cover art and chapter pages. This proxy fetches images from third-party sources (such as MangaDex CDN) on your behalf. Your IP address is not exposed to these third-party image servers; instead, our server makes the request. The proxied images are not stored permanently on our servers.",
            },
        ],
    },
    {
        id: "policy-changes",
        number: "9",
        title: "Changes to This Policy",
        content: [
            {
                text: 'We may update this Privacy Policy from time to time to reflect changes in our practices, technology, or legal requirements. We will notify you of any material changes by posting the updated policy on this page and updating the "Last Updated" date. Your continued use of JustScroll after any changes constitutes acceptance of the updated policy.',
            },
        ],
    },
    {
        id: "contact",
        number: "10",
        title: "Contact Us",
        content: [
            {
                text: "If you have any questions, concerns, or requests regarding this Privacy Policy or our data practices, please contact us at:",
            },
            { text: "Email: srinathnulidonda.dev@gmail.com" },
            {
                text: "We aim to respond to all inquiries within 48 hours.",
            },
        ],
    },
];

function TableOfContents({ activeId }) {
    return (
        <nav className="space-y-1" aria-label="Table of contents">
            {sections.map((s, i) => (
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

function MobileSection({ section }) {
    return (
        <div className="space-y-3">
            <h2 className="text-lg font-semibold text-foreground">
                {section.number}. {section.title}
            </h2>
            {section.content.map((block, i) => (
                <div key={i}>
                    {block.subtitle && (
                        <h3 className="text-sm font-semibold text-foreground mt-4 mb-1.5">
                            {block.subtitle}
                        </h3>
                    )}
                    {block.text && (
                        <p className="text-sm text-muted-foreground leading-relaxed">
                            {block.text}
                        </p>
                    )}
                    {block.list && (
                        <ul className="list-disc list-inside space-y-1.5 text-sm text-muted-foreground ml-1">
                            {block.list.map((item, j) => (
                                <li key={j} className="leading-relaxed">
                                    {item}
                                </li>
                            ))}
                        </ul>
                    )}
                </div>
            ))}
        </div>
    );
}

function DesktopSection({ section, index }) {
    return (
        <section id={section.id} className="scroll-mt-24">
            <div className="flex items-center gap-3 mb-4">
                <span className="flex items-center justify-center w-8 h-8 rounded-lg bg-muted text-xs font-mono font-semibold text-muted-foreground">
                    {String(index + 1).padStart(2, "0")}
                </span>
                <h2 className="text-xl font-semibold tracking-tight">
                    {section.title}
                </h2>
            </div>
            <div className="space-y-4 pl-11">
                {section.content.map((block, i) => (
                    <div key={i}>
                        {block.subtitle && (
                            <h3 className="text-[15px] font-semibold text-foreground mb-1.5">
                                {block.subtitle}
                            </h3>
                        )}
                        {block.text && (
                            <p className="text-[15px] text-muted-foreground leading-[1.8]">
                                {block.text}
                            </p>
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

export default function Privacy() {
    const [activeId, setActiveId] = useState(sections[0].id);
    const observerRef = useRef(null);

    useEffect(() => {
        observerRef.current = new IntersectionObserver(
            (entries) => {
                const visible = entries
                    .filter((e) => e.isIntersecting)
                    .sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top);
                if (visible.length > 0) setActiveId(visible[0].target.id);
            },
            { rootMargin: "-100px 0px -60% 0px", threshold: 0 }
        );
        sections.forEach((s) => {
            const el = document.getElementById(s.id);
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
                                <Shield className="h-6 w-6 text-primary" />
                            </div>
                            <div>
                                <h1 className="text-2xl sm:text-3xl font-bold tracking-tight">
                                    Privacy Policy
                                </h1>
                                <p className="text-sm text-muted-foreground mt-1">
                                    Last updated: {LAST_UPDATED}
                                </p>
                            </div>
                        </div>

                        <div className="rounded-xl border border-border/50 bg-card p-4 sm:p-5 mb-8">
                            <p className="text-sm sm:text-[15px] text-muted-foreground leading-relaxed">
                                At JustScroll, we take your privacy seriously. This Privacy
                                Policy explains how we collect, use, disclose, and safeguard
                                your information when you use our manga reading platform.
                                Please read this policy carefully. By using JustScroll, you
                                agree to the collection and use of information in accordance
                                with this policy.
                            </p>
                        </div>

                        <div className="space-y-8">
                            {sections.map((section, i) => (
                                <MobileSection key={i} section={section} />
                            ))}
                        </div>
                    </motion.div>
                </div>
            </div>

            {/* ─── DESKTOP ─── */}
            <div className="hidden lg:block">
                {/* Header */}
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
                                    <Shield className="h-5 w-5 text-primary" />
                                </div>
                                <div>
                                    <h1 className="text-4xl font-bold tracking-tight">
                                        Privacy Policy
                                    </h1>
                                    <div className="flex items-center gap-3 mt-2 text-sm text-muted-foreground">
                                        <span>Last updated: {LAST_UPDATED}</span>
                                        <span className="text-border">·</span>
                                        <span>Effective: {EFFECTIVE_DATE}</span>
                                    </div>
                                </div>
                            </div>

                            <p className="mt-6 max-w-3xl text-[15px] text-muted-foreground leading-[1.75]">
                                This Privacy Policy describes how JustScroll collects, uses,
                                and protects your personal information when you use our manga
                                reading platform. We are committed to safeguarding your privacy
                                and being transparent about our data practices.
                            </p>
                        </motion.div>
                    </div>
                </div>

                {/* Content with sidebar */}
                <div className="mx-auto max-w-site px-4 sm:px-6 lg:px-8 py-12">
                    <div className="grid grid-cols-12 gap-12">
                        {/* Sidebar */}
                        <aside className="col-span-3">
                            <div className="sticky top-20">
                                <p className="text-[11px] font-semibold text-muted-foreground uppercase tracking-widest mb-3 px-3">
                                    On this page
                                </p>
                                <TableOfContents activeId={activeId} />
                                <div className="mt-6 mx-3 pt-6 border-t border-border/40">
                                    <div className="flex flex-col gap-2 text-[13px]">
                                        <Link to="/terms" className="text-muted-foreground hover:text-foreground transition-colors">
                                            Terms of Service →
                                        </Link>
                                        <Link to="/cookies" className="text-muted-foreground hover:text-foreground transition-colors">
                                            Cookie Policy →
                                        </Link>
                                    </div>
                                </div>
                            </div>
                        </aside>

                        {/* Main */}
                        <motion.div
                            initial={{ opacity: 0, y: 8 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.4, delay: 0.1 }}
                            className="col-span-9 space-y-12"
                        >
                            {sections.map((section, i) => (
                                <DesktopSection key={section.id} section={section} index={i} />
                            ))}

                            <div className="pt-8 mt-8 border-t border-border/40 flex items-center justify-between">
                                <p className="text-xs text-muted-foreground/60">
                                    © {new Date().getFullYear()} JustScroll. All rights reserved.
                                </p>
                                <div className="flex items-center gap-4 text-xs">
                                    <Link to="/terms" className="text-muted-foreground hover:text-foreground transition-colors">
                                        Terms of Service
                                    </Link>
                                    <Link to="/cookies" className="text-muted-foreground hover:text-foreground transition-colors">
                                        Cookie Policy
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