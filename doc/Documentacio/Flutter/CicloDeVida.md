# Flutter

## Inicio

El usuario debe insertar su correo y contraseña, si no tiene una cuenta debe pulsar `Registra't`.

## Registro

Al pulsar el boton se te redirige a **Odoo**, concretamente al apartado web donde crear un usuario

Al crearlo ya puedes volver a la aplicacion.

## Inicio Session

En el momento de iniciar session se hace una peticion a un endpoint de **Odoo**, el cual nos devuelve un token con informacion del usuario
en ese  momento se guarda un `usuario` en un **provider** con los datos recibidos del token.

A continuacion se cargan las 3 paginas principales

### Home

Se hace un `GET` al catalogo para recibir sus videos, los cuales se ordenan dentro de las series y por categorias.

Se puede hacer scroll lateral en el carrousel

### Listas

Aqui se muestran las listas creadas por los usuarios con sus correspondientes videos

Hay un boton arriba para refrescar las listas, este al ser pulsado vuelve a cargar las listas para mostrar los cambios.

### Perfil

Aqui solamente se muestra el boton para cerrar sesion.

(futuras mejoras)

- Configuracion de los usuarios
- Creacion de perfiles

## Series

Al pulsar una serie se muestra informacion detallada del primer video de esta

### Reproducir

Al pulsar el boton `Reproducir` se accede al **Media server** pasandole un token y el id del video, este verifica la validez del token, si eres admin o tienes suscripcion y te devuelve el vide el qual reproduces.

### lista

Abajo aparece una lista con todos los videos de la serie, ordenados por temporada y capitulo

## Busqueda

Aqui se puede buscar por series.

Aparecen todas las series al principio y al buscar solo aparecen las que coinciden con la busqueda.
