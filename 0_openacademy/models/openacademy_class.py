from odoo import models, fields

class OpenacademyClass(models.Model):
    _name="openacademy.class"
    _description = "openacademy class"
    
    name = fields.Char(string="Class Name",required=True)
    description = fields.Text()
    course_id = fields.Many2one('openacademy.course',string="course id") #string course id hiển thị trên giao diện

class class_add(models.Model):
    _name="openacademy.class"
    _inherit = "openacademy.class"
    room = fields.Char(string="phòng học")
    
    
    
    
    