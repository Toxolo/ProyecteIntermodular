# -*- coding: utf-8 -*-
{
    'name': "website user signup",
    'summary': "Add a user registration form to the website",
    'description': "Add a user registration form to the website",
    'author': "Mohamed Hawala",
    'license': 'LGPL-3',
    'category': 'website',
    'version': '1.0',
    'depends': ['base', 'website'],
    'data': [
        'security/ir.model.access.csv',
        'views/signup_template.xml'
    ],
    'installable': True,
    'application': False
}
