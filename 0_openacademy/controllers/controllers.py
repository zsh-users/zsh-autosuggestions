# -*- coding: utf-8 -*-
# from odoo import http


# class 0Openacademy(http.Controller):
#     @http.route('/0_openacademy/0_openacademy/', auth='public')
#     def index(self, **kw):
#         return "Hello, world"

#     @http.route('/0_openacademy/0_openacademy/objects/', auth='public')
#     def list(self, **kw):
#         return http.request.render('0_openacademy.listing', {
#             'root': '/0_openacademy/0_openacademy',
#             'objects': http.request.env['0_openacademy.0_openacademy'].search([]),
#         })

#     @http.route('/0_openacademy/0_openacademy/objects/<model("0_openacademy.0_openacademy"):obj>/', auth='public')
#     def object(self, obj, **kw):
#         return http.request.render('0_openacademy.object', {
#             'object': obj
#         })
