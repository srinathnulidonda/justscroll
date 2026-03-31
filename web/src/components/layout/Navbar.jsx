// frontend/src/components/layout/Navbar.jsx
import { useState } from "react";
import { Link, useNavigate, useLocation } from "react-router-dom";
import { useAuthStore } from "@/stores/authStore";
import { useThemeStore } from "@/stores/themeStore";
import { Button } from "@/components/ui/Button";
import {
    DropdownMenu,
    DropdownMenuTrigger,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuSeparator,
    DropdownMenuLabel,
} from "@/components/ui/Dropdown";
import { SimpleTooltip } from "@/components/ui/Tooltip";
import {
    Sun,
    Moon,
    User,
    BookmarkPlus,
    History,
    LogOut,
    Search,
    X,
    Download,  // ADD THIS
} from "lucide-react";
import { cn } from "@/lib/utils";
import { motion, AnimatePresence } from "framer-motion";
import logo from "@/assets/logo.png";

export function Navbar() {
    const { isAuthenticated, user, logout } = useAuthStore();
    const { theme, toggle } = useThemeStore();
    const navigate = useNavigate();
    const location = useLocation();
    const [mobileSearchOpen, setMobileSearchOpen] = useState(false);
    const [searchQuery, setSearchQuery] = useState("");

    if (location.pathname.startsWith("/read")) return null;

    const handleSearch = (e) => {
        e.preventDefault();
        const q = searchQuery.trim();
        if (q) {
            navigate(`/search?q=${encodeURIComponent(q)}`);
            setSearchQuery("");
            setMobileSearchOpen(false);
        }
    };

    return (
        <header className="sticky top-0 z-40 w-full border-b border-border/50 bg-background/90 backdrop-blur-xl">
            <div className="mx-auto max-w-site px-4 sm:px-6 lg:px-8">
                <div className="flex h-14 items-center gap-4">
                    {/* Logo */}
                    <Link
                        to="/"
                        className="flex items-center hover:opacity-80 transition-opacity flex-shrink-0"
                    >
                        <img
                            src={logo}
                            alt="JustScroll"
                            className="h-7 sm:h-8 w-auto max-w-[120px] sm:max-w-[150px] object-contain"
                        />
                    </Link>

                    {/* Desktop Search Bar */}
                    <form
                        onSubmit={handleSearch}
                        className="hidden md:flex flex-1 max-w-lg mx-auto relative"
                    >
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground pointer-events-none" />
                        <input
                            type="text"
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            placeholder="Search manga, comics, manhwa..."
                            className={cn(
                                "w-full h-9 pl-9 pr-4 rounded-lg",
                                "bg-muted/60 border border-transparent",
                                "text-sm placeholder:text-muted-foreground/50",
                                "hover:bg-muted/80 hover:border-border/50",
                                "focus:outline-none focus:ring-2 focus:ring-ring/30 focus:border-primary/40 focus:bg-background",
                                "transition-all duration-200"
                            )}
                            aria-label="Search manga"
                        />
                        {searchQuery && (
                            <button
                                type="button"
                                onClick={() => setSearchQuery("")}
                                className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                                aria-label="Clear"
                            >
                                <X className="h-3.5 w-3.5" />
                            </button>
                        )}
                    </form>

                    <div className="flex-1 md:hidden" />

                    {/* Right Actions */}
                    <div className="flex items-center gap-1">
                        {/* Mobile Search Toggle */}
                        <button
                            onClick={() => setMobileSearchOpen(!mobileSearchOpen)}
                            className={cn(
                                "flex h-9 w-9 items-center justify-center rounded-lg transition-colors md:hidden",
                                mobileSearchOpen
                                    ? "text-primary bg-primary/10"
                                    : "text-muted-foreground hover:text-foreground hover:bg-muted"
                            )}
                            aria-label="Search"
                        >
                            {mobileSearchOpen ? (
                                <X className="h-4 w-4" />
                            ) : (
                                <Search className="h-4 w-4" />
                            )}
                        </button>

                        {/* ADD DOWNLOAD BUTTON (Desktop only) */}
                        <SimpleTooltip content="Download App">
                            <Link
                                to="/download"
                                className="hidden md:flex h-9 w-9 items-center justify-center rounded-lg text-muted-foreground hover:text-foreground hover:bg-muted transition-colors"
                                aria-label="Download app"
                            >
                                <Download className="h-4 w-4" />
                            </Link>
                        </SimpleTooltip>

                        {/* Theme Toggle */}
                        <SimpleTooltip
                            content={theme === "dark" ? "Light mode" : "Dark mode"}
                        >
                            <button
                                onClick={toggle}
                                className="flex h-9 w-9 items-center justify-center rounded-lg text-muted-foreground hover:text-foreground hover:bg-muted transition-colors"
                                aria-label="Toggle theme"
                            >
                                <AnimatePresence mode="wait" initial={false}>
                                    <motion.div
                                        key={theme}
                                        initial={{ scale: 0, rotate: -90 }}
                                        animate={{ scale: 1, rotate: 0 }}
                                        exit={{ scale: 0, rotate: 90 }}
                                        transition={{ duration: 0.15 }}
                                    >
                                        {theme === "dark" ? (
                                            <Sun className="h-4 w-4" />
                                        ) : (
                                            <Moon className="h-4 w-4" />
                                        )}
                                    </motion.div>
                                </AnimatePresence>
                            </button>
                        </SimpleTooltip>

                        {/* User Menu / Auth */}
                        {isAuthenticated ? (
                            <DropdownMenu>
                                <DropdownMenuTrigger asChild>
                                    <button
                                        className="flex h-9 w-9 items-center justify-center rounded-full bg-primary/10 text-primary text-xs font-bold hover:bg-primary/20 transition-colors ml-1"
                                        aria-label="Account menu"
                                    >
                                        {user?.username?.charAt(0).toUpperCase() || "U"}
                                    </button>
                                </DropdownMenuTrigger>
                                <DropdownMenuContent align="end" className="w-52">
                                    <DropdownMenuLabel className="font-normal px-3 py-2">
                                        <p className="text-sm font-semibold">{user?.username}</p>
                                        {user?.email && (
                                            <p className="text-xs text-muted-foreground truncate mt-0.5">
                                                {user.email}
                                            </p>
                                        )}
                                    </DropdownMenuLabel>
                                    <DropdownMenuSeparator />
                                    <DropdownMenuItem onClick={() => navigate("/bookmarks")}>
                                        <BookmarkPlus className="mr-2.5 h-4 w-4 text-muted-foreground" />
                                        Bookmarks
                                    </DropdownMenuItem>
                                    <DropdownMenuItem onClick={() => navigate("/history")}>
                                        <History className="mr-2.5 h-4 w-4 text-muted-foreground" />
                                        History
                                    </DropdownMenuItem>
                                    <DropdownMenuItem onClick={() => navigate("/profile")}>
                                        <User className="mr-2.5 h-4 w-4 text-muted-foreground" />
                                        Profile
                                    </DropdownMenuItem>
                                    <DropdownMenuSeparator />
                                    <DropdownMenuItem
                                        onClick={() => {
                                            logout();
                                            navigate("/");
                                        }}
                                        className="text-destructive focus:text-destructive"
                                    >
                                        <LogOut className="mr-2.5 h-4 w-4" />
                                        Sign out
                                    </DropdownMenuItem>
                                </DropdownMenuContent>
                            </DropdownMenu>
                        ) : (
                            <>
                                <div className="hidden sm:flex items-center gap-2 ml-1">
                                    <Button
                                        variant="ghost"
                                        size="sm"
                                        onClick={() => navigate("/login")}
                                        className="text-muted-foreground hover:text-foreground"
                                    >
                                        Sign in
                                    </Button>
                                    <Button
                                        variant="primary"
                                        size="sm"
                                        onClick={() => navigate("/register")}
                                    >
                                        Sign up
                                    </Button>
                                </div>
                                <button
                                    onClick={() => navigate("/login")}
                                    className="flex sm:hidden h-9 w-9 items-center justify-center rounded-full bg-muted text-muted-foreground hover:text-foreground hover:bg-muted/80 transition-colors ml-1"
                                    aria-label="Sign in"
                                >
                                    <User className="h-4 w-4" />
                                </button>
                            </>
                        )}
                    </div>
                </div>
            </div>

            {/* Mobile Search Dropdown */}
            <AnimatePresence>
                {mobileSearchOpen && (
                    <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: "auto", opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        transition={{ duration: 0.2, ease: "easeOut" }}
                        className="overflow-hidden border-t border-border/50 md:hidden bg-background"
                    >
                        <form onSubmit={handleSearch} className="px-4 py-3 relative">
                            <Search className="absolute left-7 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground pointer-events-none" />
                            <input
                                type="text"
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                placeholder="Search manga..."
                                autoFocus
                                className={cn(
                                    "w-full h-10 pl-9 pr-4 rounded-lg",
                                    "bg-muted border border-border/50",
                                    "text-sm placeholder:text-muted-foreground/50",
                                    "focus:outline-none focus:ring-2 focus:ring-ring/30 focus:border-primary/40",
                                    "transition-all duration-200"
                                )}
                                aria-label="Search manga"
                            />
                            {searchQuery && (
                                <button
                                    type="button"
                                    onClick={() => setSearchQuery("")}
                                    className="absolute right-7 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                                    aria-label="Clear"
                                >
                                    <X className="h-3.5 w-3.5" />
                                </button>
                            )}
                        </form>
                    </motion.div>
                )}
            </AnimatePresence>
        </header>
    );
}