const puppeteer = require('puppeteer');
const path = require('path');

(async () => {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();

  // Load the HTML file
  const htmlPath = path.resolve(__dirname, 'putior-cheatsheet.html');
  await page.goto(`file://${htmlPath}`, { waitUntil: 'networkidle0' });

  // Generate PDF
  await page.pdf({
    path: path.resolve(__dirname, 'putior-cheatsheet.pdf'),
    width: '24in',
    height: '16in',
    printBackground: true,
    margin: { top: 0, right: 0, bottom: 0, left: 0 }
  });

  console.log('PDF generated successfully!');
  await browser.close();
})();
