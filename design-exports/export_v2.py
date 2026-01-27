#!/usr/bin/env python3
"""Export Trippified screens as PNG files using Playwright with proper rendering."""

import json
import re
import time
from pathlib import Path
from playwright.sync_api import sync_playwright

def sanitize_filename(name: str) -> str:
    """Convert screen name to valid filename."""
    name = re.sub(r'^\d+\.\s*', '', name)
    name = re.sub(r'[^\w\s-]', '', name)
    name = re.sub(r'\s+', '-', name)
    return name.lower().strip('-')

def create_single_screen_html(screen_html: str, width: int, height: int) -> str:
    """Create an HTML page that renders a single screen at full size."""
    return f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width={width}, height={height}">
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,100..1000;1,9..40,100..1000&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/lucide-static@latest/font/lucide.min.css" rel="stylesheet">
    <style>
        * {{ box-sizing: border-box; margin: 0; padding: 0; }}
        html, body {{
            width: {width}px;
            height: {height}px;
            overflow: hidden;
            background: transparent;
        }}
        body {{
            font-family: 'DM Sans', sans-serif;
        }}
        .screen {{
            width: {width}px;
            height: {height}px;
        }}
        /* Lucide icons */
        [class^="lucide-"], [class*=" lucide-"] {{
            font-family: 'lucide' !important;
            font-style: normal;
            font-weight: normal;
        }}
    </style>
</head>
<body>
    <div class="screen">
        {screen_html}
    </div>
</body>
</html>'''

def main():
    base_dir = Path("/Users/jonmac/Documents/Projects/Trippified/design-exports")
    output_dir = base_dir / "png-exports"
    output_dir.mkdir(exist_ok=True)

    # Load index
    with open(base_dir / "index.json") as f:
        index = json.load(f)

    screens = index["screens"]
    print(f"Exporting {len(screens)} screens...")

    # Read the full preview.html to extract screen HTML
    with open(base_dir / "preview.html", "r") as f:
        preview_html = f.read()

    with sync_playwright() as p:
        browser = p.chromium.launch()

        for i, screen in enumerate(screens):
            screen_name = screen["name"]
            screen_index = screen["index"]
            width = screen.get("width", 390)
            height = screen.get("height", 844)

            if screen_name == "itinPreviewContent":
                print(f"Skipping: {screen_name}")
                continue

            filename = f"{screen_index:02d}-{sanitize_filename(screen_name)}.png"
            output_path = output_dir / filename

            print(f"[{i+1}/{len(screens)}] {screen_name}")

            # Create a page with exact screen dimensions
            page = browser.new_page(viewport={'width': width, 'height': height})

            # Navigate to preview.html
            page.goto(f"file://{base_dir}/preview.html")
            page.wait_for_load_state('networkidle')

            # Wait a bit for fonts and images
            page.wait_for_timeout(500)

            # Find the specific screen by index and extract its inner HTML
            # Then create a full-page screenshot of just that screen
            try:
                # Get the screen frame element
                screen_selector = f".screen-container:nth-child({i+1}) .screen-frame > div"

                # Set the page content to just this screen at full size
                screen_inner_html = page.evaluate(f'''() => {{
                    const screenEl = document.querySelector("{screen_selector}");
                    if (!screenEl) return null;

                    // Remove the scale transform from parent
                    const frame = screenEl.closest('.screen-frame');
                    if (frame) {{
                        frame.style.transform = 'none';
                        frame.style.width = '{width}px';
                        frame.style.height = '{height}px';
                    }}

                    // Return the outer HTML
                    return screenEl.outerHTML;
                }}''')

                if screen_inner_html:
                    # Create a new page with just this screen
                    single_page = browser.new_page(viewport={'width': width, 'height': height})
                    full_html = create_single_screen_html(screen_inner_html, width, height)
                    single_page.set_content(full_html)
                    single_page.wait_for_load_state('networkidle')
                    single_page.wait_for_timeout(1000)  # Wait for images

                    # Take screenshot
                    single_page.screenshot(path=str(output_path))
                    single_page.close()
                    print(f"  -> Saved: {filename}")
                else:
                    print(f"  -> Error: Could not find screen element")

            except Exception as e:
                print(f"  -> Error: {e}")

            page.close()

        browser.close()

    print(f"\nDone! Exported to: {output_dir}")

if __name__ == "__main__":
    main()
