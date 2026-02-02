// src/services/api.ts
import axios from 'axios'
import { getTokenFromCookie } from '../utils/auth'  // Assegura’t que és la funció correcta

const api = axios.create({
  baseURL: 'http://localhost:8090'
})

// Interceptor per afegir el token automàticament
api.interceptors.request.use(config => {
  const token = getTokenFromCookie() // obté token de les cookies
  if (token) {
    config.headers = config.headers ?? {}
    if ('set' in config.headers) {
      // Si ja és AxiosHeaders
      config.headers.set('Authorization', `Bearer ${token}`)
    } else {
      // Si és un object literal
      (config.headers as Record<string, string>)['Authorization'] = `Bearer ${token}`
    }
  }
  return config
})

export default api
