FROM odoo:16

USER root
COPY Odoo/requirements.txt /tmp/

# Instalar unzip
RUN apt-get update && \
    apt-get install -y unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copiar los archivos ZIP a un directorio temporal que NO se sobrescribirá
COPY Odoo/modulos-zip/ /tmp/modulos-zip/

# Copiar el script de inicialización
COPY Odoo/entrypoint.sh /usr/local/bin/custom-entrypoint.sh
RUN chmod +x /usr/local/bin/custom-entrypoint.sh

RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

USER odoo

# Usar nuestro entrypoint personalizado
ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]
CMD ["odoo"]