const { chromium } = require("playwright-core");

const edge = "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe";

async function mapState(page, selector = ".leaflet-map-pane") {
  return page.evaluate((target) => {
    const pane = document.querySelector(target);
    const container = document.querySelector(".leaflet-container");
    return {
      paneTransform: pane?.style.transform || "",
      cursor: container ? getComputedStyle(container).cursor : "",
      pointerEvents: container ? getComputedStyle(container).pointerEvents : "",
      rect: container
        ? (() => {
            const box = container.getBoundingClientRect();
            return [box.x, box.y, box.width, box.height];
          })()
        : null,
    };
  }, selector);
}

(async () => {
  const browser = await chromium.launch({ headless: true, executablePath: edge });
  const page = await browser.newPage({ viewport: { width: 1440, height: 960 } });
  await page.goto("http://127.0.0.1:8787", { waitUntil: "domcontentloaded" });
  await page.waitForSelector(".leaflet-container");
  await page.waitForTimeout(1200);

  const before = await mapState(page);
  const [x, y, width, height] = before.rect;
  const startX = x + width * 0.55;
  const startY = y + height * 0.45;
  await page.mouse.move(startX, startY);
  await page.mouse.down();
  await page.mouse.move(startX + 180, startY - 100, { steps: 20 });
  await page.mouse.up();
  await page.waitForTimeout(500);
  const afterDrag = await mapState(page);

  await page.mouse.click(startX, startY);
  await page.waitForTimeout(500);
  const afterClick = await mapState(page);
  const marker = await page.locator(".leaflet-interactive").first().boundingBox();
  if (marker) {
    await page.mouse.click(marker.x + marker.width / 2, marker.y + marker.height / 2);
    await page.waitForTimeout(500);
  }
  const afterMarkerClick = await mapState(page);

  await page.getByRole("button", { name: "数字孪生" }).click();
  await page.waitForSelector(".admin-layout .leaflet-container");
  await page.waitForTimeout(1200);
  const adminBefore = await mapState(page);
  const [ax, ay, aw, ah] = adminBefore.rect;
  const adminStartX = ax + aw * 0.52;
  const adminStartY = ay + ah * 0.48;
  await page.mouse.move(adminStartX, adminStartY);
  await page.mouse.down();
  await page.mouse.move(adminStartX - 170, adminStartY + 90, { steps: 20 });
  await page.mouse.up();
  await page.waitForTimeout(500);
  const adminAfterDrag = await mapState(page);

  console.log(
    JSON.stringify(
      { before, afterDrag, afterClick, afterMarkerClick, adminBefore, adminAfterDrag },
      null,
      2,
    ),
  );
  await browser.close();
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
