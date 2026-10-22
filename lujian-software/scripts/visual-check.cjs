const fs = require("node:fs");
const path = require("node:path");
const { chromium } = require("playwright-core");

const edge = "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe";
const output = path.resolve(process.cwd(), "artifacts");
fs.mkdirSync(output, { recursive: true });

async function capture(page, name) {
  await page.screenshot({ path: path.join(output, name), fullPage: false });
}

(async () => {
  const browser = await chromium.launch({
    headless: true,
    executablePath: edge,
    args: ["--disable-gpu", "--no-first-run", "--disable-features=msEdgeSidebarV2"],
  });
  const page = await browser.newPage({ viewport: { width: 1440, height: 960 } });
  const consoleErrors = [];
  page.on("console", (message) => {
    if (message.type() === "error") consoleErrors.push(message.text());
  });
  page.on("pageerror", (error) => consoleErrors.push(error.message));

  await page.goto("http://127.0.0.1:8787", { waitUntil: "domcontentloaded" });
  await page.waitForSelector(".worker-layout");
  await page.waitForTimeout(2800);
  await capture(page, "worker-desktop.png");
  const completeBeforePhoto = await page.getByRole("button", { name: "完成处置" }).isDisabled();
  await page.locator(".repair-upload input").setInputFiles(
    path.join(process.cwd(), "public", "cover-evidence.png"),
  );
  await page.waitForSelector(".repair-upload.has-image");
  await page.waitForTimeout(300);
  const completeAfterPhoto = await page.getByRole("button", { name: "完成处置" }).isDisabled();
  await capture(page, "worker-repair.png");

  const workerMetrics = await page.evaluate(() => ({
    width: window.innerWidth,
    bodyScrollWidth: document.body.scrollWidth,
    mapVisible: Boolean(document.querySelector(".leaflet-container")),
    taskCards: document.querySelectorAll(".worker-order-card").length,
    detailVisible: Boolean(document.querySelector(".worker-detail")),
  }));

  await page.getByRole("button", { name: "数字孪生" }).click();
  await page.waitForSelector(".admin-layout");
  await page.waitForTimeout(2200);
  await capture(page, "admin-desktop.png");

  const adminMetrics = await page.evaluate(() => ({
    canvasCount: document.querySelectorAll("canvas").length,
    canvasSize: [...document.querySelectorAll("canvas")].map((canvas) => [
      canvas.width,
      canvas.height,
    ]),
    kpiCount: document.querySelectorAll(".kpi-item").length,
    tableRows: document.querySelectorAll(".data-table tbody tr").length,
  }));

  await page.getByRole("button", { name: /数据处理/ }).click();
  await page.waitForTimeout(500);
  await capture(page, "pipeline-desktop.png");

  await page.getByRole("button", { name: /采集终端/ }).click();
  await page.waitForTimeout(500);
  await capture(page, "terminals-desktop.png");
  const terminalMetrics = await page.evaluate(() => ({
    terminalCards: document.querySelectorAll(".device-terminal").length,
    bodyScrollWidth: document.body.scrollWidth,
    metricsCount: document.querySelectorAll(".device-metrics > div").length,
  }));

  await page.getByRole("button", { name: /合作服务/ }).click();
  await page.waitForTimeout(500);
  await capture(page, "services-desktop.png");
  const serviceMetrics = await page.evaluate(() => ({
    programCards: document.querySelectorAll(".program-card").length,
    governanceItems: document.querySelectorAll(".governance-list > div").length,
    bodyScrollWidth: document.body.scrollWidth,
  }));

  await page.getByRole("button", { name: /工单调度/ }).click();
  await page.waitForTimeout(500);
  await capture(page, "dispatch-desktop.png");
  await page.locator(".dispatch-queue-card").first().click();
  await page.getByRole("button", { name: "派发工单" }).click();
  await page.waitForSelector(".dispatch-modal");
  await capture(page, "dispatch-modal.png");
  const modalMetrics = await page.evaluate(() => ({
    workerOptions: document.querySelectorAll(".dispatch-modal select option").length,
    priorityOptions: document.querySelectorAll(".segmented-control button").length,
  }));
  await page.getByRole("button", { name: "关闭" }).click();

  await page.setViewportSize({ width: 390, height: 844 });
  await page.getByRole("button", { name: "工人作业" }).click();
  await page.waitForSelector(".worker-layout");
  await page.waitForTimeout(800);
  await capture(page, "worker-mobile.png");
  const mobileWorker = await page.evaluate(() => ({
    width: window.innerWidth,
    bodyScrollWidth: document.body.scrollWidth,
    mapHeight: document.querySelector(".worker-map-pane")?.getBoundingClientRect().height,
  }));

  await page.getByRole("button", { name: "数字孪生" }).click();
  await page.waitForSelector(".admin-layout");
  await page.waitForTimeout(500);
  await capture(page, "admin-mobile.png");
  const mobileAdmin = await page.evaluate(() => ({
    width: window.innerWidth,
    bodyScrollWidth: document.body.scrollWidth,
    sidebarVisible: Boolean(document.querySelector(".admin-sidebar")),
  }));

  await page.getByRole("button", { name: /合作服务/ }).click();
  await page.waitForSelector(".service-view");
  await page.waitForTimeout(400);
  await capture(page, "services-mobile.png");
  const mobileServices = await page.evaluate(() => ({
    width: window.innerWidth,
    bodyScrollWidth: document.body.scrollWidth,
    programCards: document.querySelectorAll(".program-card").length,
    governanceItems: document.querySelectorAll(".governance-list > div").length,
  }));

  console.log(
    JSON.stringify(
      {
        workerMetrics,
        adminMetrics,
        terminalMetrics,
        serviceMetrics,
        modalMetrics,
    photoFlow: { completeBeforePhoto, completeAfterPhoto },
        mobileWorker,
        mobileAdmin,
        mobileServices,
        consoleErrors: [...new Set(consoleErrors)].slice(0, 20),
      },
      null,
      2,
    ),
  );
  await browser.close();
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
