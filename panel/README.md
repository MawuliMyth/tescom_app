# TESCON Admin Panel

React admin panel for managing the TESCON backend.

## Setup

1. Copy `.env.example` to `.env`.
2. Set `VITE_API_URL` to the backend URL.
3. Run:

```bash
npm install
npm run dev
```

This folder is standalone and can be moved out of the Flutter project later.

## Vercel

Deploy this folder as a separate Vercel project with the root directory set to
`panel`.

Set:

```env
VITE_API_URL=https://your-backend.vercel.app
```

After the admin project has a final Vercel URL, add that origin to the backend
`CORS_ORIGIN` value.
