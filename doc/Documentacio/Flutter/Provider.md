# Provider

El provider se utiliza para poder acceder desde qualquier ventana/widget al usuario que ha iniciado sesion,

Mediante su uso podemos modificar campos automaticamente al modificar parametros del provider.

## Refresh token

Utilizando al provider establecemos un tiempo para que controle lo que queda para que se caduque el token del usuario, de esta manera cuando falta poco tiempo hace una peticion a **Odoo** para refrescar el token, el cual actualizamos en el provider y toda la app pasa a tener el nuevo token.
