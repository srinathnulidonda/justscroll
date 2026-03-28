// frontend/src/pages/Login.jsx
import { useState } from "react";
import { Link, useNavigate, useLocation } from "react-router-dom";
import { useAuthStore } from "@/stores/authStore";
import { toast } from "@/stores/toastStore";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import {
    Card,
    CardContent,
    CardHeader,
    CardTitle,
    CardDescription,
} from "@/components/ui/Card";
import { User, Lock } from "lucide-react";
import { motion } from "framer-motion";
import logo from "@/assets/logo.png";

export default function Login() {
    const [username, setUsername] = useState("");
    const [password, setPassword] = useState("");
    const [loading, setLoading] = useState(false);
    const [errors, setErrors] = useState({});
    const { login } = useAuthStore();
    const navigate = useNavigate();
    const location = useLocation();

    // Get the page user was trying to reach
    const from = location.state?.from?.pathname || "/";

    const validate = () => {
        const e = {};
        if (!username.trim()) e.username = "Username is required";
        if (!password) e.password = "Password is required";
        setErrors(e);
        return Object.keys(e).length === 0;
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!validate()) return;
        setLoading(true);
        try {
            await login(username, password);
            toast.success("Welcome back!");
            // Redirect to the page they were trying to access
            navigate(from, { replace: true });
        } catch (err) {
            toast.error(err.message || "Invalid credentials");
            setErrors({ password: err.message || "Invalid credentials" });
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="flex min-h-[calc(100vh-8rem)] items-center justify-center px-4 py-8">
            <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.3 }}
                className="w-full max-w-sm"
            >
                <Card className="border-border/50 shadow-lg">
                    <CardHeader className="text-center pb-2">
                        <div className="flex justify-center mb-3">
                            <Link to="/">
                                <img
                                    src={logo}
                                    alt="JustScroll"
                                    className="h-9 sm:h-10 w-auto object-contain"
                                />
                            </Link>
                        </div>
                        <CardTitle className="text-xl">Welcome back</CardTitle>
                        <CardDescription>
                            Sign in to your account
                        </CardDescription>
                    </CardHeader>
                    <CardContent className="pt-4">
                        <form onSubmit={handleSubmit} className="space-y-4">
                            <Input
                                id="username"
                                label="Username"
                                placeholder="Enter your username"
                                icon={User}
                                value={username}
                                onChange={(e) => setUsername(e.target.value)}
                                error={errors.username}
                                autoComplete="username"
                                autoFocus
                            />
                            <Input
                                id="password"
                                label="Password"
                                placeholder="Enter your password"
                                type="password"
                                icon={Lock}
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                error={errors.password}
                                autoComplete="current-password"
                            />
                            <Button
                                type="submit"
                                className="w-full"
                                size="lg"
                                loading={loading}
                            >
                                Sign In
                            </Button>
                        </form>

                        <p className="mt-6 text-center text-sm text-muted-foreground">
                            Don't have an account?{" "}
                            <Link
                                to="/register"
                                state={location.state}
                                className="text-primary font-medium hover:underline"
                            >
                                Create one
                            </Link>
                        </p>
                    </CardContent>
                </Card>
            </motion.div>
        </div>
    );
}