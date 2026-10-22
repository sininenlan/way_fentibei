import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [
    react(),
    {
      name: "geojson-loader",
      transform(code, id) {
        if (!id.endsWith(".geojson")) return null;
        return {
          code: `export default ${code}`,
          map: null,
        };
      },
    },
  ],
  server: { port: 4174 },
  build: { outDir: "dist" },
});
