import { defineConfig } from 'vite'
import { resolve } from "node:path";
import react from '@vitejs/plugin-react-swc'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: { 
    // 절대경로 추가
      "@": resolve(__dirname, "./src"),
    },
  },
  server: {
    // 로컬호스트 변경(포트 3000)
    host: "localhost",
    port: 3000,
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          react: ["react", "react-dom"],
        },
      },
    },
  },
});
