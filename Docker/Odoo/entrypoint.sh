#!/bin/bash
set -e

echo "============================================"
echo "🚀 Iniciando Odoo con descompresión de módulos"
echo "============================================"

# Directorios
MODULES_ZIP_DIR="/mnt/modules-zip"
EXTRA_ADDONS_DIR="/mnt/extra-addons"

# Función para limpiar extra-addons
clean_addons() {
    echo "🗑️  Limpiando módulos anteriores..."
    if [ -d "$EXTRA_ADDONS_DIR" ]; then
        find "$EXTRA_ADDONS_DIR" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +
        echo "   ✓ Carpeta limpiada"
    else
        mkdir -p "$EXTRA_ADDONS_DIR"
        echo "   ✓ Carpeta creada"
    fi
}

# Función para descomprimir módulos
unzip_modules() {
    if [ ! -d "$MODULES_ZIP_DIR" ]; then
        echo "⚠️  No existe $MODULES_ZIP_DIR"
        return
    fi
    
    ZIP_COUNT=$(find "$MODULES_ZIP_DIR" -name "*.zip" 2>/dev/null | wc -l)
    
    if [ "$ZIP_COUNT" -eq 0 ]; then
        echo "⚠️  No hay archivos .zip en $MODULES_ZIP_DIR"
        return
    fi
    
    echo "📦 Descomprimiendo $ZIP_COUNT módulos..."
    
    for zip_file in "$MODULES_ZIP_DIR"/*.zip; do
        if [ -f "$zip_file" ]; then
            filename=$(basename "$zip_file")
            echo "   📂 $filename"
            unzip -q -o "$zip_file" -d "$EXTRA_ADDONS_DIR"
            echo "   ✓ Descomprimido"
        fi
    done
    
    echo "✅ Módulos listos"
}

# Función para listar módulos
list_modules() {
    echo ""
    echo "📋 Módulos disponibles:"
    if [ -d "$EXTRA_ADDONS_DIR" ]; then
        MODULE_COUNT=$(find "$EXTRA_ADDONS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
        if [ "$MODULE_COUNT" -gt 0 ]; then
            for module in "$EXTRA_ADDONS_DIR"/*; do
                if [ -d "$module" ]; then
                    module_name=$(basename "$module")
                    if [ -f "$module/__manifest__.py" ]; then
                        echo "   ✓ $module_name"
                    else
                        echo "   ⚠️  $module_name (sin __manifest__.py)"
                    fi
                fi
            done
        else
            echo "   (ninguno)"
        fi
    fi
}

# Ejecutar proceso
clean_addons
unzip_modules
list_modules

echo ""
echo "============================================"
echo "🎉 Iniciando Odoo..."
echo "============================================"
echo ""

# Ejecutar el comando original de Odoo
exec "$@"