import axios from 'axios'
import { getToken } from '../utils/auth'

const api = axios.create({
  baseURL: 'http://localhost:8090'
})

// Interceptor de request
api.interceptors.request.use(config => {
  const token = getToken()
  if (token) {
    // Aquí usamos la función oficial de Axios para asegurarnos de que headers es AxiosHeaders
    config.headers = config.headers ?? {} // si headers es undefined, lo inicializamos
    if ('set' in config.headers) {
      // Si ya es AxiosHeaders
      config.headers.set('Authorization', `Bearer ${token}`)
    } else {
      // Si es objeto literal
      (config.headers as Record<string, string>)['Authorization'] = `Bearer ${token}`
    }
  }
  return config
})

export default api
