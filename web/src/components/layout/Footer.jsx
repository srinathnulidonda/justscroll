// frontend/src/components/layout/Footer.jsx
import { Link } from "react-router-dom";
import logo from "@/assets/logo.png";

const footerLinks = {
    browse: [
        { label: "Discover", to: "/discover" },
        { label: "Latest Updates", to: "/discover?tab=latest" },
        { label: "Search", to: "/search" },
    ],
    account: [
        { label: "Sign In", to: "/login" },
        { label: "Create Account", to: "/register" },
        { label: "Bookmarks", to: "/bookmarks" },
        { label: "History", to: "/history" },
    ],
    app: [  // ADD THIS NEW SECTION
        { label: "Download Android App", to: "/download" },
        { label: "GitHub", href: "https://github.com/srinathnulidonda/justscroll/releases/tag/v1.0.0", external: true },
    ],
    legal: [
        { label: "Privacy Policy", to: "/privacy" },
        { label: "Terms of Service", to: "/terms" },
        { label: "Cookie Policy", to: "/cookies" },
    ],
};

function FooterLinkGroup({ title, links }) {
    return (
        <div>
            <h3 className="text-xs font-semibold text-foreground uppercase tracking-wider mb-3">
                {title}
            </h3>
            <ul className="space-y-2">
                {links.map((link) => (
                    <li key={link.label}>
                        {link.external ? (
                            <a
                                href={link.href}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="text-sm text-muted-foreground hover:text-foreground transition-colors duration-150"
                            >
                                {link.label}
                            </a>
                        ) : (
                            <Link
                                to={link.to}
                                className="text-sm text-muted-foreground hover:text-foreground transition-colors duration-150"
                            >
                                {link.label}
                            </Link>
                        )}
                    </li>
                ))}
            </ul>
        </div>
    );
}

export function Footer() {
    const year = new Date().getFullYear();

    return (
        <footer className="border-t border-border/50 mt-auto bg-card/30 pb-12 md:pb-0">
            <div className="mx-auto max-w-site px-4 sm:px-6 lg:px-8">
                <div className="py-10 sm:py-12">
                    <div className="grid grid-cols-2 sm:grid-cols-5 gap-8">
                        {/* Brand */}
                        <div className="col-span-2 sm:col-span-1">
                            <Link
                                to="/"
                                className="inline-flex items-center hover:opacity-80 transition-opacity"
                            >
                                <img
                                    src={logo}
                                    alt="JustScroll"
                                    className="h-7 w-auto object-contain"
                                />
                            </Link>
                            <p className="text-xs text-muted-foreground mt-3 max-w-[200px] leading-relaxed">
                                A premium manga reading experience. Discover,
                                read, and track your favorite titles.
                            </p>
                            <p className="text-[11px] text-muted-foreground/60 mt-4">
                                Powered by MangaDex, Jikan & ComicVine
                            </p>
                        </div>

                        {/* Links */}
                        <FooterLinkGroup title="Browse" links={footerLinks.browse} />
                        <FooterLinkGroup title="Account" links={footerLinks.account} />
                        <FooterLinkGroup title="App" links={footerLinks.app} />
                        <FooterLinkGroup title="Legal" links={footerLinks.legal} />
                    </div>
                </div>

                <div className="border-t border-border/40 py-5 flex flex-col sm:flex-row items-center justify-between gap-3">
                    <p className="text-xs text-muted-foreground/60">
                        © {year} JustScroll. All rights reserved.
                    </p>
                    <div className="flex items-center gap-4">
                        <Link
                            to="/privacy"
                            className="text-xs text-muted-foreground/60 hover:text-muted-foreground transition-colors"
                        >
                            Privacy
                        </Link>
                        <Link
                            to="/terms"
                            className="text-xs text-muted-foreground/60 hover:text-muted-foreground transition-colors"
                        >
                            Terms
                        </Link>
                        <Link
                            to="/cookies"
                            className="text-xs text-muted-foreground/60 hover:text-muted-foreground transition-colors"
                        >
                            Cookies
                        </Link>
                    </div>
                </div>
            </div>
        </footer>
    );
}