// frontend/src/pages/Terms.jsx
import { useState, useEffect, useRef } from "react";
import { Link } from "react-router-dom";
import { ArrowLeft, FileText, ChevronRight } from "lucide-react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";

const LAST_UPDATED = "June 15, 2025";
const EFFECTIVE_DATE = "June 15, 2025";

const sections = [
    {
        id: "acceptance",
        number: "1",
        title: "Acceptance of Terms",
        content: [
            {
                text: 'By accessing or using JustScroll ("the Service"), you acknowledge that you have read, understood, and agree to be bound by these Terms of Service. If you do not agree to these terms, you must not use the Service.',
            },
            {
                text: "We reserve the right to modify these terms at any time. Continued use of the Service after changes constitutes acceptance of the updated terms.",
            },
        ],
    },
    {
        id: "description",
        number: "2",
        title: "Description of Service",
        content: [
            {
                text: "JustScroll is a manga reading platform that aggregates content from third-party sources including MangaDex, Jikan (MyAnimeList), and ComicVine. We provide a unified interface for discovering, reading, and tracking manga, manhwa, and comics.",
            },
            {
                text: "JustScroll does not host manga content directly. All manga pages and cover images are fetched from their respective third-party sources via API integrations and image proxying.",
            },
        ],
    },
    {
        id: "accounts",
        number: "3",
        title: "User Accounts",
        content: [
            {
                subtitle: "Registration",
                text: "To access certain features such as bookmarks, reading history, and profile settings, you must create an account. You agree to provide accurate and complete information during registration.",
            },
            {
                subtitle: "Account Security",
                text: "You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately of any unauthorized use of your account. JustScroll is not liable for any losses resulting from unauthorized access to your account.",
            },
            {
                subtitle: "Account Termination",
                text: "We reserve the right to suspend or terminate accounts that violate these terms, engage in abusive behavior, or are inactive for extended periods. You may also delete your account at any time.",
            },
        ],
    },
    {
        id: "acceptable-use",
        number: "4",
        title: "Acceptable Use",
        content: [
            { text: "When using JustScroll, you agree not to:" },
            {
                list: [
                    "Use the Service for any unlawful purpose or in violation of any applicable laws",
                    "Attempt to gain unauthorized access to any part of the Service, other accounts, or related systems",
                    "Interfere with or disrupt the Service, servers, or networks connected to the Service",
                    "Use automated tools, bots, or scrapers to access or collect data from the Service without permission",
                    "Reproduce, distribute, or create derivative works from the Service without authorization",
                    "Upload, transmit, or distribute any malicious code, viruses, or harmful content",
                    "Impersonate any person or entity, or falsely represent your affiliation with any person or entity",
                    "Harass, abuse, or harm other users of the Service",
                    "Circumvent or attempt to circumvent any security features of the Service",
                ],
            },
        ],
    },
    {
        id: "intellectual-property",
        number: "5",
        title: "Intellectual Property",
        content: [
            {
                subtitle: "Our Content",
                text: "The JustScroll platform, including its design, code, branding, and original content, is the intellectual property of JustScroll. You may not copy, modify, or distribute our platform without written permission.",
            },
            {
                subtitle: "Third-Party Content",
                text: "All manga, manhwa, and comic content displayed on JustScroll belongs to their respective creators, publishers, and rights holders. JustScroll acts as an aggregator and does not claim ownership of any third-party content. If you are a rights holder and believe your content is being displayed improperly, please contact us.",
            },
        ],
    },
    {
        id: "content-disclaimer",
        number: "6",
        title: "Content Disclaimer",
        content: [
            {
                text: "JustScroll aggregates content from third-party sources and does not control or guarantee the accuracy, completeness, or availability of such content. Manga content may include material rated for different audiences. Users are responsible for ensuring that the content they access is appropriate for them.",
            },
            {
                text: "We display content ratings where available but cannot guarantee that all content is accurately rated by its source.",
            },
        ],
    },
    {
        id: "availability",
        number: "7",
        title: "Service Availability",
        content: [
            {
                text: "We strive to keep JustScroll available 24/7, but we do not guarantee uninterrupted access. The Service may be temporarily unavailable due to:",
            },
            {
                list: [
                    "Scheduled maintenance and updates",
                    "Third-party API outages or rate limiting (MangaDex, Jikan, ComicVine)",
                    "Server issues or technical difficulties",
                    "Force majeure events beyond our control",
                ],
            },
            {
                text: "We are not liable for any damages resulting from service interruptions.",
            },
        ],
    },
    {
        id: "liability",
        number: "8",
        title: "Limitation of Liability",
        content: [
            {
                text: 'JustScroll is provided on an "AS IS" and "AS AVAILABLE" basis without warranties of any kind, either express or implied. To the fullest extent permitted by law:',
            },
            {
                list: [
                    "We disclaim all warranties, including implied warranties of merchantability, fitness for a particular purpose, and non-infringement",
                    "We are not liable for any indirect, incidental, special, consequential, or punitive damages",
                    "Our total liability for any claims related to the Service shall not exceed the amount you paid us (if any) in the 12 months preceding the claim",
                    "We are not responsible for the content, accuracy, or practices of third-party sources",
                ],
            },
        ],
    },
    {
        id: "dmca",
        number: "9",
        title: "DMCA & Copyright",
        content: [
            {
                text: "JustScroll respects the intellectual property rights of others. If you believe that content accessible through our Service infringes your copyright, please send a DMCA takedown notice to our designated agent with the following information:",
            },
            {
                list: [
                    "A description of the copyrighted work you claim has been infringed",
                    "The URL or location of the infringing content on our Service",
                    "Your contact information (name, email, phone number)",
                    "A statement that you have a good faith belief that the use is not authorized",
                    "A statement, under penalty of perjury, that the information is accurate and you are authorized to act on behalf of the copyright owner",
                    "Your physical or electronic signature",
                ],
            },
            { text: "Send DMCA notices to: srinathnulidonda.dev@gmail.com" },
        ],
    },
    {
        id: "governing-law",
        number: "10",
        title: "Governing Law",
        content: [
            {
                text: "These Terms shall be governed by and construed in accordance with applicable laws, without regard to conflict of law provisions. Any disputes arising from these terms or your use of the Service shall be resolved through good-faith negotiation, and if necessary, binding arbitration.",
            },
        ],
    },
    {
        id: "contact",
        number: "11",
        title: "Contact",
        content: [
            {
                text: "For questions or concerns about these Terms of Service, please contact us at:",
            },
            { text: "Email: srinathnulidonda.dev@gmail.com" },
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
                                <li key={j} className="leading-relaxed">{item}</li>
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
                <h2 className="text-xl font-semibold tracking-tight">{section.title}</h2>
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

export default function Terms() {
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
                <div className="mx-auto max-w-3xl px-4 sm:px-6 py-8">
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
                                <FileText className="h-6 w-6 text-primary" />
                            </div>
                            <div>
                                <h1 className="text-2xl sm:text-3xl font-bold tracking-tight">
                                    Terms of Service
                                </h1>
                                <p className="text-sm text-muted-foreground mt-1">
                                    Last updated: {LAST_UPDATED}
                                </p>
                            </div>
                        </div>

                        <div className="rounded-xl border border-border/50 bg-card p-4 sm:p-5 mb-8">
                            <p className="text-sm sm:text-[15px] text-muted-foreground leading-relaxed">
                                Welcome to JustScroll. These Terms of Service govern your
                                access to and use of the JustScroll platform. By using our
                                Service, you agree to comply with and be bound by these terms.
                                Please read them carefully before using JustScroll.
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
                <div className="border-b border-border/50">
                    <div className="mx-auto max-w-7xl px-8 py-14">
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
                                    <FileText className="h-5 w-5 text-primary" />
                                </div>
                                <div>
                                    <h1 className="text-4xl font-bold tracking-tight">
                                        Terms of Service
                                    </h1>
                                    <div className="flex items-center gap-3 mt-2 text-sm text-muted-foreground">
                                        <span>Last updated: {LAST_UPDATED}</span>
                                        <span className="text-border">·</span>
                                        <span>Effective: {EFFECTIVE_DATE}</span>
                                    </div>
                                </div>
                            </div>

                            <p className="mt-6 max-w-3xl text-[15px] text-muted-foreground leading-[1.75]">
                                These Terms of Service constitute a legally binding agreement
                                between you and JustScroll governing your access to and use of
                                the platform. Please read these terms carefully before using our
                                Service.
                            </p>
                        </motion.div>
                    </div>
                </div>

                <div className="mx-auto max-w-7xl px-8 py-12">
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
                                        <Link to="/cookies" className="text-muted-foreground hover:text-foreground transition-colors">
                                            Cookie Policy →
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
                            {sections.map((section, i) => (
                                <DesktopSection key={section.id} section={section} index={i} />
                            ))}

                            <div className="pt-8 mt-8 border-t border-border/40 flex items-center justify-between">
                                <p className="text-xs text-muted-foreground/60">
                                    © {new Date().getFullYear()} JustScroll. All rights reserved.
                                </p>
                                <div className="flex items-center gap-4 text-xs">
                                    <Link to="/privacy" className="text-muted-foreground hover:text-foreground transition-colors">
                                        Privacy Policy
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