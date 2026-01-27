from odoo import models, fields, api
from datetime import datetime, timedelta

class Subscription(models.Model):
    _name = 'subscription.subscription'
    _description = 'Suscripción del Cliente'
    _order = 'start_date desc'
    
    name = fields.Char(string='Referencia', required=True, copy=False, readonly=True, default='Nuevo')
    partner_id = fields.Many2one('res.partner', string='Cliente', required=True, ondelete='cascade')
    product_id = fields.Many2one('product.product', string='Producto', required=True, domain=[('product_tmpl_id.is_subscription', '=', True)])
    sale_order_id = fields.Many2one('sale.order', string='Pedido de Venta')
    
    start_date = fields.Date(string='Fecha de Inicio', default=fields.Date.today, required=True)
    end_date = fields.Date(string='Fecha de Fin', compute='_compute_end_date', store=True)
    
    total_days = fields.Integer(string='Total de Días', required=True)
    
    # CAMBIO: Quitar store=True para que se calcule siempre en tiempo real
    days_remaining = fields.Integer(string='Días Restantes', compute='_compute_days_remaining')
    
    state = fields.Selection([
        ('active', 'Activa'),
        ('expired', 'Expirada'),
        ('cancelled', 'Cancelada')
    ], string='Estado', default='active', required=True)
    
    # CAMBIO: Quitar store=True para que se calcule siempre
    progress = fields.Float(string='Progreso (%)', compute='_compute_progress')
    
    @api.model
    def create(self, vals):
        if vals.get('name', 'Nuevo') == 'Nuevo':
            vals['name'] = self.env['ir.sequence'].next_by_code('subscription.subscription') or 'SUB/'
        return super(Subscription, self).create(vals)
    
    @api.depends('start_date', 'total_days')
    def _compute_end_date(self):
        for record in self:
            if record.start_date and record.total_days:
                record.end_date = record.start_date + timedelta(days=record.total_days)
            else:
                record.end_date = False
    
    # CAMBIO: Simplificar dependencias y mejorar cálculo
    @api.depends('end_date')
    def _compute_days_remaining(self):
        today = fields.Date.today()
        for record in self:
            if record.state == 'expired' or record.state == 'cancelled':
                record.days_remaining = 0
            elif record.end_date:
                delta = record.end_date - today
                days = max(0, delta.days)
                record.days_remaining = days
                
                # NUEVO: Auto-expirar si llegó a 0 días y la fecha ya pasó
                if days == 0 and record.end_date < today and record.state == 'active':
                    record.state = 'expired'
            else:
                record.days_remaining = 0
    
    @api.depends('total_days', 'days_remaining')
    def _compute_progress(self):
        for record in self:
            if record.total_days > 0:
                elapsed = record.total_days - record.days_remaining
                record.progress = (elapsed / record.total_days) * 100
            else:
                record.progress = 0
    
    def action_check_expiration(self):
        """Método llamado por el cron para verificar expiraciones"""
        today = fields.Date.today()
        
        # Buscar suscripciones activas que ya expiraron
        subscriptions = self.search([
            ('state', '=', 'active'), 
            ('end_date', '<', today)  # Cambiado <= a < para que sea más claro
        ])
        
        if subscriptions:
            subscriptions.write({'state': 'expired'})
            # Log para debugging
            import logging
            _logger = logging.getLogger(__name__)
            _logger.info(f"=== CRON EXPIRATION ===")
            _logger.info(f"Marcadas como expiradas {len(subscriptions)} suscripciones")
            _logger.info(f"IDs: {subscriptions.ids}")
        
        return True
    
    # NUEVO: Método para forzar recálculo (útil para debugging)
    def action_recompute_days(self):
        """Forzar recálculo de días restantes"""
        self._compute_days_remaining()
        self._compute_progress()
        return True