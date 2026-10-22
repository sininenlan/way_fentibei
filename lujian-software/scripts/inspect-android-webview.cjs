const { chromium } = require("playwright-core");

(async () => {
  const browser = await chromium.connectOverCDP("http://127.0.0.1:9222");
  const page = browser.contexts()[0].pages()[0];
  const result = await page.evaluate(() => ({
    viewport: [window.innerWidth, window.innerHeight],
    htmlClass: document.documentElement.className,
    children: [...document.querySelectorAll(".topbar-actions > *")].map((element) => {
      const rect = element.getBoundingClientRect();
      return {
        className: element.className,
        display: getComputedStyle(element).display,
        text: element.textContent.trim(),
        rect: [rect.x, rect.y, rect.width, rect.height],
      };
    }),
    bodyScrollWidth: document.body.scrollWidth,
  }));
  await page.screenshot({ path: "artifacts/android-playwright.png" });
  await page.evaluate(() => {
    document.querySelector(".worker-detail")?.scrollIntoView({ block: "start" });
  });
  await page.waitForTimeout(700);
  await page.screenshot({ path: "artifacts/android-playwright-detail.png" });
  await page.getByRole("button", { name: "完成处置" }).click();
  await page.waitForTimeout(700);
  result.completionStatus = await page.locator(".status-pill").first().textContent();
  await page.reload({ waitUntil: "domcontentloaded" });
  await page.waitForSelector(".worker-layout");
  console.log(JSON.stringify(result, null, 2));
  await browser.close();
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
