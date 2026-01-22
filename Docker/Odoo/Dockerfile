FROM odoo:16

USER root

# Copiar requirements e instalar dependencias Python
COPY requirements.txt /tmp/
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# Instalar unzip (necesario para descomprimir módulos)
RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*

# Copiar el script de entrada y dar permisos (TODO COMO ROOT)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Cambiar a usuario odoo DESPUÉS de dar permisos
USER odoo

# Establecer como entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Comando por defecto de Odoo
CMD ["odoo"]