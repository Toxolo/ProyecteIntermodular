// src/services/TokenUserID.ts
import jwt_decode from "jwt-decode";
import { getRefreshToken } from '../utils/auth';

/* Interfaces */
interface TokenPayload {
  user_id: number;
  exp: number;
  [key: string]: any;
}

interface RefreshResponse {
  jsonrpc: string;
  id: number | null;
  result: {
    access_token: string;
  };
}

/**
 * getUserIdFromToken: Extreu el user_id d'un JWT
 */
function getUserIdFromToken(token: string): number | null {
  try {
    const decoded = jwt_decode<TokenPayload>(token);
    return decoded.user_id || null;
  } catch (e) {
    console.error("Error decoding token:", e);
    return null;
  }
}

/**
 * getUserIdFromRefreshToken: Retorna el user_id del refresh token guardat
 */
export function getUserIdFromRefreshToken(): number | null {
  const refreshToken = getRefreshToken();
  if (!refreshToken) return null;
  return getUserIdFromToken(refreshToken);
}

/**
 * refreshAccessToken: Fa POST a Odoo per obtenir un nou access token
 */
export async function refreshAccessToken(): Promise<string | null> {
  const refreshToken = getRefreshToken();
  if (!refreshToken) {
    console.error("No hi ha refresh token");
    return null;
  }

  const userId = getUserIdFromToken(refreshToken);
  if (!userId) {
    console.error("No s'ha pogut obtenir user_id del token");
    return null;
  }

  const API_BASE = import.meta.env.DEV ? "/api" : "http://localhost:8069";

  try {
    const response = await fetch(`${API_BASE}/update/access-token`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
      body: JSON.stringify({
        jsonrpc: "2.0",
        method: "call",
        params: {
          user_id: userId,
          refresh_token: refreshToken
        },
        id: null
      })
    });

    if (!response.ok) {
      console.error("Error HTTP refrescant token:", response.status, response.statusText);
      return null;
    }

    const data = await response.json();

    if (!data.result?.access_token) {
      console.error("Resposta invàlida del servidor:", data);
      return null;
    }

    // Guardar cookie amb nou token
    document.cookie = `token=${data.result.access_token}; path=/; max-age=3600`;

    return data.result.access_token;

  } catch (err) {
    console.error("Error de connexió al refrescar token:", err);
    return null;
  }
}


/**
 * getValidAccessToken: Retorna un access token vàlid,
 * refrescant-lo automàticament si ha caducat.
 */
export async function getValidAccessToken(): Promise<string | null> {
  const match = document.cookie.match(/(^| )token=([^;]+)/);
  let token = match ? match[2] : null;

  if (!token) {
    console.log("No hi ha token, provem de refrescar...");
    return await refreshAccessToken();
  }

  try {
    const payload = jwt_decode<TokenPayload>(token);
    const now = Math.floor(Date.now() / 1000);

    // Si el token ha caducat o caduca en menys de 1 minut
    if (payload.exp && payload.exp - now < 60) {
      console.log("Token caducat o pròxim a caducar, refrescant...");
      return await refreshAccessToken();
    }

    return token;
  } catch {
    console.log("Token invàlid, refrescant...");
    return await refreshAccessToken();
  }
}
