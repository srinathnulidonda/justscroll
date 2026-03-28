// frontend/src/components/common/OptimizedImage.jsx
import { useState, useRef, useEffect } from "react";
import { cn } from "@/lib/utils";
import { proxyImage } from "@/lib/utils";
import { ImageOff } from "lucide-react";

export function OptimizedImage({
    src,
    alt,
    className,
    containerClassName,
    fallback,
    proxy = true,
    aspect = "3/4",
    ...props
}) {
    const [loaded, setLoaded] = useState(false);
    const [error, setError] = useState(false);
    const imgRef = useRef(null);
    const observerRef = useRef(null);
    const [inView, setInView] = useState(false);

    const imgSrc = proxy ? proxyImage(src) : src;

    useEffect(() => {
        observerRef.current = new IntersectionObserver(
            ([entry]) => {
                if (entry.isIntersecting) {
                    setInView(true);
                    observerRef.current?.disconnect();
                }
            },
            { rootMargin: "200px" }
        );
        if (imgRef.current) observerRef.current.observe(imgRef.current);
        return () => observerRef.current?.disconnect();
    }, []);

    if (error || !src) {
        return (
            <div
                className={cn(
                    "flex items-center justify-center bg-muted rounded-xl",
                    containerClassName
                )}
                style={{ aspectRatio: aspect }}
            >
                {fallback || <ImageOff className="h-8 w-8 text-muted-foreground/40" />}
            </div>
        );
    }

    return (
        <div
            ref={imgRef}
            className={cn("relative overflow-hidden rounded-xl bg-muted", containerClassName)}
            style={{ aspectRatio: aspect }}
        >
            {inView && (
                <img
                    src={imgSrc}
                    alt={alt}
                    loading="lazy"
                    onLoad={() => setLoaded(true)}
                    onError={() => setError(true)}
                    className={cn(
                        "h-full w-full object-cover transition-opacity duration-500",
                        loaded ? "opacity-100" : "opacity-0",
                        className
                    )}
                    {...props}
                />
            )}
            {!loaded && !error && (
                <div className="absolute inset-0 bg-muted animate-pulse" />
            )}
        </div>
    );
}