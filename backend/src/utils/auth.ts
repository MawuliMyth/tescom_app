import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import crypto from "node:crypto";
import { env } from "../env.js";

export type TokenUser = {
  id: string;
  email: string;
  role: "USER" | "ADMIN" | "SUPER_ADMIN";
};

export type TokenPair = {
  accessToken: string;
  refreshToken: string;
  accessTokenExpiresIn: number;
  refreshTokenExpiresIn: number;
};

const accessTokenExpiresIn = 15 * 60;
const refreshTokenExpiresIn = 30 * 24 * 60 * 60;

export function hashPassword(password: string) {
  return bcrypt.hash(password, 12);
}

export function verifyPassword(password: string, hash: string) {
  return bcrypt.compare(password, hash);
}

export function signAccessToken(user: TokenUser) {
  return jwt.sign(user, env.JWT_SECRET, { expiresIn: accessTokenExpiresIn });
}

export function verifyAccessToken(token: string) {
  return jwt.verify(token, env.JWT_SECRET) as TokenUser;
}

export function createRefreshToken() {
  return crypto.randomBytes(64).toString("base64url");
}

export function hashRefreshToken(token: string) {
  return crypto.createHash("sha256").update(token).digest("hex");
}

export function tokenExpiry(seconds: number) {
  return new Date(Date.now() + seconds * 1000);
}

export function getTokenPair(user: TokenUser, refreshToken: string): TokenPair {
  return {
    accessToken: signAccessToken(user),
    refreshToken,
    accessTokenExpiresIn,
    refreshTokenExpiresIn
  };
}
