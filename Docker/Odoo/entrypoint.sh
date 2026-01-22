#!/bin/bash
set -e

# Descomprimir módulos si existen y extra-addons está vacío
if [ -d /tmp/modulos-zip ] && [ ! "$(ls -A /mnt/extra-addons 2>/dev/null)" ]; then
    echo "Descomprimiendo módulos en /mnt/extra-addons..."
    cd /tmp/modulos-zip
    for file in *.zip; do
        if [ -f "$file" ]; then
            echo "Descomprimiendo $file..."
            unzip -o "$file" -d /mnt/extra-addons/
        fi
    done
    echo "Módulos descomprimidos correctamente"
fi

# Crear odoo.conf si no existe
if [ ! -f /etc/odoo/odoo.conf ]; then
    echo "Creando odoo.conf..."
    cat > /etc/odoo/odoo.conf << EOF
[options]
admin_passwd = cnuw-qwz5-jirc
db_host = db
db_port = 5432
db_user = odoo
db_password = odoo
addons_path = /mnt/extra-addons
EOF
    echo "odoo.conf creado correctamente"
fi

# Ejecutar el comando original de Odoo
exec /entrypoint.sh "$@"