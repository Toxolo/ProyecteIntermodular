# Ciclo de vida del Express en Padalustro

Este Express tiene como función principal es gestionar los vídeos y servir rutas protegidas para su reproducción.
Aquí recibimos las peticiones, validamos el acceso y devolvemos  rutas protegidas.

**Tecnologías usadas:** Node.js, Express.js, Docker, FFmpeg, Multer, WebSockets, JSON Web Tokens (JWT)

---

## 1. Inicio del servidor Express

Primero que todo arrancamos el Express con el docker encendido.

Una vez completado este proceso, Express queda en estado de espera, preparado para recibir peticiones HTTP.

---

## 2. Espera de peticiones

Con el servidor en funcionamiento, Express permanece a la espera de peticiones de:

- La **app Admin**, cuando se suben vídeos.
- El **catálogo**, cuando se solicita la reproducción de un vídeo.

Cada petición entra por una ruta concreta, lo que determina el flujo que seguirá dentro de la aplicación.

---

## 3. Enrutamiento de las peticiones

Cuando llega una petición:

1. Express identifica la ruta solicitada.
2. Se ejecutan los middlewares asociados a esa ruta.
3. Si todo es correcto, la petición se redirige al controlador correspondiente.

Las rutas principales permiten:

- Subir vídeos al sistema.
- Solicitar rutas protegidas para la reproducción de vídeos.

---

## 4. Flujo de subida de vídeos (Admin → Express)

Cuando la **app Admin** envía un vídeo al sistema, el flujo es el siguiente:

1. La petición llega a la ruta destinada a la subida de vídeos.
2. Express identifica que se trata de una petición de subida.
3. Antes de llegar al controlador:
   - Se recibe el archivo de vídeo.
   - Se procesa la metadata asociada en extractmetadata.js.
   - Se genera o extrae la miniatura del vídeo con el extractThumbnail.js.
4. Una vez completado el procesamiento previo, la petición llega al **VideoController**.
5. El controlador finaliza la gestión del vídeo para que quede disponible para el catálogo.

(ACLARACIÓN)Express actúa como intermediario entre Admin y el sistema de almacenamiento de vídeos.

---

## 5. VideoController

Solo cuando los tres middlewares se ejecutan correctamente, la petición llega al **VideoController**.

El **VideoController** es el encargado de procesar los vídeos que envía la app Admin y prepararlos para que puedan ser consumidos posteriormente por el catálogo.

Cuando una petición de subida llega a este controlador, el flujo es el siguiente:

1. El vídeo llega a Express y es recibido completamente en memoria.
   - El archivo no se guarda directamente en disco.

2. El controlador valida que el vídeo exista y que no esté vacío.
   - Si el archivo no es válido, la petición se rechaza con un error.

3. Se prepara un directorio temporal de trabajo.
   - Este directorio ya ha sido creado previamente por un middleware.
   - Aquí se guardarán los archivos temporales necesarios para el procesamiento.

4. El vídeo recibido en memoria se guarda de forma temporal.
   - Este archivo temporal sirve como base para los siguientes pasos.
   - No es el archivo final que se usará para la reproducción.

5. Se genera una versión corregida del vídeo.
   - Se crea una versión optimizada del archivo para evitar problemas de reproducción.
   - Este paso asegura que el vídeo sea compatible con streaming.

6. El controlador convierte el vídeo a formato HLS.
   - Se divide el vídeo en pequeños fragmentos.
   - Se genera una playlist que permite la reproducción progresiva.
   - Este formato es el que utilizará el catálogo para reproducir el contenido.

7. Durante todo el proceso, se envían actualizaciones de progreso.
   - Estas actualizaciones permiten a la app Admin saber en qué punto está el procesamiento.
   - También se notifican errores si algo falla.

8. Una vez finalizado el procesamiento:
   - Se eliminan los archivos temporales utilizados.

9. El controlador genera la ruta final del vídeo procesado.
   - Esta ruta apunta al archivo HLS principal.
   - Es la ruta que después se devolverá al catálogo cuando solicite el vídeo.

10. Finalmente, se responde a la app Admin:
    - Confirmando que el vídeo se ha procesado correctamente.
    - Devolviendo el identificador del vídeo.
    - Incluyendo la ruta del vídeo procesado y la miniatura asociada.

### getVideoById

Aqui es donde se controla que al intentar recibir un video desde la app del cliente verifique que se tiene un token valido, lo que significa que el usuario esta "logueado".

1. Recibe el id del video que quiere reproducir el usuario
2. Comprueba que haya id y que el video existe
3. Si todo se cumple devuelve el index para reproducir el video.

(NOTA): aqui solo se puede acceder despues de verificar el token entonces que no nos tenemos que preocupar de que el usuario tenga cuenta o no.

---

## 6. Flujo de solicitud de reproducción (Catálogo → Express)

Cuando el **catálogo** necesita reproducir un vídeo, se sigue este flujo:

1. El catálogo envía una petición indicando el identificador del vídeo.
2. La petición pasa primero por el middleware **verifyToken**.
3. `verifyToken` comprueba:
   - Que el token enviado es válido.
   - Que el catálogo tiene permiso para acceder al video.
4. Si el token no es válido:
   - Express responde con un mensaje de error (dependiendo del error un mensaje u otro).
5. Si el token es válido:
   - La petición continúa hasta el controlador.
   - Se devuelve al catálogo la ruta protegida del vídeo.

El vídeo no se envía directamente, solo se proporciona una ruta segura para su reproducción.

---
