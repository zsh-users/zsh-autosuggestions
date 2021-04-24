from odoo import models, fields

class Course(models.Model):
    _name = 'openacademy.course'   #tên trên local là openacademy_course
    _description = "OpenAcademy Courses"

    name = fields.Char(string="Title", required=True)
    description = fields.Text()
    class_ids = fields.One2many("openacademy.class","course_id",string="Class")
    demo = fields.One2many
