const jwt = require('jsonwebtoken');
const fs = require('fs');

// Configuration - UPDATE TEAM_ID
const TEAM_ID = process.argv[2] || 'YOUR_TEAM_ID';
const KEY_ID = '2NSMX53QN3';
const CLIENT_ID = 'com.jonmac.trippified';
const PRIVATE_KEY_PATH = '/Users/jonmac/Documents/AuthKey_2NSMX53QN3.p8';

// Read private key
const privateKey = fs.readFileSync(PRIVATE_KEY_PATH, 'utf8');

// Generate JWT valid for 6 months (maximum allowed by Apple)
const now = Math.floor(Date.now() / 1000);
const expiry = now + (86400 * 180); // 180 days

const token = jwt.sign(
  {
    iss: TEAM_ID,
    iat: now,
    exp: expiry,
    aud: 'https://appleid.apple.com',
    sub: CLIENT_ID,
  },
  privateKey,
  {
    algorithm: 'ES256',
    keyid: KEY_ID,
  }
);

console.log('\n=== Apple Client Secret JWT ===\n');
console.log(token);
console.log('\n=== Copy the above JWT and paste into Supabase ===\n');
console.log('Expires:', new Date(expiry * 1000).toISOString());
