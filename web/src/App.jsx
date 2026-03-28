// frontend/src/App.jsx
import { lazy, Suspense, useEffect } from "react";
import {
    BrowserRouter,
    Routes,
    Route,
    Navigate,
    useLocation,
} from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useAuthStore } from "@/stores/authStore";
import { Layout } from "@/components/layout/Layout";
import { ErrorBoundary } from "@/components/common/ErrorBoundary";

// Browse Pages
const Home = lazy(() => import("@/pages/browse/Home"));
const Discover = lazy(() => import("@/pages/browse/Discover"));
const SearchPage = lazy(() => import("@/pages/browse/Search"));

// Manga Pages
const MangaDetail = lazy(() => import("@/pages/manga/MangaDetail"));
const ReaderPage = lazy(() => import("@/pages/manga/ReaderPage"));

// Auth Pages
const Login = lazy(() => import("@/pages/auth/Login"));
const Register = lazy(() => import("@/pages/auth/Register"));

// User Pages
const Bookmarks = lazy(() => import("@/pages/user/Bookmarks"));
const History = lazy(() => import("@/pages/user/History"));
const Profile = lazy(() => import("@/pages/user/Profile"));

// Legal Pages
const PrivacyPolicy = lazy(() => import("@/pages/Privacy"));
const TermsOfService = lazy(() => import("@/pages/Terms"));
const CookiePolicy = lazy(() => import("@/pages/Cookies"));

// Other
const NotFound = lazy(() => import("@/pages/NotFound"));

const queryClient = new QueryClient({
    defaultOptions: {
        queries: {
            refetchOnWindowFocus: false,
            refetchOnMount: true,
            retry: 1,
            staleTime: 2 * 60 * 1000,
            cacheTime: 5 * 60 * 1000,
        },
    },
});

function PageLoader() {
    return (
        <div className="flex items-center justify-center min-h-[50vh]">
            <div className="flex flex-col items-center gap-3">
                <div className="h-8 w-8 rounded-full border-2 border-primary border-t-transparent animate-spin" />
                <span className="text-sm text-muted-foreground">
                    Loading…
                </span>
            </div>
        </div>
    );
}

function ScrollToTop() {
    const { pathname } = useLocation();
    useEffect(() => {
        window.scrollTo(0, 0);
    }, [pathname]);
    return null;
}

function ProtectedRoute({ children }) {
    const { isAuthenticated, isLoading } = useAuthStore();
    const location = useLocation();

    if (isLoading) {
        return <PageLoader />;
    }

    if (!isAuthenticated) {
        return <Navigate to="/login" state={{ from: location }} replace />;
    }

    return <>{children}</>;
}

function AppRoutes() {
    return (
        <Routes>
            <Route element={<Layout />}>
                {/* Browse */}
                <Route
                    index
                    element={
                        <Suspense fallback={<PageLoader />}>
                            <Home />
                        </Suspense>
                    }
                />
                <Route
                    path="discover"
                    element={
                        <Suspense fallback={<PageLoader />}>
                            <Discover />
                        </Suspense>
                    }
                />
                <Route
                    path="search"
                    element={
                        <Suspense fallback={<PageLoader />}>
                            <SearchPage />
                        </Suspense>
                    }
                />

                {/* Manga */}
                <Route
                    path="manga/:id"
                    element={
                        <Suspense fallback={<PageLoader />}>
                            <MangaDetail />
                        </Suspense>
                    }
                />

                {/* Auth */}
                <Route
                    path="login"
                    element={
                        <Suspense fallback={<PageLoader />}>
                            <Login />
                        </Suspense>
                    }
                />
                <Route
                    path="register"
                    element={
                        <Suspense fallback={<PageLoader />}>
                            <Register />
                        </Suspense>
                    }
                />

                {/* User (Protected) */}
                <Route
                    path="bookmarks"
                    element={
                        <ProtectedRoute>
                            <Suspense fallback={<PageLoader />}>
                                <Bookmarks />
                            </Suspense>
                        </ProtectedRoute>
                    }
                />
                <Route
                    path="history"
                    element={
                        <ProtectedRoute>
                            <Suspense fallback={<PageLoader />}>
                                <History />
                            </Suspense>
                        </ProtectedRoute>
                    }
                />
                <Route
                    path="profile"
                    element={
                        <ProtectedRoute>
                            <Suspense fallback={<PageLoader />}>
                                <Profile />
                            </Suspense>
                        </ProtectedRoute>
                    }
                />

                {/* Legal */}
                <Route
                    path="privacy"
                    element={
                        <Suspense fallback={<PageLoader />}>
                            <PrivacyPolicy />
                        </Suspense>
                    }
                />
                <Route
                    path="terms"
                    element={
                        <Suspense fallback={<PageLoader />}>
                            <TermsOfService />
                        </Suspense>
                    }
                />
                <Route
                    path="cookies"
                    element={
                        <Suspense fallback={<PageLoader />}>
                            <CookiePolicy />
                        </Suspense>
                    }
                />

                {/* 404 */}
                <Route
                    path="*"
                    element={
                        <Suspense fallback={<PageLoader />}>
                            <NotFound />
                        </Suspense>
                    }
                />
            </Route>

            {/* Reader (outside Layout - fullscreen) */}
            <Route
                path="read/:chapterId"
                element={
                    <Suspense fallback={<PageLoader />}>
                        <ReaderPage />
                    </Suspense>
                }
            />
        </Routes>
    );
}

export default function App() {
    const initialize = useAuthStore((s) => s.initialize);

    useEffect(() => {
        initialize();
    }, [initialize]);

    return (
        <QueryClientProvider client={queryClient}>
            <BrowserRouter
                future={{
                    v7_startTransition: true,
                    v7_relativeSplatPath: true,
                }}
            >
                <ScrollToTop />
                <ErrorBoundary>
                    <AppRoutes />
                </ErrorBoundary>
            </BrowserRouter>
        </QueryClientProvider>
    );
}