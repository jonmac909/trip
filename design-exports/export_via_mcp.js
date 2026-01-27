#!/usr/bin/env node
/**
 * Export all Trippified screens as PNG using Pencil MCP server
 */

const { spawn } = require("child_process");
const fs = require("fs");
const path = require("path");

const PEN_FILE = "/Users/jonmac/Documents/Projects/Trippified/Trippified_12.pen";
const OUTPUT_DIR = "/Users/jonmac/Documents/Projects/Trippified/design-exports/png-exports";

// Screen list from screens_to_export.json
const SCREENS = [
  { id: "EBVXQ", name: "01-splash-screen" },
  { id: "Jgwld", name: "02-login-screen" },
  { id: "7XXBb", name: "03-trips-home" },
  { id: "IF7R0", name: "04-trips-home-empty" },
  { id: "Icr58", name: "05-trips-wishlist" },
  { id: "mMM3r", name: "06-trips-drafts-empty" },
  { id: "KEPq6", name: "07-trips-setup" },
  { id: "rfkvI", name: "08-trips-routes-japan" },
  { id: "r8utq", name: "09-trips-routes-vietnam" },
  { id: "QNXEv", name: "10-trips-itinerary-blocks" },
  { id: "sZNhc", name: "11-trips-dashboard-japan" },
  { id: "nysiF", name: "12-trips-dashboard-vietnam" },
  { id: "aYlBy", name: "13-trips-itinerary-scrolled" },
  { id: "X0NAF", name: "14-trips-dashboard-europe" },
  { id: "z4jKQ", name: "15-trips-dashboard-checklist" },
  { id: "wX10A", name: "16-trips-checklist-scrolled" },
  { id: "zoZU9", name: "17-trips-day-builder-autofill" },
  { id: "HYZHW", name: "18-trips-day-builder-hanoi-autofill" },
  { id: "MMxS5", name: "19-trips-generate-day-modal" },
  { id: "HorxA", name: "20-trips-generate-day-modal-hanoi" },
  { id: "rtOTV", name: "21-trips-day-builder-after-generate" },
  { id: "EW97m", name: "22-trips-day-builder-hanoi-after-generate" },
  { id: "kSziY", name: "23-trips-day-builder-itinerary" },
  { id: "mghvs", name: "24-trips-day-builder-hanoi-itinerary" },
  { id: "DiXm2", name: "25-trips-day-builder-flight-ticket" },
  { id: "Ra26M", name: "26-trips-day-builder-hotel-ticket" },
  { id: "Z7j1Q", name: "27-trips-smart-tickets-tokyo" },
  { id: "o542N", name: "28-trips-smart-tickets-hanoi" },
  { id: "6nldY", name: "29-trips-place-detail-modal" },
  { id: "kQujn", name: "30-trips-place-detail-modal-book" },
  { id: "6jJDx", name: "31-explore-home-destinations" },
  { id: "WFIE5", name: "32-explore-home-itineraries" },
  { id: "SFfBe", name: "33-explore-home-itineraries-scrolled" },
  { id: "JjcPO", name: "34-explore-see-all-history" },
  { id: "CM9ke", name: "35-explore-destination-overview" },
  { id: "mOyRk", name: "36-explore-destination-overview-scrolled" },
  { id: "OS8Gd", name: "37-explore-destination-cities-map" },
  { id: "gt5l6", name: "38-explore-destination-cities-list" },
  { id: "1YwP2", name: "39-explore-destination-itineraries" },
  { id: "MhgBv", name: "40-explore-destination-history" },
  { id: "Evuq2", name: "41-explore-destination-history-scrolled" },
  { id: "VRznc", name: "42-explore-itinerary-preview" },
  { id: "W8L7K", name: "43-explore-city-detail" },
  { id: "mh9Gu", name: "44-explore-city-things-to-do" },
  { id: "sWrC7", name: "45-explore-city-itineraries" },
  { id: "toyuq", name: "46-explore-city-place-detail-sheet" },
  { id: "E8zkg", name: "47-explore-itinerary-preview-single-city" },
  { id: "0O0XQ", name: "48-explore-itinerary-preview-multi-city" },
  { id: "iHu0t", name: "49-saved-empty-state" },
  { id: "sR25O", name: "50-saved-tiktok-scan-results" },
  { id: "hJ74D", name: "51-saved-home" },
  { id: "BQt0Q", name: "52-saved-places-collapsed" },
  { id: "Z26rI", name: "53-saved-itineraries" },
  { id: "wtjyU", name: "54-saved-links" },
  { id: "Wpkcr", name: "55-saved-city-detail" },
  { id: "KNANz", name: "56-saved-customize-itinerary" },
  { id: "e1AVb", name: "57-saved-review-route" },
  { id: "un9Ly", name: "58-saved-day-builder" },
  { id: "Rtpbz", name: "59-saved-itineraries-new-added" },
  { id: "4IxxB", name: "60-saved-trip-hub-drafts" },
  { id: "TzDWQ", name: "61-profile-home" },
  { id: "cSrH8", name: "62-profile-my-tickets" },
  { id: "HnXuh", name: "63-profile-import-ticket-modal" },
  { id: "BMGXc", name: "64-feature-itinerary-stacking" },
  { id: "8c7vl", name: "65-feature-day-builder-detail" },
  { id: "Qv6UP", name: "66-feature-itinerary-detail" },
  { id: "3PuGi", name: "67-feature-add-itinerary" },
];

let server;
let buffer = "";
let currentIndex = 0;
let requestId = 0;
let connected = false;

function startServer() {
  return new Promise((resolve, reject) => {
    server = spawn(
      "/Applications/Pencil.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64",
      ["--ws-port", "61251"],
      { stdio: ["pipe", "pipe", "pipe"] }
    );

    server.stderr.on("data", (data) => {
      const text = data.toString();
      if (text.includes("received client ID") && !connected) {
        connected = true;
        console.log("Connected to Pencil app\n");
        resolve();
      }
    });

    server.stdout.on("data", (data) => {
      buffer += data.toString();
      processBuffer();
    });

    server.on("error", reject);

    // Timeout if connection takes too long
    setTimeout(() => {
      if (!connected) reject(new Error("Connection timeout"));
    }, 10000);
  });
}

function processBuffer() {
  const lines = buffer.split("\n");
  buffer = lines.pop();

  for (const line of lines) {
    if (!line.trim()) continue;

    try {
      const response = JSON.parse(line);
      handleResponse(response);
    } catch (e) {
      // Ignore parse errors
    }
  }
}

function handleResponse(response) {
  if (!response.result || !response.result.content) return;

  const imageContent = response.result.content.find(c => c.type === "image");

  if (imageContent && imageContent.data) {
    const screen = SCREENS[currentIndex];
    const filename = `${screen.name}.png`;
    const filepath = path.join(OUTPUT_DIR, filename);

    fs.writeFileSync(filepath, Buffer.from(imageContent.data, "base64"));
    console.log(`[${currentIndex + 1}/${SCREENS.length}] Saved: ${filename}`);

    currentIndex++;
    if (currentIndex < SCREENS.length) {
      // Small delay between requests
      setTimeout(() => requestScreenshot(currentIndex), 200);
    } else {
      console.log("\nExport complete!");
      server.kill();
      process.exit(0);
    }
  } else {
    const textContent = response.result.content.find(c => c.type === "text");
    if (textContent && response.result.isError) {
      console.log(`Error: ${textContent.text}`);
    }
  }
}

function requestScreenshot(index) {
  const screen = SCREENS[index];
  requestId++;

  const request = JSON.stringify({
    jsonrpc: "2.0",
    id: requestId,
    method: "tools/call",
    params: {
      name: "get_screenshot",
      arguments: {
        filePath: PEN_FILE,
        nodeId: screen.id
      }
    }
  }) + "\n";

  server.stdin.write(request);
}

async function main() {
  console.log(`Exporting ${SCREENS.length} screens to PNG...\n`);

  // Ensure output directory exists
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  try {
    await startServer();
    requestScreenshot(0);
  } catch (e) {
    console.error("Failed to start:", e.message);
    process.exit(1);
  }
}

main();
