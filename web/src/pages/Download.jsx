// web/src/pages/Download.jsx
// Add route: /download
export default function Download() {
    return (
        <div className="flex flex-col items-center justify-center min-h-[70vh] px-4">
            <h1 className="text-3xl font-bold mb-4">Download JustScroll</h1>
            <p className="text-muted-foreground mb-8">Get the Android app</p>
            <a
                href="https://github.com/srinathnulidonda/justscroll/releases/latest/download/app-release.apk"
                className="bg-primary text-primary-foreground px-8 py-3 rounded-xl font-medium"
            >
                Download APK
            </a>
            <p className="text-xs text-muted-foreground mt-4">v1.0.0 · Android 5.0+</p>
        </div>
    );
}