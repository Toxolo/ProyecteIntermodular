from odoo import http
from odoo.http import request
from ..setup.jwt_token import JwtToken
import logging

_logger = logging.getLogger(__name__)


class ApiAuth(http.Controller):
    """
    Controlador principal para la gestión de autenticación via API utilizando JWT.
    Proporciona endpoints para inicio de sesión, refresco de tokens y validación de identidad.
    """


    # ¡¡¡¡ Endpoint  de inicio de sesión, (retorna solo token acceso y refresco)(hace falta pasar correo y contraseña )!!!
    
     
    @http.route('/api/authenticate', type='json', auth='none', methods=['POST'], csrf=False)
    def authenticate_post(self, **kwargs):
        """
        Endpoint para autenticar a un usuario y generar un par de tokens (Access y Refresh).
        """
        # Forzar cierre de sesión previo para limpieza total (especialmente en Postman)
        request.session.logout()
        
        # Extraer parámetros - Odoo puede enviarlos de varias formas
        params = {}
        
        # Intentar obtener de jsonrequest primero
        if hasattr(request, 'jsonrequest') and request.jsonrequest:
            params = request.jsonrequest.get('params', request.jsonrequest)
        
        # Si no hay params, intentar desde kwargs
        if not params:
            params = kwargs
        
        login = params.get('login')
        password = params.get('password')
        db_name = params.get('db') or request.db or request.session.db

        if not login or not password:
            return {"error": "Please provide login and password"}

        try:
            # Intento de autenticación estándar en Odoo
            uid = request.session.authenticate(db_name, login, password)
            if not uid:
                return {"error": "Invalid login or password"}
        except Exception as e:
            return {"error": "Authentication failed: %s" % str(e)}

        try:
            user = request.env['res.users'].browse(uid)
            has_subscription = self._user_has_active_subscription(uid)

            # Generar tokens de acceso y refresco
            is_admin = user.has_group('base.group_system')
            access_token = JwtToken.generate_token(uid, extra_payload={
                'user_id': uid,
                'has_subscription': has_subscription,
                'is_admin': is_admin,
                'username': user.name
            })
            refresh_token = JwtToken.create_refresh_token(request, uid)

            res_data = {
                'access_token': access_token,
                'refresh_token': refresh_token
            }

            return res_data

        except Exception as exc:
            return {"error": str(exc)}

    @staticmethod
    def _user_has_active_subscription(uid):
        """
        Verifica si el usuario indicado tiene al menos una suscripción activa.
        """
        user = request.env['res.users'].sudo().browse(uid)
        if not user:
            return False

        has_subscription = bool(
            request.env['subscription.subscription']
            .sudo()
            .search([
                ('partner_id', '=', user.partner_id.id),
                ('state', '=', 'active')
            ], limit=1)
        )
        return has_subscription
   

    # ¡¡¡¡ Endpoint  de refrescar token de acceso, (retorna solo token acceso) (hace falta pasar solo refresh tokens para refrescar)!!! 


    @http.route('/api/update/access-token', type='json', auth='none', methods=['POST'], csrf=False)
    def updated_short_term_token(self, **kwargs):
        """
        Permite obtener un nuevo Access Token utilizando un Refresh Token vigente.
        """
        # Extraer parámetros - compatible con múltiples formatos
        params = {}
        if hasattr(request, 'jsonrequest') and request.jsonrequest:
            params = request.jsonrequest.get('params', request.jsonrequest)
        if not params:
            params = kwargs
        
        user_id = params.get('user_id')
        
        user_id = int(user_id) if user_id else None

        # Obtener refresh token desde cookies, headers o body
        long_term_token = self.get_refresh_token(request)
        
        if not long_term_token:
            return {'error': 'Refresh token not provided'}

        try:
            # Verificar la validez del refresh token
            user_id = JwtToken.verify_refresh_token(request, long_term_token, uid=user_id)
            
            # Obtener datos del usuario para incluir en el nuevo token
            user = request.env['res.users'].sudo().browse(user_id)
            has_subscription = self._user_has_active_subscription(user_id)
            
            # Generar nuevo access token con los mismos datos extra
            is_admin = 4 in user.groups_id.ids
            new_token = JwtToken.generate_token(user_id, extra_payload={
                'has_subscription': has_subscription,
                'is_active': user.active,
                'is_admin': is_admin
            })
            
            return {'access_token': new_token}
        except Exception as e:
            return {'error': str(e)}

    @http.route('/api/update/refresh-token', type='json', auth='jwt', methods=['POST'], csrf=False)
    def updated_long_term_token(self, **kwargs):
        """
        Renueva el Refresh Token actual por uno nuevo. Requiere autenticación JWT.
        """
        # Extraer parámetros - compatible con múltiples formatos
        params = {}
        if hasattr(request, 'jsonrequest') and request.jsonrequest:
            params = request.jsonrequest.get('params', request.jsonrequest)
        if not params:
            params = kwargs
        
        user_id = params.get('user_id')
        if not user_id:
            # Si no viene user_id, usar el del usuario autenticado
            user_id = request.env.user.id
        else:
            user_id = int(user_id)

        old_token = self.get_refresh_token(request)
        
        if not old_token:
            return {'error': 'Refresh token not provided'}

        try:
            user_id = JwtToken.verify_refresh_token(request, old_token, uid=user_id)
            new_token = JwtToken.create_refresh_token(request, user_id)

            res_data = {'status': 'done'}
            user_agent = request.httprequest.user_agent
            is_browser = user_agent.browser if user_agent else False
            
            if not is_browser:
                res_data['refresh_token'] = new_token
            else:
                res_data['refresh_token'] = 1
                if hasattr(request, 'future_response'):
                    request.future_response.set_cookie(
                        'refresh_token', 
                        new_token, 
                        httponly=True, 
                        secure=True, 
                        samesite='Lax'
                    )
            
            return res_data
        except Exception as e:
            return {'error': str(e)}
   

    # ¡¡¡¡ Endpoint  de cierre de sesión, (confirmación de cierre de sessión(success)) (hace falta pasar los dos tokens para cerrar sesión)!!! 


    @http.route('/api/revoke/token', type='json', auth='none', methods=['POST'], csrf=False)
    def revoke_api_token(self, **kwargs):
        """
        Invalida manualmente un Refresh Token (Cierre de sesión).
        """
        # Extraer parámetros - compatible con múltiples formatos
        params = {}
        if hasattr(request, 'jsonrequest') and request.jsonrequest:
            params = request.jsonrequest.get('params', request.jsonrequest)
        if not params:
            params = kwargs
        
        user_id = params.get('user_id')
        if not user_id:
            user_id = request.env.user.id
        else:
            user_id = int(user_id)

        long_term_token = self.get_refresh_token(request)
        
        if not long_term_token:
            return {'error': 'Refresh token not provided'}

        try:
            user_id = JwtToken.verify_refresh_token(request, long_term_token, uid=user_id)
            tok_ob = request.env['jwt.refresh_token'].sudo().search([('user_id', '=', user_id)])
            if tok_ob:
                tok_ob.is_revoked = True
            return {'status': 'success', 'logged_out': 1}
        except Exception as e:
            return {'error': str(e)}


    #¡¡No gastado!! Endpoint  de petición de token protegida. ( no requerida en proyecto debido al cigfrado de los tokens.) !!! 


    @http.route('/api/protected/test', type='json', auth='jwt', methods=['POST'], csrf=False)
    def protected_users_json(self):
        """
        Endpoint de prueba protegido. Retorna datos dummy si el token es válido.
        """
        uob = request.env.user
        users = [{'id': 1, 'name': 'test_user'}]
        user_data = [{'id': user['id'], 'name': user['name']} for user in users]
        return {'uid': uob.id, 'data': user_data}


    #¡¡No gastado!! Endpoint  de petición de información de usuario. ( no requerida en proyecto, info pasada en el token.) !!! 


    @http.route('/api/me', type='json', auth='jwt', methods=['POST'], csrf=False)
    def api_me(self):
        """
        Retorna información del usuario actualmente autenticado.
        """
        uob = request.env.user
        has_subscription = self._user_has_active_subscription(uob.id)
        return {
            'id': uob.id,
            'nom': uob.name,
            'email': uob.login,
            'active': uob.active,
            'has_subscription': has_subscription
        }


    #¡¡No gastado!! Endpoint  de petición de token protegida. ( no requerida en proyecto debido al cigfrado de los tokens.) !!! 


    @http.route('/api/protected/test', type='json', auth='jwt', methods=['POST'], csrf=False)
    def protected_users_json(self):
        """
        Endpoint de prueba protegido (Duplicado para mantener estructura original).
        """
        uob = request.env.user
        users = [{'id': 1, 'name': 'test_user'}]
        user_data = [{'id': user['id'], 'name': user['name']} for user in users]
        return {'uid': uob.id, 'data': user_data}


    #¡¡No gastado!! Endpoint  de petición de información de usuario. ( no requerida en proyecto, info pasada en el token.) !!! 


    @http.route('/api/me', type='json', auth='jwt', methods=['POST'], csrf=False)
    def api_me(self):
        """
        Retorna información del usuario actualmente autenticado (Duplicado para mantener estructura original).
        """
        uob = request.env.user
        has_subscription = self._user_has_active_subscription(uob.id)
        return {
            'id': uob.id,
            'nom': uob.name,
            'email': uob.login,
            'active': uob.active,
            'has_subscription': has_subscription
        }


    #¡¡No gastado!! Endpoint  de refrescado de refresh token.) !!! 


    @classmethod
    def get_refresh_token(cls, req_obj):
        """
        Busca el Refresh Token en cookies, cabeceras o cuerpo de la petición.
        """
        key_name = 'refresh_token'
        http_req = req_obj.httprequest
        token = None
        
        # 1. Intentar desde cookies
        token = http_req.cookies.get(key_name)
        if token: _logger.info("Found token in cookies")
        # 1. Intentar desde cookies
        token = http_req.cookies.get(key_name)
        if token: _logger.info("Found token in cookies")
        
        # 2. Intentar desde headers
        if not token:
            token = http_req.headers.get(key_name) or \
                    http_req.headers.get('Authorization-Refresh') or \
                    http_req.headers.get('refresh-token')
            if token: _logger.info("Found token in headers")
        
        # 3. Intentar desde el body (JSON)
        # Odoo 16: req_obj.jsonrequest suele ser el contenido de "params"
        # 2. Intentar desde headers
        if not token:
            token = http_req.headers.get(key_name) or \
                    http_req.headers.get('Authorization-Refresh') or \
                    http_req.headers.get('refresh-token')
            if token: _logger.info("Found token in headers")
        
        # 3. Intentar desde el body (JSON)
        # Odoo 16: req_obj.jsonrequest suele ser el contenido de "params"
        if not token and hasattr(req_obj, 'jsonrequest') and req_obj.jsonrequest:
            jr = req_obj.jsonrequest
            token = jr.get(key_name) or jr.get('refresh_token')
            
            # Si no está ahí, quizás esté anidado dentro de otro "params" (redundante pero posible en Postman)
            if not token and 'params' in jr:
                token = jr['params'].get(key_name) or jr['params'].get('refresh_token')
            
            if token: _logger.info("Found token in JSON body")
            token = jr.get(key_name) or jr.get('refresh_token')
            
            # Si no está ahí, quizás esté anidado dentro de otro "params" (redundante pero posible en Postman)
            if not token and 'params' in jr:
                token = jr['params'].get(key_name) or jr['params'].get('refresh_token')
            
            if token: _logger.info("Found token in JSON body")

        # 4. Intentar desde request.params (Odoo parseado)
        if not token and hasattr(req_obj, 'params') and req_obj.params:
            token = req_obj.params.get(key_name) or req_obj.params.get('refresh_token')
            if token: _logger.info("Found token in request.params")
        # 4. Intentar desde request.params (Odoo parseado)
        if not token and hasattr(req_obj, 'params') and req_obj.params:
            token = req_obj.params.get(key_name) or req_obj.params.get('refresh_token')
            if token: _logger.info("Found token in request.params")
            
        return token
