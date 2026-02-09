import axios, { AxiosError, InternalAxiosRequestConfig, AxiosHeaders } from 'axios'
import { getValidAccessToken } from './TokenUserID'

const api = axios.create({
  baseURL: 'http://localhost:8090'
})

// Afegim l'access token abans de cada petició
api.interceptors.request.use(async (config: InternalAxiosRequestConfig) => {
  const token = await getValidAccessToken() // aquí obté el token actualitzat

  if (token) {
    const headers = config.headers instanceof AxiosHeaders
      ? config.headers
      : new AxiosHeaders(config.headers)

    headers.set('Authorization', `Bearer ${token}`)
    config.headers = headers
  }

  return config
})

// Interceptor de resposta: només log out si realment és 401 i no tenim token
api.interceptors.response.use(
  response => response,
  async (error: AxiosError) => {
    if (error.response?.status === 401) {
      console.warn("Token invàlid o caducat")
      // opcional: redirigir a login o mostrar missatge
    }
    return Promise.reject(error)
  }
)

export default api
