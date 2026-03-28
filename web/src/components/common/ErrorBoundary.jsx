// frontend/src/components/common/ErrorBoundary.jsx
import { Component } from "react";
import { Button } from "@/components/ui/Button";
import { AlertTriangle } from "lucide-react";

export class ErrorBoundary extends Component {
    constructor(props) {
        super(props);
        this.state = { hasError: false, error: null };
    }

    static getDerivedStateFromError(error) {
        return { hasError: true, error };
    }

    render() {
        if (this.state.hasError) {
            return (
                <div className="flex flex-col items-center justify-center min-h-[400px] p-8 text-center">
                    <div className="rounded-2xl bg-destructive/10 p-4 mb-4">
                        <AlertTriangle className="h-8 w-8 text-destructive" />
                    </div>
                    <h2 className="text-xl font-semibold mb-2">Something went wrong</h2>
                    <p className="text-muted-foreground text-sm mb-6 max-w-md">
                        An unexpected error occurred. Please try refreshing the page.
                    </p>
                    <Button onClick={() => window.location.reload()} variant="outline">
                        Refresh Page
                    </Button>
                </div>
            );
        }
        return this.props.children;
    }
}