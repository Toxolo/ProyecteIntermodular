
# Servidor de ODOO

## Levantar odoo desde cero

1. Ejecuta el comando `docker compose build --no-cache` en la carpeta /docker situada en la raiz del proyecto.
2. Ejecuta el comando `docker compose up -d`
3. Accede a Odoo: `http://localhost:8069`
4. Ve a "Manage Databases"
5. Selecciona "Restore Database"
6. Sube el archivo de backup
7. Ingresa:
   - Nombre de la base de datos
   - Master password (proporcionada por el admin)


## Levantar odoo ( ya base de datos )

1. Ejecuta el comando `docker compose up -d` en la carpeta /docker situada en la raiz del proyecto.
2. Accede a Odoo: `http://localhost:8069`
2. Introduce el correo del admin
3. Introduce el password del admin
4. Pulsa en Iniciar sesión

## Funcionalidades 

La pagina de odoo dispone de un entorno de pagina web al cual puedes acceder entrando en la url `http://localhost:8069`, en el cual se puede crear usuarios portables ( de usuarios que no tienen acceso a la pagina de odoo, solo a la web), en el caso de que quieras entrar en la configuración de odoo solo deberas registrarte con las credenciales de administrador y se abre automaticamente. 

Adema de esto odoo dispone de:

- **Pasarela de pago**: Entorno de pago el cual esta adaptado a la apariencia que se suele ver en las plataformas de streaming en el cual no existe el carrito. Te lleva directamente a pagar. 
- **Metodos de pago**:  Diversos metodos de pago como Paypal, Targeta de credito y Transferecia bancaria. Junto con codigos promocionales y descuentos por temporada.
- **Modelos de suscripciones**: Dispone de 3 modelos de suscripciones los cuales se situan desde el mes, hasta el año pasando por los tres meses.
- **Visualizador de suscripciones personales**: El cliente podrá visualizar las suscripciones activas y las expiradas desde el apartado de "Mis suscripciones" situado en el area de "Mi cuenta".
- **Visualizador de suscripciones generales**: El administrador dispone de un apartado de todas las suscripciones activas y expiradas situado en la configuración de odoo.
- **Descompresor de modulos de Odoo**: Al realizar el `docker compose build --no-cache` se descomprimen los modulos y se situan en la carpeta extra-addons automaticamente en el caso de no tenerlos.
- **Creación de fichero odoo.conf**: Al realizar el `docker compose build --no-cache` se crea el fichero odoo.conf automaticamente con el contenido y la configuración de odoo.
- **Creación de carpetas esenciales de ODOO**: Al realizar el `docker compose build --no-cache` se crea la estructura de carpetas esenciales para ODOO. 


## Modulos de ODOO

### Gestión de Suscripciones con Temporizador

Este módulo permite la creación y gestión automática de suscripciones de clientes basadas en productos comprados mediante pedidos de venta.

#### Funcionalidades Principales

- **Automatización**: Creación automática de suscripciones al confirmar un `Sale Order`.
- **Configuración de Productos**: Campos en la plantilla de producto para marcar si es una suscripción y definir su duración en días.
- **Seguimiento en Tiempo Real**: 
  - Cálculo automático de fecha de fin.
  - Contador de días restantes.
  - Barra de progreso visual según el tiempo transcurrido.
- **Gestión de Expiración**: Proceso automático (Cron) que marca las suscripciones como expiradas al llegar a la fecha límite.
- **Integración con Portal**: (Opcional) Permite a los clientes visualizar sus suscripciones activas.


### JWT (JSON Web Token)

Este módulo implementa un sistema de autenticación basado en **JSON Web Tokens (JWT)** para la API de Odoo.

#### Funcionalidades Principales

- **Autenticación sin estado**: Utiliza tokens para validar la identidad del usuario sin depender de sesiones de servidor tradicionales.
- **RS256**: Generación de firmas criptográficas robustas utilizando claves asimétricas (PEM).
- **Control de Tokens**:
  - **Access Tokens**: Tokens de corta duración (60s) para acceso inmediato.
  - **Refresh Tokens**: Tokens de larga duración (1h) almacenados en base de datos para renovación de sesiones.
- **Integración Nativa**: Sobrescribe `ir.http` para permitir el método de autenticación `auth='jwt'`.

#### Endpoints API

- `/api/authenticate`: Inicio de sesión y entrega de tokens.
  - **Tipo de petición**: POST
  - **Url**: /api/authenticate
  - **Body**:
```
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {
    "db":"Padalustro",
    "login":"correo",
    "password":"password"
  },
  "id": 1
}
```
- **Retorno**:
```
{"jsonrpc": "2.0", 
"id": 1, 
"result": {"
access_token": "access_tocken", 
"refresh_token": "refresh_token"
}}
```
- `/api/update/access-token`: Renovación de access token.
  - **Tipo de petición**: POST
  - **Url**: /api/update/access-token
  - **Body**:
```
{
    "params": {
        "user_id": 11,
        "refresh_token": "refresh_token"
    }
}
```
- **Retorno**:
```
{"jsonrpc": "2.0", 
"id": null, 
"result": {
  "access_token": "access_tocken"
  }}
```
- `/api/revoke/token`: Cierre de sesión (revocación).
  - **Tipo de petición**: POST
  - **Url**: /api/revoke/token
  - **Body**:
```
{
    "params": {
        "refresh_token": "refresh_token"
    }
}
```
  - **Headers**: Authorization : Bearer + acces_Token
  - **Retorno**:
```
{"jsonrpc": "2.0", 
"id": null, 
"result": {
  "status": "success", 
  "logged_out": 1
  }}
```
