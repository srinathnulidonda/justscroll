// frontend/src/components/layout/MobileNav.jsx
import { useLocation, useNavigate } from "react-router-dom";
import { Home, Compass, BookmarkPlus, User } from "lucide-react";
import { cn } from "@/lib/utils";
import { useAuthStore } from "@/stores/authStore";
import { motion } from "framer-motion";

const NAV_ITEMS = [
    {
        key: "home",
        to: "/",
        icon: Home,
        label: "Home",
        matchPaths: ["/"],
    },
    {
        key: "discover",
        to: "/discover",
        icon: Compass,
        label: "Discover",
        matchPaths: ["/discover", "/search"],
    },
    {
        key: "library",
        to: "/bookmarks",
        icon: BookmarkPlus,
        label: "Library",
        matchPaths: ["/bookmarks", "/history"],
        requireAuth: true,
    },
    {
        key: "profile",
        to: "/profile",
        guestTo: "/login",
        icon: User,
        label: "Profile",
        guestLabel: "Account",
        matchPaths: ["/profile"],
    },
];

export function MobileNav() {
    const location = useLocation();
    const navigate = useNavigate();
    const { isAuthenticated } = useAuthStore();

    if (location.pathname.startsWith("/read")) return null;

    const isActive = (item) => {
        // When on /login or /register, check where user came from
        if (
            location.pathname === "/login" ||
            location.pathname === "/register"
        ) {
            const fromPath = location.state?.from?.pathname;
            if (fromPath) {
                // Highlight the tab that the user was trying to reach
                return item.matchPaths.some(
                    (p) =>
                        p === fromPath ||
                        (p !== "/" && fromPath.startsWith(p))
                );
            }
            // No from state — highlight Account/Profile tab
            return item.key === "profile";
        }

        if (item.matchPaths.includes(location.pathname)) return true;
        return item.matchPaths.some(
            (p) => p !== "/" && location.pathname.startsWith(p)
        );
    };

    const handleClick = (item) => {
        if (item.requireAuth && !isAuthenticated) {
            navigate("/login", {
                state: { from: { pathname: item.to } },
            });
            return;
        }
        const target =
            !isAuthenticated && item.guestTo ? item.guestTo : item.to;

        // When guest clicks Account, pass no from state
        if (!isAuthenticated && item.guestTo) {
            navigate(target);
            return;
        }

        navigate(target);
    };

    return (
        <div
            className="fixed bottom-0 left-0 right-0 z-40 md:hidden pointer-events-none"
            style={{ paddingBottom: "env(safe-area-inset-bottom)" }}
        >
            <div className="px-5 pb-2.5">
                <nav
                    className={cn(
                        "pointer-events-auto",
                        "mx-auto max-w-sm",
                        "rounded-2xl",
                        "border border-border/30 dark:border-white/[0.06]",
                        "bg-background/80 dark:bg-[#1c1c1e]/80",
                        "backdrop-blur-xl",
                        "shadow-[0_4px_20px_rgba(0,0,0,0.08)]",
                        "dark:shadow-[0_4px_20px_rgba(0,0,0,0.35)]",
                        "px-1 py-0.5"
                    )}
                    aria-label="Mobile navigation"
                >
                    <div className="flex items-center justify-around">
                        {NAV_ITEMS.map((item) => {
                            const Icon = item.icon;
                            const active = isActive(item);
                            const label =
                                !isAuthenticated && item.guestLabel
                                    ? item.guestLabel
                                    : item.label;

                            return (
                                <motion.button
                                    key={item.key}
                                    onClick={() => handleClick(item)}
                                    whileTap={{ scale: 0.92 }}
                                    transition={{
                                        type: "spring",
                                        stiffness: 400,
                                        damping: 20,
                                    }}
                                    className={cn(
                                        "relative flex flex-col items-center justify-center",
                                        "w-14 py-1.5 rounded-xl",
                                        "transition-colors duration-200",
                                        "outline-none",
                                        active
                                            ? "text-primary"
                                            : "text-muted-foreground"
                                    )}
                                    aria-label={label}
                                    aria-current={
                                        active ? "page" : undefined
                                    }
                                >
                                    {active && (
                                        <motion.div
                                            layoutId="nav-pill"
                                            className="absolute inset-0 rounded-xl bg-primary/8 dark:bg-primary/10"
                                            transition={{
                                                type: "spring",
                                                stiffness: 350,
                                                damping: 30,
                                            }}
                                        />
                                    )}

                                    <Icon
                                        className={cn(
                                            "relative z-10 h-[18px] w-[18px]",
                                            "transition-colors duration-200"
                                        )}
                                        strokeWidth={active ? 2.3 : 1.8}
                                    />

                                    <span
                                        className={cn(
                                            "relative z-10 mt-0.5",
                                            "text-[9px] font-medium",
                                            "transition-colors duration-200",
                                            active
                                                ? "text-primary"
                                                : "text-muted-foreground/70"
                                        )}
                                    >
                                        {label}
                                    </span>
                                </motion.button>
                            );
                        })}
                    </div>
                </nav>
            </div>
        </div>
    );
}