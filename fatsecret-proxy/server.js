const express = require('express');
const axios = require('axios');

const app = express();
app.use(express.json());

// --- Config (set these as environment variables on Render/Railway) ---
const CLIENT_ID = process.env.FATSECRET_CLIENT_ID;
const CLIENT_SECRET = process.env.FATSECRET_CLIENT_SECRET;
const TOKEN_URL = 'https://oauth.fatsecret.com/connect/token';
const API_URL = 'https://platform.fatsecret.com/rest/server.api';

// --- Token cache (in-memory, resets on server restart) ---
let cachedToken = null;
let tokenExpiry = null;

async function getAccessToken() {
  const now = Date.now();
  if (cachedToken && tokenExpiry && now < tokenExpiry - 60000) {
    return cachedToken;
  }

  if (!CLIENT_ID || !CLIENT_SECRET) {
    throw new Error('FATSECRET_CLIENT_ID and FATSECRET_CLIENT_SECRET env vars are not set');
  }

  console.log('[Proxy] Fetching new OAuth2 token...');
  const credentials = Buffer.from(`${CLIENT_ID}:${CLIENT_SECRET}`).toString('base64');

  const response = await axios.post(TOKEN_URL, 'grant_type=client_credentials', {
    headers: {
      Authorization: `Basic ${credentials}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
  });

  cachedToken = response.data.access_token;
  const expiresIn = response.data.expires_in || 3600;
  tokenExpiry = now + expiresIn * 1000;
  console.log(`[Proxy] Token acquired, expires in ${expiresIn}s`);
  return cachedToken;
}

async function fatSecretCall(params) {
  const token = await getAccessToken();
  const response = await axios.get(API_URL, {
    params: { format: 'json', ...params },
    headers: { Authorization: `Bearer ${token}` },
    timeout: 15000,
  });
  if (response.data && response.data.error) {
    throw new Error(`FatSecret error: ${JSON.stringify(response.data.error)}`);
  }
  return response.data;
}

// ─── CORS: allow requests from any origin (mobile apps) ─────────────────────
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  next();
});

// ─── Health check ────────────────────────────────────────────────────────────
app.get('/health', (req, res) => res.json({ status: 'ok', timestamp: new Date().toISOString() }));

// ─── Search foods ─────────────────────────────────────────────────────────────
// GET /api/foods/search?q=chicken&max=10&page=0
app.get('/api/foods/search', async (req, res) => {
  const { q, max = 10, page = 0 } = req.query;
  if (!q) return res.status(400).json({ error: 'Missing query param: q' });

  console.log(`[Proxy] Search: "${q}"`);
  try {
    const data = await fatSecretCall({
      method: 'foods.search.v3',
      search_expression: q,
      max_results: max,
      page_number: page,
    });
    res.json(data);
  } catch (err) {
    console.error('[Proxy] Search error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ─── Autocomplete ─────────────────────────────────────────────────────────────
// GET /api/foods/autocomplete?q=app&max=8
app.get('/api/foods/autocomplete', async (req, res) => {
  const { q, max = 8 } = req.query;
  if (!q) return res.status(400).json({ error: 'Missing query param: q' });

  console.log(`[Proxy] Autocomplete: "${q}"`);
  try {
    const data = await fatSecretCall({
      method: 'foods.autocomplete.v2',
      expression: q,
      max_results: max,
    });
    res.json(data);
  } catch (err) {
    console.error('[Proxy] Autocomplete error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ─── Get food details ─────────────────────────────────────────────────────────
// GET /api/foods/:id
app.get('/api/foods/:id', async (req, res) => {
  const { id } = req.params;
  console.log(`[Proxy] Get food: ${id}`);
  try {
    const data = await fatSecretCall({ method: 'food.get.v4', food_id: id });
    res.json(data);
  } catch (err) {
    console.error('[Proxy] Detail error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ─── Autocomplete ─────────────────────────────────────────────────────────────


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`[Proxy] FatSecret proxy running on port ${PORT}`));
