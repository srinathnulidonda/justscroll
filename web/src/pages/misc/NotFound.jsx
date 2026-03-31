// frontend/src/pages/misc/NotFound.jsx
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { Home, ArrowLeft } from "lucide-react";
import { motion } from "framer-motion";

export default function NotFound() {
    return (
        <div className="flex min-h-[70vh] items-center justify-center px-4">
            <motion.div
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.3 }}
                className="text-center max-w-md"
            >
                <div className="text-8xl font-bold gradient-text mb-4">404</div>
                <h1 className="text-2xl font-bold mb-2">Page not found</h1>
                <p className="text-muted-foreground mb-8">
                    The page you're looking for doesn't exist or has been moved.
                </p>
                <div className="flex flex-wrap items-center justify-center gap-3">
                    <Button variant="primary" size="lg" onClick={() => window.history.back()}>
                        <ArrowLeft className="h-4 w-4" /> Go Back
                    </Button>
                    <Link to="/">
                        <Button variant="outline" size="lg">
                            <Home className="h-4 w-4" /> Home
                        </Button>
                    </Link>
                </div>
            </motion.div>
        </div>
    );
}