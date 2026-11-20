import type { NextConfig } from "next";
import { previewAncestors } from "./src/lib/preview-hosts";

const managedPreview = !!process.env.E2B_SANDBOX_ID && process.env.SUNU_ENV !== "production";
const publicPages = ["/", "/espace-ecole", "/fonctionnalites", "/faq", "/contact", "/ouvrir-espace"];
const workspacePages = ["/login", "/connexion", "/inscription", "/mot-de-passe-oublie", "/reinitialiser", "/onboarding", "/dashboard", "/journal", "/eleves/:path*", "/synthese", "/fiche-renvoi", "/historique", "/parametres", "/utilisateurs"];
const ancestors = previewAncestors(process.env.SUNU_PREVIEW_ANCESTORS);
function policy(frameAncestors: string) {
  return ["default-src 'self'", "base-uri 'self'", "form-action 'self'", `frame-ancestors ${frameAncestors}`, "object-src 'none'", "script-src 'self' 'unsafe-inline'", "style-src 'self' 'unsafe-inline'", "img-src 'self' data: blob:", "font-src 'self' data:", "connect-src 'self'", "frame-src 'self' blob:", "media-src 'self' blob:", ...(!managedPreview ? ["upgrade-insecure-requests"] : [])].join("; ");
}
const nextConfig: NextConfig = {
  poweredByHeader: false,
  env: { NEXT_PUBLIC_SUNU_PREVIEW_ANCESTORS: managedPreview ? ancestors.join(" ") : "" },
  images: { formats: ["image/avif", "image/webp"] },
  outputFileTracingIncludes: { "/api/*": ["./supabase.sql"] },
  async headers() {
    return [{ source: "/:path*", headers: [
      { key: "Content-Security-Policy", value: policy("'none'") },
      ...(!managedPreview ? [{ key: "X-Frame-Options", value: "DENY" }] : []),
      { key: "X-Content-Type-Options", value: "nosniff" },
      { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
      { key: "Permissions-Policy", value: "camera=(), microphone=(), geolocation=()" },
      { key: "Strict-Transport-Security", value: "max-age=63072000; includeSubDomains" },
    ] }, ...(managedPreview ? [
      ...publicPages.map((source) => ({ source, headers: [{ key: "Content-Security-Policy", value: policy("'self' https: http://localhost:* http://127.0.0.1:*") }] })),
      // Private HTML is only embeddable by the trusted managed viewer. Every
      // record still requires a real bearer session at the API. Production denies all framing.
      ...workspacePages.map((source) => ({ source, headers: [{ key: "Content-Security-Policy", value: policy(`'self' ${ancestors.join(" ")}`) }] })),
      { source: "/api/:path*", headers: [{ key: "X-Frame-Options", value: "DENY" }, { key: "Cache-Control", value: "private, no-store" }] },
    ] : [])];
  },
};
export default nextConfig;
