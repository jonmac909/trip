#!/usr/bin/env node
/**
 * Export Trippified screens as PNG using Pencil MCP server
 */

const WebSocket = require('ws');
const fs = require('fs');
const path = require('path');

const WS_PORT = 61251;
const PEN_FILE = '/Users/jonmac/Documents/Projects/Trippified/Trippified_12.pen';
const OUTPUT_DIR = '/Users/jonmac/Documents/Projects/Trippified/design-exports/png-exports';

// Screen IDs and names from the .pen file
const SCREENS = [
  { id: 'EBVXQ', name: '01-splash-screen' },
  { id: 'Jgwld', name: '02-login-screen' },
  { id: '7XXBb', name: '03-trips-1-home' },
  { id: 'IF7R0', name: '04-trips-1-home-empty' },
  { id: 'Icr58', name: '05-trips-2-wishlist' },
  { id: 'mMM3r', name: '06-trips-3-drafts-empty' },
  { id: 'KEPq6', name: '07-trips-3-trip-setup' },
  { id: 'rfkvI', name: '08-trips-4a-routes-japan' },
  { id: 'r8utq', name: '09-trips-4b-routes-vietnam' },
  { id: 'QNXEv', name: '10-trips-5-itinerary-blocks' },
  { id: 'sZNhc', name: '11-trips-5a-trip-dashboard-japan' },
  { id: 'nysiF', name: '12-trips-5b-trip-dashboard-vietnam' },
  { id: 'aYlBy', name: '13-trips-5b-itinerary-blocks-scrolled' },
  { id: 'X0NAF', name: '14-trips-5c-trip-dashboard-europe' },
  { id: 'z4jKQ', name: '15-trips-5d-trip-dashboard-with-checklist' },
  { id: 'wX10A', name: '16-trips-5e-trip-checklist-scrolled' },
  { id: 'zoZU9', name: '17-trips-6a-day-builder-auto-fill' },
  { id: 'HYZHW', name: '18-trips-6a-day-builder-hanoi-auto-fill' },
  { id: 'MMxS5', name: '19-trips-6b-generate-day-modal' },
  { id: 'HorxA', name: '20-trips-6b-generate-day-modal-hanoi' },
  { id: 'rtOTV', name: '21-trips-6c-day-builder-after-generate' },
  { id: 'EW97m', name: '22-trips-6c-day-builder-hanoi-after-generate' },
  { id: 'kSziY', name: '23-trips-7-day-builder-itinerary' },
  { id: 'mghvs', name: '24-trips-7b-day-builder-hanoi-itinerary' },
  { id: 'DiXm2', name: '25-trips-7c-day-builder-with-flight-ticket' },
  { id: 'Ra26M', name: '26-trips-7d-day-builder-with-hotel-ticket' },
  { id: 'Z7j1Q', name: '27-trips-8a-smart-tickets-tokyo' },
  { id: 'o542N', name: '28-trips-8b-smart-tickets-hanoi' },
  { id: '6nldY', name: '29-trips-9a-place-detail-modal' },
  { id: 'kQujn', name: '30-trips-9b-place-detail-modal-book' },
  { id: '6jJDx', name: '31-explore-1a-home-destinations' },
  { id: 'WFIE5', name: '32-explore-1b-home-itineraries' },
  { id: 'SFfBe', name: '33-explore-1c-home-itineraries-scrolled' },
  { id: 'JjcPO', name: '34-explore-1d-see-all-history' },
  { id: 'CM9ke', name: '35-explore-2a-destination-overview' },
  { id: 'mOyRk', name: '36-explore-2a-2-destination-overview-scrolled' },
  { id: 'OS8Gd', name: '37-explore-2b-destination-cities-map' },
  { id: 'gt5l6', name: '38-explore-2b-2-destination-cities-list' },
  { id: '1YwP2', name: '39-explore-2c-destination-itineraries' },
  { id: 'MhgBv', name: '40-explore-2d-destination-history' },
  { id: 'Evuq2', name: '41-explore-2d-2-destination-history-scrolled' },
  { id: 'VRznc', name: '42-explore-3-itinerary-preview' },
  { id: 'W8L7K', name: '43-explore-4-city-detail' },
  { id: 'mh9Gu', name: '44-explore-4b-city-things-to-do' },
  { id: 'sWrC7', name: '45-explore-4c-city-itineraries' },
  { id: 'toyuq', name: '46-explore-4d-city-place-detail-sheet' },
  { id: 'E8zkg', name: '47-explore-5a-itinerary-preview-single-city' },
  { id: '0O0XQ', name: '48-explore-5b-itinerary-preview-multi-city' },
  { id: 'iHu0t', name: '49-saved-1-empty-state' },
  { id: 'sR25O', name: '50-saved-1b-tiktok-scan-results' },
  { id: 'hJ74D', name: '51-saved-2-home' },
  { id: 'BQt0Q', name: '52-saved-3-places-collapsed' },
  { id: 'Z26rI', name: '53-saved-3b-itineraries' },
  { id: 'wtjyU', name: '54-saved-4-links' },
  { id: 'Wpkcr', name: '55-saved-5-city-detail' },
  { id: 'KNANz', name: '56-saved-6-customize-itinerary' },
  { id: 'e1AVb', name: '57-saved-7-review-route' },
  { id: 'un9Ly', name: '58-saved-8-day-builder' },
  { id: 'Rtpbz', name: '59-saved-9-itineraries-new-added' },
  { id: '4IxxB', name: '60-saved-10-trip-hub-drafts' },
  { id: 'TzDWQ', name: '61-profile-1-home' },
  { id: 'cSrH8', name: '62-profile-2-my-tickets' },
  { id: 'HnXuh', name: '63-profile-2b-import-ticket-modal' },
  { id: 'BMGXc', name: '64-feature-3-itinerary-stacking' },
  { id: '8c7vl', name: '65-feature-4-day-builder-detail' },
  { id: 'Qv6UP', name: '66-feature-6-itinerary-detail' },
  { id: '3PuGi', name: '67-feature-7-add-itinerary' },
];

let msgId = 1;

function createRequest(method, params) {
  return JSON.stringify({
    jsonrpc: '2.0',
    id: msgId++,
    method,
    params
  });
}

async function exportScreenshots() {
  console.log(`Connecting to Pencil MCP server on port ${WS_PORT}...`);

  const ws = new WebSocket(`ws://127.0.0.1:${WS_PORT}`);

  return new Promise((resolve, reject) => {
    const pendingRequests = new Map();
    let currentIndex = 0;

    ws.on('open', () => {
      console.log('Connected to Pencil MCP server');
      console.log(`Exporting ${SCREENS.length} screens...`);
      requestNextScreen();
    });

    ws.on('message', (data) => {
      try {
        const response = JSON.parse(data.toString());

        if (response.id && pendingRequests.has(response.id)) {
          const { screen, resolve: reqResolve } = pendingRequests.get(response.id);
          pendingRequests.delete(response.id);

          if (response.result) {
            // Extract base64 image from result
            const result = response.result;
            if (result.content && result.content[0] && result.content[0].data) {
              const imageData = result.content[0].data;
              const outputPath = path.join(OUTPUT_DIR, `${screen.name}.png`);
              fs.writeFileSync(outputPath, Buffer.from(imageData, 'base64'));
              console.log(`[${currentIndex}/${SCREENS.length}] Saved: ${screen.name}.png`);
            } else {
              console.log(`[${currentIndex}/${SCREENS.length}] No image data for: ${screen.name}`);
            }
          } else if (response.error) {
            console.log(`[${currentIndex}/${SCREENS.length}] Error for ${screen.name}: ${response.error.message}`);
          }

          // Request next screen
          requestNextScreen();
        }
      } catch (e) {
        console.error('Error parsing response:', e.message);
      }
    });

    ws.on('error', (err) => {
      console.error('WebSocket error:', err.message);
      reject(err);
    });

    ws.on('close', () => {
      console.log('Connection closed');
      resolve();
    });

    function requestNextScreen() {
      if (currentIndex >= SCREENS.length) {
        console.log('\nExport complete!');
        ws.close();
        return;
      }

      const screen = SCREENS[currentIndex];
      currentIndex++;

      const request = createRequest('tools/call', {
        name: 'get_screenshot',
        arguments: {
          filePath: PEN_FILE,
          nodeId: screen.id
        }
      });

      const id = msgId - 1;
      pendingRequests.set(id, { screen, resolve: () => {} });
      ws.send(request);
    }
  });
}

// Ensure output directory exists
if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

exportScreenshots()
  .then(() => {
    console.log(`\nScreenshots saved to: ${OUTPUT_DIR}`);
    process.exit(0);
  })
  .catch((err) => {
    console.error('Export failed:', err);
    process.exit(1);
  });
