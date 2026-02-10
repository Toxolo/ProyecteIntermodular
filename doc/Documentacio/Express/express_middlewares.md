# Middlewares del Express en Padalustro
Estos son los tres middlewares que tenemos im`plementados en el express:

---

## 1. Middleware de procesamiento de metadata (extractMetadata)

Este middleware se encarga de **extraer la información técnica del vídeo**.

### Funcionamiento:

1. Le llega la petición que ya contiene el vídeo validado.
2. Analiza el vídeo.
3. Extrae información como:
   - Duración del vídeo.
   - Códec utilizado.
   - Resolución.
4. Guarda esta información dentro de la propia petición.
5. Permite que los siguientes middlewares y el controlador accedan a estos datos **sin volver a procesar el vídeo**.
6. Si ocurre un error durante la extracción:
   Se detiene el flujo y devuelve un mensaje de error.

Este middleware evita reprocesamientos y centraliza la obtención de datos técnicos del vídeo.

---

## 2. Middleware de generación de miniatura (extractThumbnail)

Este middleware se encarga de **generar la miniatura asociada a cada vídeo**.

### Funcionamiento:

1. Recibe la petición con el vídeo y su metadata ya disponible.
2. Selecciona un punto representativo del vídeo (en este caso en el segundo 3).
3. Genera una imagen que servirá como miniatura.
4. Guarda la miniatura en la ubicación correspondiente (la misma ruta que el video solo que cambiando el nombre).
5. Asocia la ruta de la miniatura a la petición.
6. Deja la petición lista para que el controlador finalice el proceso.

La miniatura generada es la que se utilizará posteriormente en el catálogo para mostrar el vídeo.

---

## 3. Middleware de validación de acceso (verifyToken)

Este middleware se encarga de **proteger el acceso a los vídeos solicitados por el catálogo**.

### Funcionamiento paso a paso:

1. Intercepta la petición enviada por el catálogo.
2. Comprueba que la petición incluye un token de autenticación.
3. Valida que el token sea correcto y no esté caducado.
4. Verifica que el catálogo tenga permiso para acceder al vídeo solicitado.
5. Si el token no es válido o no existe:
   La petición se detiene y el Express responde con un mensaje de error:
   - Error usuario sin subscripción
   - Token no proporcionado
   - Token invalido
6. Si el token es válido la petición continúa su flujo normal y se permite el acceso a la ruta protegida.

Este middleware garantiza que solo el catálogo autorizado pueda acceder a los vídeos.
