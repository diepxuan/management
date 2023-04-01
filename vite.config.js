import { defineConfig } from "vite";
import laravel from "laravel-vite-plugin";
import path from "path";
import fs from "fs";

const host = "admin.diepxuan.com";
const port = "443";

export default defineConfig({
    plugins: [
        laravel({
            input: ["resources/scss/app.scss", "resources/js/app.js"],
            refresh: true,
        }),
    ],
    server: {
        https: {
            key: fs.readFileSync("./.cert/key.pem"),
            cert: fs.readFileSync("./.cert/cert.pem"),
        },
        proxy: {
            "^(?!(/@vite|/resources|/node_modules))": {
                target: `https://${host}:${port}`,
                changeOrigin: true,
            },
        },
        host: "0.0.0.0",
        port: 5173,
        hmr: { host },
    },
    resolve: {
        alias: {
            "~bootstrap": path.resolve(__dirname, "node_modules/bootstrap"),
        },
    },
});
