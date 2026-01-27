#!/usr/bin/env python3
"""
Export Trippified screens as PNG files.
Creates individual HTML pages for each screen and screenshots them with Playwright.
"""

import json
import os
import re
from pathlib import Path
from playwright.sync_api import sync_playwright

def sanitize_filename(name: str, index: int) -> str:
    """Convert screen name to valid filename."""
    # Remove leading numbers and dots
    name = re.sub(r'^\d+\.\s*', '', name)
    # Replace special characters
    name = re.sub(r'[^\w\s-]', '', name)
    # Replace spaces with hyphens
    name = re.sub(r'\s+', '-', name)
    return f"{index:02d}-{name.lower().strip('-')}"

def main():
    base_dir = Path("/Users/jonmac/Documents/Projects/Trippified/design-exports")
    output_dir = base_dir / "png-exports"
    output_dir.mkdir(exist_ok=True)

    # Load index
    with open(base_dir / "index.json") as f:
        index = json.load(f)

    screens = index["screens"]

    # Read preview.html
    with open(base_dir / "preview.html", "r", encoding="utf-8") as f:
        preview_content = f.read()

    print(f"Exporting {len(screens)} screens...")

    with sync_playwright() as p:
        # Launch browser
        browser = p.chromium.launch()

        for i, screen in enumerate(screens):
            screen_name = screen["name"]
            screen_index = screen["index"]
            width = screen.get("width", 390)
            height = screen.get("height", 844)

            if screen_name == "itinPreviewContent":
                print(f"Skipping content frame: {screen_name}")
                continue

            filename = f"{sanitize_filename(screen_name, screen_index)}.png"
            output_path = output_dir / filename

            print(f"[{i+1}/{len(screens)}] {screen_name}")

            try:
                # Create page with screen dimensions
                page = browser.new_page(
                    viewport={'width': width + 100, 'height': height + 100}
                )

                # Load preview page
                page.goto(f"file://{base_dir}/preview.html")
                page.wait_for_load_state("networkidle")

                # Wait for fonts and images
                page.wait_for_timeout(2000)

                # Find and isolate the screen, remove scale transform
                page.evaluate(f'''() => {{
                    // Hide all other screens
                    const containers = document.querySelectorAll('.screen-container');
                    containers.forEach((c, idx) => {{
                        if (idx !== {i}) {{
                            c.style.display = 'none';
                        }}
                    }});

                    // Get our screen
                    const container = containers[{i}];
                    if (container) {{
                        // Remove the grid layout
                        const screensDiv = document.querySelector('.screens');
                        if (screensDiv) {{
                            screensDiv.style.display = 'block';
                            screensDiv.style.padding = '0';
                        }}

                        // Remove container styling
                        container.style.background = 'none';
                        container.style.padding = '0';
                        container.style.margin = '0';
                        container.style.borderRadius = '0';

                        // Hide the title
                        const title = container.querySelector('.screen-title');
                        if (title) title.style.display = 'none';

                        const info = container.querySelector('.screen-info');
                        if (info) info.style.display = 'none';

                        // Get the frame and wrapper
                        const wrapper = container.querySelector('.screen-wrapper');
                        const frame = container.querySelector('.screen-frame');

                        if (wrapper) {{
                            wrapper.style.height = 'auto';
                            wrapper.style.overflow = 'visible';
                        }}

                        if (frame) {{
                            // Remove the scale transform
                            frame.style.transform = 'none';
                            frame.style.height = 'auto';
                        }}
                    }}

                    // Clean up page styling
                    document.body.style.padding = '0';
                    document.body.style.margin = '0';
                    document.body.style.background = 'transparent';
                    document.querySelector('h1').style.display = 'none';
                    document.querySelector('.subtitle').style.display = 'none';
                }}''')

                # Wait a bit more for reflow
                page.wait_for_timeout(500)

                # Find the actual screen div and screenshot it
                screen_selector = f".screen-container:nth-child({i + 1}) .screen-frame > div"
                screen_element = page.locator(screen_selector).first

                if screen_element:
                    screen_element.screenshot(path=str(output_path))
                    print(f"  -> Saved: {filename}")
                else:
                    print(f"  -> Error: Screen element not found")

                page.close()

            except Exception as e:
                print(f"  -> Error: {e}")

        browser.close()

    print(f"\nDone! Exported to: {output_dir}")

if __name__ == "__main__":
    main()
