#!/usr/bin/env python3
"""Export all 68 Trippified screens as PNG files using Playwright."""

import json
import re
from pathlib import Path
from playwright.sync_api import sync_playwright

def sanitize_filename(name: str) -> str:
    """Convert screen name to valid filename."""
    # Remove leading number and dot if present
    name = re.sub(r'^\d+\.\s*', '', name)
    # Replace special characters with hyphens
    name = re.sub(r'[^\w\s-]', '', name)
    # Replace spaces with hyphens
    name = re.sub(r'\s+', '-', name)
    # Convert to lowercase
    return name.lower().strip('-')

def main():
    base_dir = Path(__file__).parent
    output_dir = base_dir / "png-exports"
    output_dir.mkdir(exist_ok=True)

    # Load screen index
    with open(base_dir / "index.json") as f:
        index = json.load(f)

    screens = index["screens"]
    print(f"Exporting {len(screens)} screens to PNG...")

    # Create a single-screen viewer HTML
    viewer_html = '''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'DM Sans', sans-serif; background: transparent; }
        #screen { border-radius: 40px; overflow: hidden; }
    </style>
</head>
<body>
    <div id="screen"></div>
    <script>
        function renderScreen(screenData) {
            document.getElementById('screen').innerHTML = screenData;
        }
    </script>
</body>
</html>'''

    viewer_path = base_dir / "viewer.html"
    with open(viewer_path, 'w') as f:
        f.write(viewer_html)

    with sync_playwright() as p:
        browser = p.chromium.launch()

        for i, screen in enumerate(screens):
            screen_name = screen["name"]
            screen_index = screen["index"]

            # Skip the content frame (not a real screen)
            if screen_name == "itinPreviewContent":
                print(f"Skipping content frame: {screen_name}")
                continue

            filename = f"{screen_index:02d}-{sanitize_filename(screen_name)}.png"
            output_path = output_dir / filename

            print(f"[{i+1}/{len(screens)}] Exporting: {screen_name}")

            # Create a page for this screen
            page = browser.new_page(viewport={'width': 390, 'height': 844})

            # Load the preview HTML and extract just this screen
            page.goto(f"file://{base_dir}/preview.html")
            page.wait_for_load_state('networkidle')

            # Find and screenshot the specific screen
            # Each screen is in a .screen-container with .screen-frame
            screen_selector = f'.screen-container:nth-child({i+1}) .screen-frame > div'

            try:
                # Get the screen element
                screen_element = page.locator(screen_selector).first

                # Remove the 0.5 scale transform from the parent
                page.evaluate('''(index) => {
                    const frames = document.querySelectorAll('.screen-frame');
                    if (frames[index]) {
                        frames[index].style.transform = 'none';
                        frames[index].style.height = 'auto';
                    }
                    const wrappers = document.querySelectorAll('.screen-wrapper');
                    if (wrappers[index]) {
                        wrappers[index].style.height = 'auto';
                    }
                }''', i)

                # Take screenshot of the screen element
                screen_element.screenshot(path=str(output_path))
                print(f"  -> Saved: {filename}")

            except Exception as e:
                print(f"  -> Error: {e}")

            page.close()

        browser.close()

    # Cleanup
    viewer_path.unlink(missing_ok=True)

    print(f"\nDone! Exported screens to: {output_dir}")

if __name__ == "__main__":
    main()
