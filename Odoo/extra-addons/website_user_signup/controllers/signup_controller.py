from odoo import http
from odoo.http import request
import werkzeug

class WebsiteSignupController(http.Controller):

    @http.route('/signup', type='http', auth='public', website=True)
    def signup_form(self, **kwargs):
        return request.render('website_user_signup.signup_template')

    @http.route('/signup/submit', type='http', auth='public', website=True, csrf=False)
    def submit_signup(self, **post):
        name = post.get('name')
        email = post.get('email')
        password = post.get('password')

        if not name or not email or not password:
            return request.redirect('/signup?error=missing_fields')

        existing_user = request.env['res.users'].sudo().search([('login', '=', email)])
        if existing_user:
            return request.redirect('/signup?error=email_exists')

        portal_group = request.env.ref('base.group_portal')
        user = request.env['res.users'].sudo().create({
            'name': name,
            'login': email,
            'email': email,
            'password': password,
            'groups_id': [(6, 0, [portal_group.id])],
        })

        return werkzeug.utils.redirect('/web/login')
