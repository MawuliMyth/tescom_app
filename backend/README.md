# TESCON Backend

Custom Node.js, Express, Prisma, and PostgreSQL backend for the TESCON app.

## Setup

1. Copy `.env.example` to `.env`.
2. Set `DATABASE_URL` and `JWT_SECRET`.
3. Start PostgreSQL. With Docker installed, run:

```bash
docker compose up -d
```

4. Run:

```bash
npm install
npm run prisma:generate
npm run prisma:migrate
npm run seed
npm run dev
```

The API runs on `http://localhost:4000` by default.

## Deployment Notes

The backend can run on Vercel through `api/index.ts`. Deploy it as its own
Vercel project with the root directory set to `backend`.

Production needs:

- `DATABASE_URL` pointing at a hosted PostgreSQL database such as Neon, Supabase, or Vercel-managed Postgres.
- `JWT_SECRET` set to a long random secret.
- `CORS_ORIGIN` set to the deployed admin panel origin.
- `BLOB_READ_WRITE_TOKEN` from Vercel Blob if image uploads should persist in production.
- `ADMIN_EMAIL` and `ADMIN_PASSWORD` for the first super-admin account.

Without `BLOB_READ_WRITE_TOKEN`, local development stores images in `storage/uploads`.
Serverless deployments should use Vercel Blob because local files are not persistent.

After setting the production environment variables, apply migrations to the
hosted database and create the admin user:

```bash
npm run prisma:deploy
npm run admin:create
```

Do not run `npm run seed` in production unless you intentionally want demo
content.

## Main Capabilities

- User registration, login, short-lived JWT access tokens, refresh-token rotation, and logout revocation
- Admin and super-admin roles
- Chapters, member profiles, news, events, announcements, jobs, polls, chat, notifications, saved items, and contact messages
- Admin CRUD endpoints under `/api/admin/*`
- Public app endpoints under `/api/app/*`

Auth responses return:

```json
{
  "user": {},
  "tokens": {
    "accessToken": "jwt",
    "refreshToken": "opaque-refresh-token",
    "accessTokenExpiresIn": 900,
    "refreshTokenExpiresIn": 2592000
  }
}
```

Clients should send `Authorization: Bearer <accessToken>` for protected routes and call `/api/auth/refresh` with the refresh token when the access token expires.

This folder is standalone and can be moved out of the Flutter project later.
