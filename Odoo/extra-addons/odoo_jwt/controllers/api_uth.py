from odoo import http
from odoo.http import request
from ..setup.jwt_token import JwtToken
import logging

_logger = logging.getLogger(__name__)


class ApiAuth(http.Controller):

    @http.route('/api/authenticate', type='json', auth='none', methods=['POST'], csrf=False)
    def authenticate_post(self, **kwargs):
        params = {}
        if hasattr(request, 'jsonrequest') and request.jsonrequest:
            params = request.jsonrequest.get('params', request.jsonrequest)
        if not params:
            params = kwargs
        
        login = params.get('login')
        password = params.get('password')
        db_name = params.get('db') or request.db or request.session.db

        if not login or not password:
            return {"error": "Please provide login and password"}

        try:
            uid = request.session.authenticate(db_name, login, password)
            if not uid:
                return {"error": "Invalid login or password"}
        except Exception as e:
            return {"error": "Authentication failed: %s" % str(e)}

        try:
            user = request.env['res.users'].browse(uid)
            has_subscription = self._user_has_active_subscription(uid)

            is_admin = 4 in user.groups_id.ids
            access_token = JwtToken.generate_token(uid, extra_payload={
                'user_id': uid,
                'user_name': user.name,
                'has_subscription': has_subscription,
                'is_admin': is_admin
            })
            refresh_token = JwtToken.create_refresh_token(request, uid)

            _logger.info("=== Simplified AUTH response triggered ===")
            return {
                'access_token': access_token,
                'refresh_token': refresh_token
            }

        except Exception as exc:
            return {"error": str(exc)}

    @staticmethod
    def _user_has_active_subscription(uid):
        user = request.env['res.users'].sudo().browse(uid)
        if not user:
            return False
        return bool(
            request.env['subscription.subscription']
            .sudo()
            .search([
                ('partner_id', '=', user.partner_id.id),
                ('state', '=', 'active')
            ], limit=1)
        )

    @http.route('/api/update/access-token', type='json', auth='none', methods=['POST'], csrf=False)
    def updated_short_term_token(self, **kwargs):
        params = {}
        if hasattr(request, 'jsonrequest') and request.jsonrequest:
            params = request.jsonrequest.get('params', request.jsonrequest)
        if not params:
            params = (request.params if hasattr(request, 'params') else {}) or kwargs
        
        user_id = params.get('user_id')
        if not user_id:
            return {'error': 'User id not given'}
        
        user_id = int(user_id)
        long_term_token = self.get_refresh_token(request)
        
        if not long_term_token:
            return {'error': 'Refresh token not provided'}

        try:
            JwtToken.verify_refresh_token(request, user_id, long_term_token)
            user = request.env['res.users'].sudo().browse(user_id)
            has_subscription = self._user_has_active_subscription(user_id)
            is_admin = 4 in user.groups_id.ids
            new_token = JwtToken.generate_token(user_id, extra_payload={
                'user_name': user.name,
                'has_subscription': has_subscription,
                'is_active': user.active,
                'is_admin': is_admin
            })
            return {'access_token': new_token}
        except Exception as e:
            return {'error': str(e)}

    @classmethod
    def get_refresh_token(cls, req_obj):
        key_name = 'refreshToken'
        http_req = req_obj.httprequest
        token = None
        
        # 1. Intentar desde request.params
        if hasattr(req_obj, 'params') and req_obj.params:
            p = req_obj.params
            token = p.get('refreshToken') or p.get('refresh_token') or p.get(key_name)

        # 2. Intentar desde el JSON body crudo
        if not token and hasattr(req_obj, 'jsonrequest') and req_obj.jsonrequest:
            jr = req_obj.jsonrequest
            token = jr.get('refreshToken') or jr.get('refresh_token') or jr.get(key_name)
            if not token and 'params' in jr:
                token = jr['params'].get('refreshToken') or jr['params'].get('refresh_token')

        # 3. Intentar desde headers
        if not token:
            token = http_req.headers.get('Authorization-Refresh') or \
                    http_req.headers.get('refreshToken') or \
                    http_req.headers.get('refresh-token')
        
        # 4. Intentar desde cookies
        if not token:
            token = http_req.cookies.get(key_name) or http_req.cookies.get('refreshToken')
            
        return token
