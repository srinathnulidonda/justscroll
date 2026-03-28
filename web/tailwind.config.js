// frontend/tailwind.config.js
/** @type {import('tailwindcss').Config} */
export default {
    darkMode: "class",
    content: ["./index.html", "./src/**/*.{js,jsx}"],
    theme: {
        screens: {
            xs: "400px",
            sm: "640px",
            md: "768px",
            lg: "1024px",
            xl: "1280px",
            "2xl": "1536px",
        },
        extend: {
            fontFamily: {
                sans: [
                    "Inter",
                    "SF Pro Display",
                    "-apple-system",
                    "BlinkMacSystemFont",
                    "Segoe UI",
                    "sans-serif",
                ],
                mono: [
                    "JetBrains Mono",
                    "SF Mono",
                    "Fira Code",
                    "monospace",
                ],
            },
            colors: {
                border: "hsl(var(--border))",
                input: "hsl(var(--input))",
                ring: "hsl(var(--ring))",
                background: "hsl(var(--background))",
                foreground: "hsl(var(--foreground))",
                primary: {
                    DEFAULT: "hsl(var(--primary))",
                    foreground: "hsl(var(--primary-foreground))",
                },
                secondary: {
                    DEFAULT: "hsl(var(--secondary))",
                    foreground: "hsl(var(--secondary-foreground))",
                },
                destructive: {
                    DEFAULT: "hsl(var(--destructive))",
                    foreground: "hsl(var(--destructive-foreground))",
                },
                muted: {
                    DEFAULT: "hsl(var(--muted))",
                    foreground: "hsl(var(--muted-foreground))",
                },
                accent: {
                    DEFAULT: "hsl(var(--accent))",
                    foreground: "hsl(var(--accent-foreground))",
                },
                card: {
                    DEFAULT: "hsl(var(--card))",
                    foreground: "hsl(var(--card-foreground))",
                },
                popover: {
                    DEFAULT: "hsl(var(--popover))",
                    foreground: "hsl(var(--popover-foreground))",
                },
            },
            fontSize: {
                "2xs": ["0.625rem", { lineHeight: "0.875rem" }],
            },
            spacing: {
                4.5: "1.125rem",
                5.5: "1.375rem",
                13: "3.25rem",
                15: "3.75rem",
                18: "4.5rem",
                22: "5.5rem",
            },
            borderRadius: {
                sm: "calc(var(--radius) - 4px)",
                md: "calc(var(--radius) - 2px)",
                lg: "var(--radius)",
                xl: "calc(var(--radius) + 4px)",
                "2xl": "calc(var(--radius) + 8px)",
                "3xl": "1.5rem",
            },
            boxShadow: {
                subtle: "0 1px 2px 0 rgb(0 0 0 / 0.03)",
                soft: "0 2px 8px -2px rgb(0 0 0 / 0.08), 0 1px 2px -1px rgb(0 0 0 / 0.06)",
                medium:
                    "0 4px 16px -4px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.06)",
                large:
                    "0 8px 32px -8px rgb(0 0 0 / 0.14), 0 4px 8px -4px rgb(0 0 0 / 0.08)",
                glow: "0 0 20px -4px hsl(var(--primary) / 0.3)",
                "inner-sm": "inset 0 1px 2px 0 rgb(0 0 0 / 0.05)",
            },
            backdropBlur: {
                xs: "2px",
            },
            animation: {
                "fade-in": "fadeIn 0.3s ease-out forwards",
                "fade-up": "fadeUp 0.4s ease-out forwards",
                "slide-in-right": "slideInRight 0.3s ease-out forwards",
                "slide-in-left": "slideInLeft 0.3s ease-out forwards",
                "scale-in": "scaleIn 0.2s ease-out forwards",
                shimmer: "shimmer 1.5s infinite",
                "spin-slow": "spin 3s linear infinite",
                float: "float 3s ease-in-out infinite",
                "pulse-soft": "pulseSoft 2s ease-in-out infinite",
            },
            keyframes: {
                fadeIn: {
                    "0%": { opacity: "0" },
                    "100%": { opacity: "1" },
                },
                fadeUp: {
                    "0%": { opacity: "0", transform: "translateY(10px)" },
                    "100%": { opacity: "1", transform: "translateY(0)" },
                },
                slideInRight: {
                    "0%": { opacity: "0", transform: "translateX(20px)" },
                    "100%": { opacity: "1", transform: "translateX(0)" },
                },
                slideInLeft: {
                    "0%": { opacity: "0", transform: "translateX(-20px)" },
                    "100%": { opacity: "1", transform: "translateX(0)" },
                },
                scaleIn: {
                    "0%": { opacity: "0", transform: "scale(0.95)" },
                    "100%": { opacity: "1", transform: "scale(1)" },
                },
                shimmer: {
                    "0%": { transform: "translateX(-100%)" },
                    "100%": { transform: "translateX(100%)" },
                },
                float: {
                    "0%, 100%": { transform: "translateY(0)" },
                    "50%": { transform: "translateY(-10px)" },
                },
                pulseSoft: {
                    "0%, 100%": { opacity: "1" },
                    "50%": { opacity: "0.7" },
                },
            },
            transitionDuration: {
                250: "250ms",
                350: "350ms",
                400: "400ms",
            },
            transitionTimingFunction: {
                "ease-spring": "cubic-bezier(0.4, 0, 0.2, 1)",
                "ease-bounce": "cubic-bezier(0.34, 1.56, 0.64, 1)",
            },
            zIndex: {
                60: "60",
                70: "70",
                80: "80",
                90: "90",
                100: "100",
            },
            maxWidth: {
                "8xl": "88rem",
                "9xl": "96rem",
            },
            aspectRatio: {
                poster: "2 / 3",
                cover: "3 / 4",
                banner: "16 / 9",
                square: "1 / 1",
            },
            gridTemplateColumns: {
                cards: "repeat(auto-fill, minmax(140px, 1fr))",
                "cards-sm": "repeat(auto-fill, minmax(120px, 1fr))",
                "cards-lg": "repeat(auto-fill, minmax(180px, 1fr))",
            },
        },
    },
    plugins: [],
};