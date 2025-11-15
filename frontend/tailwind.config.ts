import type { Config } from "tailwindcss";

export default {
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      fontFamily: {
        sans: ["'SF Pro Display'", "Inter", "sans-serif"]
      }
    }
  },
  plugins: []
} satisfies Config;
