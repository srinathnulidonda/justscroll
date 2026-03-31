// frontend/src/pages/Profile.jsx
import { useNavigate } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { useAuthStore } from "@/stores/authStore";
import { useThemeStore } from "@/stores/themeStore";
import { useReaderStore } from "@/stores/readerStore";
import { api } from "@/lib/api";
import { toast } from "@/stores/toastStore";
import { Button } from "@/components/ui/Button";
import { EmptyState } from "@/components/common/EmptyState";
import {
    User,
    BookmarkPlus,
    History,
    Sun,
    Moon,
    LogOut,
    ChevronRight,
    BookOpen,
    Clock,
    Shield,
    Zap,
    TrendingUp,
    Eye,
    Image as ImageIcon,
    Scroll,
    ArrowRight,
} from "lucide-react";
import { cn, formatDate, proxyImage } from "@/lib/utils";
import { motion } from "framer-motion";
import logo from "@/assets/logo.png";

function ProfileAvatar({ username, size = "lg" }) {
    const initials = username ? username.slice(0, 2).toUpperCase() : "U";

    const sizes = {
        sm: "w-12 h-12 text-base",
        md: "w-16 h-16 text-xl",
        lg: "w-20 h-20 text-2xl",
        xl: "w-28 h-28 text-4xl",
    };

    return (
        <div className="relative">
            <div
                className={cn(
                    "flex items-center justify-center rounded-full",
                    "bg-gradient-to-br from-primary via-primary/90 to-primary/70",
                    "text-primary-foreground font-bold",
                    "shadow-lg shadow-primary/25",
                    "ring-4 ring-background",
                    sizes[size]
                )}
            >
                {initials}
            </div>
            <div
                className={cn(
                    "absolute -bottom-0.5 -right-0.5",
                    "rounded-full bg-emerald-500 border-[3px] border-background",
                    size === "xl" ? "w-7 h-7" : "w-5 h-5"
                )}
            />
        </div>
    );
}

function StatCard({ icon: Icon, label, value, sublabel, color, onClick, compact }) {
    return (
        <motion.button
            whileTap={{ scale: 0.97 }}
            onClick={onClick}
            className={cn(
                "relative overflow-hidden",
                "flex flex-col",
                compact ? "p-3" : "p-3.5 sm:p-4 lg:p-5",
                "rounded-2xl border border-border/40",
                "bg-card",
                "hover:border-border hover:shadow-soft",
                "transition-all duration-200",
                "text-left w-full group"
            )}
        >
            <div
                className={cn(
                    "absolute top-0 right-0 w-20 h-20 rounded-full",
                    "opacity-[0.04] group-hover:opacity-[0.08]",
                    "transition-opacity duration-300",
                    "-translate-y-1/2 translate-x-1/2"
                )}
                style={{ background: "currentColor" }}
            />
            <div
                className={cn(
                    "flex items-center justify-center rounded-xl mb-2 lg:mb-3",
                    compact ? "w-8 h-8" : "w-9 h-9 lg:w-11 lg:h-11",
                    color
                )}
            >
                <Icon className={cn(compact ? "w-4 h-4" : "w-4 h-4 lg:w-5 lg:h-5")} />
            </div>
            <span
                className={cn(
                    "font-bold tracking-tight leading-none",
                    compact ? "text-xl" : "text-2xl lg:text-3xl"
                )}
            >
                {value}
            </span>
            <span
                className={cn(
                    "font-medium text-foreground mt-1",
                    compact ? "text-[11px]" : "text-xs lg:text-sm"
                )}
            >
                {label}
            </span>
            {sublabel && (
                <span
                    className={cn(
                        "text-muted-foreground mt-0.5",
                        compact ? "text-[9px]" : "text-[10px] lg:text-xs"
                    )}
                >
                    {sublabel}
                </span>
            )}
        </motion.button>
    );
}

function QuickAction({ icon: Icon, label, color, onClick, compact }) {
    return (
        <motion.button
            whileTap={{ scale: 0.97 }}
            onClick={onClick}
            className={cn(
                "flex flex-col items-center justify-center",
                compact ? "p-2.5" : "p-3 lg:p-4",
                "rounded-xl lg:rounded-2xl",
                "border border-border/40 bg-card",
                "hover:border-border hover:shadow-soft",
                "transition-all duration-200",
                "text-center group"
            )}
        >
            <div
                className={cn(
                    "flex items-center justify-center rounded-lg lg:rounded-xl",
                    "transition-transform duration-200 group-hover:scale-110",
                    compact ? "w-8 h-8 mb-1.5" : "w-9 h-9 lg:w-11 lg:h-11 mb-2",
                    color
                )}
            >
                <Icon className={cn(compact ? "w-4 h-4" : "w-4 h-4 lg:w-5 lg:h-5")} />
            </div>
            <span className={cn("font-medium", compact ? "text-[10px]" : "text-xs lg:text-sm")}>
                {label}
            </span>
        </motion.button>
    );
}

function MenuItem({ icon: Icon, label, description, onClick, variant }) {
    return (
        <button
            onClick={onClick}
            className={cn(
                "flex items-center gap-3 w-full",
                "px-3 lg:px-4 py-3 lg:py-3.5",
                "text-left transition-all duration-150",
                "active:scale-[0.99] rounded-xl",
                variant === "danger"
                    ? "text-destructive hover:bg-destructive/5"
                    : "hover:bg-muted/50"
            )}
        >
            <div
                className={cn(
                    "flex items-center justify-center flex-shrink-0",
                    "w-8 h-8 lg:w-10 lg:h-10 rounded-lg",
                    variant === "danger"
                        ? "bg-destructive/10 text-destructive"
                        : "bg-muted text-muted-foreground"
                )}
            >
                <Icon className="w-4 h-4 lg:w-5 lg:h-5" />
            </div>
            <div className="flex-1 min-w-0">
                <p className="text-[13px] lg:text-sm font-medium leading-tight">{label}</p>
                {description && (
                    <p className="text-[10px] lg:text-xs text-muted-foreground mt-0.5 truncate">
                        {description}
                    </p>
                )}
            </div>
            <ChevronRight
                className={cn(
                    "w-4 h-4 flex-shrink-0",
                    variant === "danger" ? "text-destructive/40" : "text-muted-foreground/30"
                )}
            />
        </button>
    );
}

function SectionCard({ title, action, noPadding, children, className }) {
    return (
        <div
            className={cn(
                "rounded-2xl border border-border/40 bg-card overflow-hidden",
                className
            )}
        >
            {title && (
                <div className="flex items-center justify-between px-3 lg:px-4 pt-3 lg:pt-4 pb-1">
                    <h3 className="text-[11px] lg:text-xs font-semibold text-muted-foreground uppercase tracking-wider">
                        {title}
                    </h3>
                    {action}
                </div>
            )}
            <div className={cn(noPadding ? "" : "px-1 py-1")}>{children}</div>
        </div>
    );
}

function ContinueReadingCard({ entry, onClick }) {
    return (
        <motion.button
            whileTap={{ scale: 0.98 }}
            onClick={onClick}
            className={cn(
                "flex items-center gap-3 w-full",
                "p-2.5 lg:p-3 rounded-xl",
                "text-left hover:bg-muted/40",
                "transition-all duration-150",
                "group"
            )}
        >
            <div className="w-10 h-14 lg:w-12 lg:h-16 rounded-lg overflow-hidden bg-muted flex-shrink-0 border border-border/20">
                <div className="w-full h-full flex items-center justify-center bg-primary/5">
                    <BookOpen className="w-4 h-4 text-primary/40" />
                </div>
            </div>
            <div className="flex-1 min-w-0">
                <p className="text-[13px] lg:text-sm font-medium truncate group-hover:text-primary transition-colors">
                    {entry.manga_title}
                </p>
                <div className="flex items-center gap-1.5 mt-0.5">
                    {entry.chapter_number && (
                        <span className="text-[10px] lg:text-xs text-muted-foreground">
                            Ch. {entry.chapter_number}
                        </span>
                    )}
                    {entry.chapter_number && (
                        <span className="text-muted-foreground/30 text-[10px]">·</span>
                    )}
                    <span className="text-[10px] lg:text-xs text-muted-foreground">
                        p.{entry.page_number}
                    </span>
                    <span className="text-muted-foreground/30 text-[10px]">·</span>
                    <span className="text-[10px] lg:text-xs text-muted-foreground">
                        {formatDate(entry.updated_at)}
                    </span>
                </div>
            </div>
            <div
                className={cn(
                    "flex items-center justify-center",
                    "w-7 h-7 lg:w-8 lg:h-8 rounded-full flex-shrink-0",
                    "bg-primary/10 text-primary",
                    "opacity-0 group-hover:opacity-100",
                    "transition-opacity duration-200"
                )}
            >
                <ArrowRight className="w-3.5 h-3.5" />
            </div>
        </motion.button>
    );
}

function ThemeOption({ icon: Icon, label, value, currentTheme, onSelect, compact }) {
    const isActive = currentTheme === value;
    return (
        <button
            onClick={() => onSelect(value)}
            className={cn(
                "flex flex-col items-center gap-1.5 lg:gap-2",
                compact ? "px-3 py-2" : "px-4 py-3 lg:py-4",
                "rounded-xl flex-1",
                "border-2 transition-all duration-200",
                "active:scale-[0.97]",
                isActive
                    ? "border-primary bg-primary/5 shadow-sm shadow-primary/10"
                    : "border-border/40 hover:border-border hover:bg-muted/30"
            )}
        >
            <div
                className={cn(
                    "rounded-lg lg:rounded-xl flex items-center justify-center",
                    "transition-all duration-200",
                    compact ? "w-8 h-8" : "w-9 h-9 lg:w-10 lg:h-10",
                    isActive
                        ? "bg-primary text-primary-foreground shadow-sm"
                        : "bg-muted text-muted-foreground"
                )}
            >
                <Icon className={cn(compact ? "w-4 h-4" : "w-4 h-4 lg:w-5 lg:h-5")} />
            </div>
            <span
                className={cn(
                    "font-medium",
                    compact ? "text-[10px]" : "text-xs lg:text-sm",
                    isActive ? "text-primary" : "text-muted-foreground"
                )}
            >
                {label}
            </span>
            {isActive && !compact && (
                <span className="text-[10px] text-primary font-medium hidden lg:block">
                    Active
                </span>
            )}
        </button>
    );
}

function SettingToggle({ label, options, value, onChange, compact }) {
    return (
        <div>
            <p
                className={cn(
                    "font-medium text-muted-foreground mb-2",
                    compact ? "text-[10px]" : "text-[11px] lg:text-xs"
                )}
            >
                {label}
            </p>
            <div className="grid grid-cols-2 gap-2">
                {options.map((option) => (
                    <button
                        key={option.value}
                        onClick={() => onChange(option.value)}
                        className={cn(
                            "flex items-center gap-2 rounded-xl border font-medium transition-all",
                            "active:scale-[0.97]",
                            compact
                                ? "px-2.5 py-2 text-[11px]"
                                : "px-3 py-2.5 text-[13px] lg:text-sm",
                            value === option.value
                                ? "border-primary bg-primary/5 text-primary"
                                : "border-border/40 text-muted-foreground hover:border-border hover:bg-muted/30"
                        )}
                    >
                        <option.icon className={cn(compact ? "w-3.5 h-3.5" : "w-4 h-4")} />
                        {option.label}
                    </button>
                ))}
            </div>
        </div>
    );
}

export default function Profile() {
    const navigate = useNavigate();
    const { isAuthenticated, user, logout, isLoading: authLoading } = useAuthStore();
    const { theme, setTheme } = useThemeStore();
    const { quality, mode, setQuality, setMode } = useReaderStore();

    const {
        data: bookmarks,
        isLoading: bookmarksLoading,
    } = useQuery({
        queryKey: ["bookmarks"],
        queryFn: () => api.getBookmarks(),
        enabled: isAuthenticated,
        staleTime: 30 * 1000,
        retry: 1,
    });

    const {
        data: history,
        isLoading: historyLoading,
    } = useQuery({
        queryKey: ["history"],
        queryFn: () => api.getHistory(),
        enabled: isAuthenticated,
        staleTime: 30 * 1000,
        retry: 1,
    });

    if (authLoading) {
        return (
            <div className="flex items-center justify-center min-h-[50vh]">
                <div className="flex flex-col items-center gap-3">
                    <div className="h-8 w-8 rounded-full border-2 border-primary border-t-transparent animate-spin" />
                    <span className="text-sm text-muted-foreground">Loading…</span>
                </div>
            </div>
        );
    }

    if (!isAuthenticated || !user) {
        return (
            <div className="mx-auto max-w-site px-4 sm:px-6 lg:px-8 py-8 md:py-12">
                <EmptyState
                    icon={User}
                    title="Sign in to view your profile"
                    description="Track your reading progress and save your favorites"
                    action={() => navigate("/login")}
                    actionLabel="Sign In"
                />
            </div>
        );
    }

    const bookmarkCount = bookmarks?.total || 0;
    const historyCount = history?.total || 0;
    const recentHistory = (history?.data || []).slice(0, 4);
    const recentBookmarks = (bookmarks?.data || []).slice(0, 6);

    const handleLogout = () => {
        logout();
        toast.info("Signed out successfully");
        navigate("/");
    };

    return (
        <div className="mx-auto max-w-site px-4 sm:px-6 lg:px-8 py-4 sm:py-6 lg:py-10">
            {/* Desktop Layout */}
            <div className="hidden lg:block">
                <div className="grid grid-cols-12 gap-6">
                    <div className="col-span-4 space-y-5">
                        <div className="p-6 rounded-2xl border border-border/40 bg-card">
                            <div className="flex flex-col items-center text-center">
                                <ProfileAvatar username={user?.username} size="xl" />
                                <h1 className="text-xl font-bold mt-4">{user?.username}</h1>
                                {user?.email && (
                                    <p className="text-sm text-muted-foreground mt-1">
                                        {user.email}
                                    </p>
                                )}
                                <div
                                    className={cn(
                                        "inline-flex items-center gap-1.5",
                                        "mt-3 px-3 py-1 rounded-full",
                                        "bg-primary/5 border border-primary/10",
                                        "text-xs font-medium text-primary"
                                    )}
                                >
                                    <Shield className="w-3 h-3" />
                                    Member
                                </div>
                            </div>
                            <div className="grid grid-cols-2 gap-3 mt-6 pt-6 border-t border-border/40">
                                <div
                                    onClick={() => navigate("/bookmarks")}
                                    className="text-center p-3 rounded-xl hover:bg-muted/50 cursor-pointer transition-colors"
                                >
                                    <p className="text-2xl font-bold">{bookmarkCount}</p>
                                    <p className="text-xs text-muted-foreground mt-0.5">
                                        Bookmarks
                                    </p>
                                </div>
                                <div
                                    onClick={() => navigate("/history")}
                                    className="text-center p-3 rounded-xl hover:bg-muted/50 cursor-pointer transition-colors"
                                >
                                    <p className="text-2xl font-bold">{historyCount}</p>
                                    <p className="text-xs text-muted-foreground mt-0.5">
                                        Chapters
                                    </p>
                                </div>
                            </div>
                        </div>

                        <SectionCard title="Quick Access">
                            <MenuItem
                                icon={BookmarkPlus}
                                label="My Library"
                                description={`${bookmarkCount} saved manga`}
                                onClick={() => navigate("/bookmarks")}
                            />
                            <MenuItem
                                icon={History}
                                label="Reading History"
                                description={`${historyCount} chapters read`}
                                onClick={() => navigate("/history")}
                            />
                            <MenuItem
                                icon={TrendingUp}
                                label="Popular Manga"
                                description="Discover trending titles"
                                onClick={() => navigate("/discover")}
                            />
                            <MenuItem
                                icon={Zap}
                                label="Latest Updates"
                                description="Recently updated manga"
                                onClick={() => navigate("/discover?tab=latest")}
                            />
                        </SectionCard>

                        <SectionCard title="Account">
                            <MenuItem
                                icon={User}
                                label="Account Details"
                                description="Manage your account"
                                onClick={() => { }}
                            />
                            <MenuItem
                                icon={Shield}
                                label="Privacy & Security"
                                description="Password, sessions"
                                onClick={() => { }}
                            />
                            <MenuItem
                                icon={LogOut}
                                label="Sign Out"
                                description={`Signed in as ${user?.username}`}
                                variant="danger"
                                onClick={handleLogout}
                            />
                        </SectionCard>
                    </div>

                    <div className="col-span-8 space-y-5">
                        {recentHistory.length > 0 && (
                            <SectionCard
                                title="Continue Reading"
                                action={
                                    historyCount > 4 ? (
                                        <button
                                            onClick={() => navigate("/history")}
                                            className="text-xs text-primary font-medium hover:underline"
                                        >
                                            See all
                                        </button>
                                    ) : null
                                }
                            >
                                <div className="grid grid-cols-2 gap-1">
                                    {recentHistory.map((entry) => (
                                        <ContinueReadingCard
                                            key={entry.id}
                                            entry={entry}
                                            onClick={() =>
                                                navigate(
                                                    `/read/${entry.chapter_id}?manga=${entry.manga_id}`
                                                )
                                            }
                                        />
                                    ))}
                                </div>
                            </SectionCard>
                        )}

                        {recentBookmarks.length > 0 && (
                            <SectionCard
                                title="Saved Manga"
                                action={
                                    bookmarkCount > 6 ? (
                                        <button
                                            onClick={() => navigate("/bookmarks")}
                                            className="text-xs text-primary font-medium hover:underline"
                                        >
                                            See all
                                        </button>
                                    ) : null
                                }
                                noPadding
                            >
                                <div className="grid grid-cols-6 gap-3 p-4">
                                    {recentBookmarks.map((bk) => (
                                        <button
                                            key={bk.id}
                                            onClick={() => navigate(`/manga/${bk.manga_id}`)}
                                            className="group"
                                        >
                                            <div className="aspect-[2/3] rounded-lg overflow-hidden border border-border/20 bg-muted">
                                                {bk.cover_url ? (
                                                    <img
                                                        src={proxyImage(bk.cover_url)}
                                                        alt={bk.manga_title}
                                                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                                                        loading="lazy"
                                                    />
                                                ) : (
                                                    <div className="w-full h-full flex items-center justify-center">
                                                        <BookOpen className="w-5 h-5 text-muted-foreground/30" />
                                                    </div>
                                                )}
                                            </div>
                                            <p className="text-xs font-medium mt-2 truncate group-hover:text-primary transition-colors">
                                                {bk.manga_title}
                                            </p>
                                        </button>
                                    ))}
                                </div>
                            </SectionCard>
                        )}

                        <div className="grid grid-cols-2 gap-5">
                            <SectionCard title="Appearance" noPadding>
                                <div className="p-4">
                                    <div className="flex gap-3">
                                        <ThemeOption
                                            icon={Sun}
                                            label="Light"
                                            value="light"
                                            currentTheme={theme}
                                            onSelect={setTheme}
                                        />
                                        <ThemeOption
                                            icon={Moon}
                                            label="Dark"
                                            value="dark"
                                            currentTheme={theme}
                                            onSelect={setTheme}
                                        />
                                    </div>
                                </div>
                            </SectionCard>

                            <SectionCard title="Reader Settings" noPadding>
                                <div className="p-4 space-y-4">
                                    <SettingToggle
                                        label="Image Quality"
                                        options={[
                                            { value: "data", label: "High", icon: ImageIcon },
                                            { value: "dataSaver", label: "Saver", icon: Zap },
                                        ]}
                                        value={quality}
                                        onChange={setQuality}
                                    />
                                    <SettingToggle
                                        label="Reading Mode"
                                        options={[
                                            { value: "single", label: "Page", icon: Eye },
                                            { value: "continuous", label: "Scroll", icon: Scroll },
                                        ]}
                                        value={mode}
                                        onChange={setMode}
                                    />
                                </div>
                            </SectionCard>
                        </div>
                    </div>
                </div>

                <div className="text-center py-8 mt-6 border-t border-border/30">
                    <div className="flex items-center justify-center gap-2 text-muted-foreground/50">
                        <img
                            src={logo}
                            alt="JustScroll"
                            className="h-5 w-auto opacity-50"
                        />
                    </div>
                    <p className="text-xs text-muted-foreground/30 mt-2">
                        v1.0.0 · Powered by MangaDex, Jikan & ComicVine
                    </p>
                </div>
            </div>

            {/* Mobile Layout */}
            <div className="lg:hidden space-y-4">
                <div className="flex items-center gap-4 p-4 rounded-2xl border border-border/40 bg-card">
                    <ProfileAvatar username={user?.username} size="md" />
                    <div className="flex-1 min-w-0">
                        <h1 className="text-lg font-bold truncate">{user?.username}</h1>
                        {user?.email && (
                            <p className="text-xs text-muted-foreground truncate mt-0.5">
                                {user.email}
                            </p>
                        )}
                        <div
                            className={cn(
                                "inline-flex items-center gap-1",
                                "mt-2 px-2 py-0.5 rounded-full",
                                "bg-primary/5 border border-primary/10",
                                "text-[10px] font-medium text-primary"
                            )}
                        >
                            <Shield className="w-2.5 h-2.5" />
                            Member
                        </div>
                    </div>
                </div>

                <div className="grid grid-cols-2 gap-2.5">
                    <StatCard
                        icon={BookmarkPlus}
                        label="Bookmarks"
                        value={bookmarkCount}
                        sublabel="Saved titles"
                        color="bg-primary/10 text-primary"
                        onClick={() => navigate("/bookmarks")}
                        compact
                    />
                    <StatCard
                        icon={Clock}
                        label="Chapters"
                        value={historyCount}
                        sublabel="Total read"
                        color="bg-emerald-500/10 text-emerald-500"
                        onClick={() => navigate("/history")}
                        compact
                    />
                </div>

                <div className="grid grid-cols-4 gap-2">
                    <QuickAction
                        icon={BookmarkPlus}
                        label="Library"
                        color="bg-primary/10 text-primary"
                        onClick={() => navigate("/bookmarks")}
                        compact
                    />
                    <QuickAction
                        icon={History}
                        label="History"
                        color="bg-amber-500/10 text-amber-500"
                        onClick={() => navigate("/history")}
                        compact
                    />
                    <QuickAction
                        icon={TrendingUp}
                        label="Popular"
                        color="bg-emerald-500/10 text-emerald-500"
                        onClick={() => navigate("/discover")}
                        compact
                    />
                    <QuickAction
                        icon={Zap}
                        label="Latest"
                        color="bg-violet-500/10 text-violet-500"
                        onClick={() => navigate("/discover?tab=latest")}
                        compact
                    />
                </div>

                {recentHistory.length > 0 && (
                    <SectionCard
                        title="Continue Reading"
                        action={
                            historyCount > 4 ? (
                                <button
                                    onClick={() => navigate("/history")}
                                    className="text-[11px] text-primary font-medium hover:underline"
                                >
                                    See all
                                </button>
                            ) : null
                        }
                    >
                        {recentHistory.map((entry) => (
                            <ContinueReadingCard
                                key={entry.id}
                                entry={entry}
                                onClick={() =>
                                    navigate(
                                        `/read/${entry.chapter_id}?manga=${entry.manga_id}`
                                    )
                                }
                            />
                        ))}
                    </SectionCard>
                )}

                {recentBookmarks.length > 0 && (
                    <SectionCard
                        title="Saved Manga"
                        action={
                            bookmarkCount > 4 ? (
                                <button
                                    onClick={() => navigate("/bookmarks")}
                                    className="text-[11px] text-primary font-medium hover:underline"
                                >
                                    See all
                                </button>
                            ) : null
                        }
                        noPadding
                    >
                        <div className="flex gap-2 px-3 py-3 overflow-x-auto scrollbar-none">
                            {recentBookmarks.slice(0, 4).map((bk) => (
                                <button
                                    key={bk.id}
                                    onClick={() => navigate(`/manga/${bk.manga_id}`)}
                                    className="flex-shrink-0 group"
                                >
                                    <div className="w-14 aspect-[2/3] rounded-lg overflow-hidden border border-border/20 bg-muted">
                                        {bk.cover_url ? (
                                            <img
                                                src={proxyImage(bk.cover_url)}
                                                alt={bk.manga_title}
                                                className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                                                loading="lazy"
                                            />
                                        ) : (
                                            <div className="w-full h-full flex items-center justify-center">
                                                <BookOpen className="w-4 h-4 text-muted-foreground/30" />
                                            </div>
                                        )}
                                    </div>
                                    <p className="text-[10px] font-medium mt-1.5 w-14 truncate text-center group-hover:text-primary transition-colors">
                                        {bk.manga_title}
                                    </p>
                                </button>
                            ))}
                            {bookmarkCount > 4 && (
                                <button
                                    onClick={() => navigate("/bookmarks")}
                                    className="flex-shrink-0"
                                >
                                    <div
                                        className={cn(
                                            "w-14 aspect-[2/3] rounded-lg",
                                            "border border-dashed border-border",
                                            "flex items-center justify-center",
                                            "hover:border-primary/40 hover:bg-primary/5",
                                            "transition-all duration-200"
                                        )}
                                    >
                                        <div className="flex flex-col items-center gap-1">
                                            <ArrowRight className="w-3.5 h-3.5 text-muted-foreground" />
                                            <span className="text-[8px] text-muted-foreground">
                                                More
                                            </span>
                                        </div>
                                    </div>
                                </button>
                            )}
                        </div>
                    </SectionCard>
                )}

                <SectionCard title="Appearance" noPadding>
                    <div className="px-3 py-3">
                        <div className="flex gap-2">
                            <ThemeOption
                                icon={Sun}
                                label="Light"
                                value="light"
                                currentTheme={theme}
                                onSelect={setTheme}
                                compact
                            />
                            <ThemeOption
                                icon={Moon}
                                label="Dark"
                                value="dark"
                                currentTheme={theme}
                                onSelect={setTheme}
                                compact
                            />
                        </div>
                    </div>
                </SectionCard>

                <SectionCard title="Reader Settings" noPadding>
                    <div className="px-3 py-3 space-y-3">
                        <SettingToggle
                            label="Image Quality"
                            options={[
                                { value: "data", label: "High", icon: ImageIcon },
                                { value: "dataSaver", label: "Saver", icon: Zap },
                            ]}
                            value={quality}
                            onChange={setQuality}
                            compact
                        />
                        <SettingToggle
                            label="Reading Mode"
                            options={[
                                { value: "single", label: "Page", icon: Eye },
                                { value: "continuous", label: "Scroll", icon: Scroll },
                            ]}
                            value={mode}
                            onChange={setMode}
                            compact
                        />
                    </div>
                </SectionCard>

                <SectionCard title="Account">
                    <MenuItem
                        icon={User}
                        label="Account Details"
                        description={user?.email || "Manage your account"}
                        onClick={() => { }}
                    />
                    <MenuItem
                        icon={Shield}
                        label="Privacy & Security"
                        description="Password, sessions"
                        onClick={() => { }}
                    />
                </SectionCard>

                <SectionCard>
                    <MenuItem
                        icon={LogOut}
                        label="Sign Out"
                        description={`Signed in as ${user?.username}`}
                        variant="danger"
                        onClick={handleLogout}
                    />
                </SectionCard>

                <div className="text-center py-4 space-y-1">
                    <div className="flex items-center justify-center gap-1.5 text-muted-foreground/40">
                        <img
                            src={logo}
                            alt="JustScroll"
                            className="h-4 w-auto opacity-40"
                        />
                    </div>
                    <p className="text-[10px] text-muted-foreground/30">
                        v1.0.0 · Powered by MangaDex, Jikan & ComicVine
                    </p>
                </div>
            </div>
        </div>
    );
}