import { cp, mkdir, readFile, rm, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import babel from "@rollup/plugin-babel";
import commonjs from "@rollup/plugin-commonjs";
import { nodeResolve } from "@rollup/plugin-node-resolve";
import replace from "@rollup/plugin-replace";
import { rollup } from "rollup";

const root = path.dirname(fileURLToPath(import.meta.url));
const dist = path.join(root, "dist");
const assets = path.join(dist, "assets");
const androidWorkerAssets = path.resolve(
  root,
  "..",
  "lujian-worker-android",
  "app",
  "src",
  "main",
  "assets",
  "worker",
);

await rm(dist, { recursive: true, force: true });
await mkdir(assets, { recursive: true });

const bundle = await rollup({
  input: path.join(root, "src", "main.jsx"),
  plugins: [
    replace({
      preventAssignment: true,
      "process.env.NODE_ENV": JSON.stringify("production"),
    }),
    nodeResolve({ browser: true, extensions: [".mjs", ".js", ".json", ".jsx"] }),
    commonjs({ transformMixedEsModules: true }),
    babel({
      babelHelpers: "bundled",
      extensions: [".js", ".jsx"],
      exclude: "node_modules/**",
      presets: [["@babel/preset-react", { runtime: "automatic" }]],
    }),
  ],
});

await bundle.write({
  file: path.join(assets, "app.js"),
  format: "iife",
  sourcemap: false,
});
await bundle.close();

await cp(
  path.join(root, "src", "styles.css"),
  path.join(dist, "styles.css"),
);
await cp(
  path.join(root, "node_modules", "leaflet", "dist", "leaflet.css"),
  path.join(dist, "leaflet.css"),
);
await cp(
  path.join(root, "node_modules", "leaflet", "dist", "images"),
  path.join(dist, "images"),
  { recursive: true },
);
await cp(
  path.join(root, "public"),
  dist,
  { recursive: true },
);
await writeFile(
  path.join(dist, "index.html"),
  await readFile(path.join(root, "index.html"), "utf8"),
  "utf8",
);

const store = JSON.parse(
  await readFile(path.join(root, "server", "data", "store.json"), "utf8"),
);
store.summary = {
  monitoredKm: 126.4,
  activeTerminals: store.terminals.filter((terminal) => terminal.status === "online").length,
  totalTerminals: store.terminals.length,
  pendingDefects: store.defects.filter((defect) =>
    ["pending_review", "awaiting_dispatch"].includes(defect.status),
  ).length,
  highRisk: store.defects.filter(
    (defect) => defect.severity === "high" && defect.status !== "completed",
  ).length,
  openOrders: store.orders.filter(
    (order) => !["completed", "cancelled"].includes(order.status),
  ).length,
  completedOrders: store.orders.filter((order) => order.status === "completed").length,
  averageConfidence: 0.862,
  latestCapture: store.defects
    .map((defect) => defect.lastSeen)
    .sort()
    .at(-1),
};

await rm(androidWorkerAssets, { recursive: true, force: true });
await mkdir(androidWorkerAssets, { recursive: true });
await cp(dist, androidWorkerAssets, { recursive: true });
await writeFile(
  path.join(androidWorkerAssets, "bootstrap.js"),
  `window.__LUJIAN_LOCAL_STORE__ = ${JSON.stringify(store)};\ndocument.documentElement.classList.add("android-demo");\n`,
  "utf8",
);
const androidIndex = (await readFile(path.join(androidWorkerAssets, "index.html"), "utf8"))
  .replace(/href="\/leaflet\.css(?:\?[^"]*)?"/, 'href="leaflet.css"')
  .replace(/href="\/styles\.css(?:\?[^"]*)?"/, 'href="styles.css"')
  .replace(
    /<script type="module" src="\/assets\/app\.js(?:\?[^"]*)?"><\/script>/,
    '<script src="bootstrap.js"></script>\n    <script src="assets/app.js"></script>',
  );
await writeFile(path.join(androidWorkerAssets, "index.html"), androidIndex, "utf8");

console.log("Built dist/");
