# FatSecret Proxy Server

A lightweight Node.js/Express proxy that sits between your Flutter mobile app and the FatSecret Nutrition API.

## Why this exists
FatSecret only allows up to 15 whitelisted IPs per API key — unusable for a mobile app with millions of different user IPs. This proxy runs on a **single fixed server IP** that gets whitelisted once, and all app traffic routes through it.

## Setup

### 1. Install dependencies
```bash
cd fatsecret-proxy
npm install
```

### 2. Set environment variables
Create a `.env` file (for local dev) or set them in your hosting dashboard:
```
FATSECRET_CLIENT_ID=your_client_id_here
FATSECRET_CLIENT_SECRET=your_client_secret_here
PORT=3000
```

### 3. Run locally
```bash
npm start
```

Test it:
```
GET http://localhost:3000/health
GET http://localhost:3000/api/foods/search?q=chicken
GET http://localhost:3000/api/foods/autocomplete?q=app
GET http://localhost:3000/api/foods/12345
```

---

## Deploy to Render.com (Free)

1. Push `fatsecret-proxy/` to a **GitHub repo** (can be a separate repo or subfolder)
2. Go to [render.com](https://render.com) → **New Web Service**
3. Connect your GitHub repo
4. Settings:
   - **Root Directory:** `fatsecret-proxy` (if it's inside the Flutter project repo)
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Instance type:** Free
5. Add **Environment Variables** in Render dashboard:
   - `FATSECRET_CLIENT_ID` = your client id
   - `FATSECRET_CLIENT_SECRET` = your client secret
6. Deploy → wait ~2 minutes
7. Copy your Render URL (e.g. `https://fatsecret-proxy.onrender.com`)

### 8. Whitelist Render's outbound IP
- In Render dashboard: **Your service → Settings → Outbound IP Addresses**
- Copy the IP(s) shown
- Add them to FatSecret portal under IP Restrictions

### 9. Update Flutter app
Add to your `.env`:
```
FATSECRET_PROXY_URL=https://fatsecret-proxy.onrender.com
```

---

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| GET | `/api/foods/search?q=chicken&max=10&page=0` | Search foods |
| GET | `/api/foods/:id` | Get food details by ID |
| GET | `/api/foods/autocomplete?q=app&max=8` | Autocomplete suggestions |
