const path = require("node:path");
const { chromium } = require("../../../lujian-software/node_modules/playwright-core");

const edge = "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe";

(async () => {
  const browser = await chromium.launch({ headless: true, executablePath: edge });
  const page = await browser.newPage({ viewport: { width: 1440, height: 960 } });
  const errors = [];
  page.on("console", (message) => {
    if (message.type() === "error") errors.push(message.text());
  });
  page.on("pageerror", (error) => errors.push(error.stack || error.message));
  await page.goto("http://127.0.0.1:4174", { waitUntil: "domcontentloaded" });
  await page.waitForTimeout(10000);
  const result = await page.evaluate(() => ({
    bodyScrollWidth: document.body.scrollWidth,
    width: window.innerWidth,
    canvasCount: document.querySelectorAll("canvas").length,
    text: document.body.innerText.slice(0, 1000),
    layers: window.__lujianStore
      ?.getState()
      .keplerGl?.lujian?.visState.layers.map((layer) => ({
        id: layer.id,
        type: layer.type,
        dataId: layer.config?.dataId,
        valid: layer.config?.isValid,
        colorField: layer.config?.colorField,
        colorScale: layer.config?.colorScale,
        sizeField: layer.config?.sizeField,
      })),
    mapStyle:
      window.__lujianStore?.getState().keplerGl?.lujian?.mapStyle.styleType,
    mapStyleKeys: Object.keys(
      window.__lujianStore?.getState().keplerGl?.lujian?.mapStyle.mapStyles ||
        {},
    ),
    resources: performance
      .getEntriesByType("resource")
      .map((entry) => entry.name)
      .filter((name) => name.includes("base_network") || name.includes("road_")),
  }));
  await page.screenshot({
    path: path.resolve(process.cwd(), "artifacts", "kepler-map.png"),
    fullPage: false,
  });
  console.log(JSON.stringify({ result, errors: [...new Set(errors)].slice(0, 20) }, null, 2));
  await browser.close();
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
