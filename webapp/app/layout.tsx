import type { Metadata } from "next";
import "./globals.css";
import { AppProvider } from "./providers";

export const metadata: Metadata = {
  title: "MeinBudget - Finanzen im Griff",
  description: "Behalte deine Finanzen im Griff – Einnahmen, Ausgaben & Kredite einfach managen. Offline, sicher & übersichtlich.",
  manifest: "/manifest.json",
  themeColor: "#3b82f6",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="de" suppressHydrationWarning>
      <body
        className="antialiased bg-gray-50 dark:bg-gray-900 transition-colors"
      >
        <AppProvider>
          {children}
        </AppProvider>
      </body>
    </html>
  );
}
