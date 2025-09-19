import asyncio
from playwright.async_api import async_playwright
import datetime
import time

async def take_screenshot():
    now=datetime.datetime.now()
    """
    Navigates to the specified URL, waits for the page to load, and
    takes a full-page screenshot using Playwright.
    """
    # URL of the webpage to screenshot
    url = "https://experience.arcgis.com/experience/0d553dfc6c60487cb1f4d20b5366ee0b/page/Map-Page/"

    # Path to save the screenshot
    output_directory = ('C:/Users/george.maynard/Documents/emolt_project_management/WeeklyUpdates/'+now.strftime('%Y')+'/'+now.strftime('%Y-%m-%d')+'/')
    screenshot_path = os.path.join(output_directory,'CCB_screenshot.png')

    async with async_playwright() as p:
        # Launch a headless Chromium browser
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()

        try:
            print(f"Opening {url}...")
            time.sleep(10)
            await page.goto(url, wait_until="networkidle")

            # Playwright's "networkidle" wait_until option is generally good for
            # ensuring dynamic content like maps has loaded. It waits until
            # there have been no new network connections for at least 500ms.

            print("Taking full-page screenshot...")
            await page.screenshot(path=screenshot_path, full_page=True)

            print(f"Screenshot saved successfully to {screenshot_path}!")
        except Exception as e:
            print(f"An error occurred: {e}")
        finally:
            await browser.close()
            print("Browser closed.")

# Run the main async function
if __name__ == "__main__":
    asyncio.run(take_screenshot())
