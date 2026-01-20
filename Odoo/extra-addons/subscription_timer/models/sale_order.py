from odoo import models, api

class SaleOrder(models.Model):
    _inherit = 'sale.order'
    
    def action_confirm(self):
        """Sobrescribir para crear suscripciones al confirmar pedido"""
        res = super(SaleOrder, self).action_confirm()
        
        for order in self:
            for line in order.order_line:
                if line.product_id.product_tmpl_id.is_subscription:
                    # Crear la suscripción
                    self.env['subscription.subscription'].create({
                        'partner_id': order.partner_id.id,
                        'product_id': line.product_id.id,
                        'sale_order_id': order.id,
                        'total_days': line.product_id.product_tmpl_id.subscription_days,
                        'state': 'active',
                    })
        
        return res