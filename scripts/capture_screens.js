const puppeteer = require('puppeteer');
const path = require('path');

const BASE_URL = 'https://trippified-26j.pages.dev';
const OUTPUT_DIR = path.join(__dirname, '..', 'wireframes');

const screens = [
  { name: '01_home_trippified', path: '/#/home', waitFor: 2000 },
  { name: '02_trip_setup', path: '/#/trip-setup', waitFor: 1000 },
  { name: '03_explore', path: '/#/home', clickTab: 1, waitFor: 1000 },
  { name: '04_saved', path: '/#/home', clickTab: 2, waitFor: 1000 },
  { name: '05_profile', path: '/#/home', clickTab: 3, waitFor: 1000 },
];

async function captureScreens() {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();

  // Set mobile viewport (iPhone 14 Pro size)
  await page.setViewport({
    width: 393,
    height: 852,
    deviceScaleFactor: 2,
  });

  for (const screen of screens) {
    console.log(`Capturing: ${screen.name}`);

    await page.goto(`${BASE_URL}${screen.path}`, { waitUntil: 'networkidle2' });
    await page.waitForTimeout(screen.waitFor);

    // Click tab if specified
    if (screen.clickTab !== undefined) {
      const tabs = await page.$$('nav button, .BottomNavigationBar button, [role="tab"]');
      if (tabs[screen.clickTab]) {
        await tabs[screen.clickTab].click();
        await page.waitForTimeout(500);
      }
    }

    await page.screenshot({
      path: path.join(OUTPUT_DIR, `${screen.name}.png`),
      fullPage: false,
    });
  }

  await browser.close();
  console.log(`\nDone! Screenshots saved to: ${OUTPUT_DIR}`);
}

captureScreens().catch(console.error);
