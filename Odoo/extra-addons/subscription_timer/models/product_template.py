from odoo import models, fields, api

class ProductTemplate(models.Model):
    _inherit = 'product.template'
    
    is_subscription = fields.Boolean(
        string='Es Suscripción',
        default=False,
        help='Marca si este producto es un plan de suscripción'
    )
    
    subscription_days = fields.Integer(
        string='Días de Suscripción',
        default=30,
        help='Número de días que dura la suscripción'
    )