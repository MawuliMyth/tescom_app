# TESCON Backend

Custom Node.js, Express, Prisma, and PostgreSQL backend for the TESCON app.

## Setup

1. Copy `.env.example` to `.env`.
2. Set `DATABASE_URL` and `JWT_SECRET`.
3. Run:

```bash
npm install
npm run prisma:generate
npm run prisma:migrate
npm run seed
npm run dev
```

The API runs on `http://localhost:4000` by default.

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
