// frontend/src/pages/Register.jsx
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
import { User, Mail, Lock } from "lucide-react";
import { motion } from "framer-motion";
import logo from "@/assets/logo.png";

export default function Register() {
    const [form, setForm] = useState({
        username: "",
        email: "",
        password: "",
        confirm: "",
    });
    const [loading, setLoading] = useState(false);
    const [errors, setErrors] = useState({});
    const { register } = useAuthStore();
    const navigate = useNavigate();
    const location = useLocation();

    // Get the page user was trying to reach (passed from Login or MobileNav)
    const from = location.state?.from?.pathname || "/";

    const update = (field) => (e) =>
        setForm({ ...form, [field]: e.target.value });

    const validate = () => {
        const e = {};
        if (form.username.trim().length < 3)
            e.username = "Username must be at least 3 characters";
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email))
            e.email = "Enter a valid email";
        if (form.password.length < 6)
            e.password = "Password must be at least 6 characters";
        if (form.password !== form.confirm)
            e.confirm = "Passwords do not match";
        setErrors(e);
        return Object.keys(e).length === 0;
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!validate()) return;
        setLoading(true);
        try {
            await register(form.username, form.email, form.password);
            toast.success("Account created! Welcome aboard.");
            // Redirect to the page they were trying to access
            navigate(from, { replace: true });
        } catch (err) {
            toast.error(err.message || "Registration failed");
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
                        <CardTitle className="text-xl">
                            Create account
                        </CardTitle>
                        <CardDescription>
                            Start your reading journey
                        </CardDescription>
                    </CardHeader>
                    <CardContent className="pt-4">
                        <form onSubmit={handleSubmit} className="space-y-4">
                            <Input
                                id="reg-username"
                                label="Username"
                                placeholder="Choose a username"
                                icon={User}
                                value={form.username}
                                onChange={update("username")}
                                error={errors.username}
                                autoComplete="username"
                                autoFocus
                            />
                            <Input
                                id="reg-email"
                                label="Email"
                                placeholder="you@example.com"
                                type="email"
                                icon={Mail}
                                value={form.email}
                                onChange={update("email")}
                                error={errors.email}
                                autoComplete="email"
                            />
                            <Input
                                id="reg-password"
                                label="Password"
                                placeholder="Min. 6 characters"
                                type="password"
                                icon={Lock}
                                value={form.password}
                                onChange={update("password")}
                                error={errors.password}
                                autoComplete="new-password"
                            />
                            <Input
                                id="reg-confirm"
                                label="Confirm Password"
                                placeholder="Re-enter password"
                                type="password"
                                icon={Lock}
                                value={form.confirm}
                                onChange={update("confirm")}
                                error={errors.confirm}
                                autoComplete="new-password"
                            />
                            <Button
                                type="submit"
                                className="w-full"
                                size="lg"
                                loading={loading}
                            >
                                Create Account
                            </Button>
                        </form>

                        <p className="mt-6 text-center text-sm text-muted-foreground">
                            Already have an account?{" "}
                            <Link
                                to="/login"
                                state={location.state}
                                className="text-primary font-medium hover:underline"
                            >
                                Sign in
                            </Link>
                        </p>
                    </CardContent>
                </Card>
            </motion.div>
        </div>
    );
}