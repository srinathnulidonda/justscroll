// frontend/src/components/layout/Layout.jsx
import { Outlet, useLocation } from "react-router-dom";
import { Navbar } from "./Navbar";
import { MobileNav } from "./MobileNav";
import { Footer } from "./Footer";
import { ToastContainer } from "@/components/common/Toast";

const FOOTER_PATHS = ["/", "/discover", "/search"];

export function Layout() {
    const location = useLocation();
    const isReader = location.pathname.startsWith("/read");
    const showFooter = FOOTER_PATHS.includes(location.pathname);

    if (isReader) {
        return (
            <>
                <Outlet />
                <ToastContainer />
            </>
        );
    }

    return (
        <div className="flex min-h-screen flex-col">
            <a href="#main-content" className="skip-link">
                Skip to content
            </a>
            <Navbar />
            <main id="main-content" className={`flex-1 ${!showFooter ? "pb-20 md:pb-0" : ""}`}>
                <Outlet />
            </main>
            {showFooter && <Footer />}
            <MobileNav />
            <ToastContainer />
        </div>
    );
}