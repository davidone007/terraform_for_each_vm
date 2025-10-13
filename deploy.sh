#!/bin/bash

set -e  # Salir si hay algún error

echo "=========================================="
echo "🚀 INICIANDO DESPLIEGUE DE INFRAESTRUCTURA"
echo "=========================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Función para logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Paso 1: Limpiar archivos anteriores (opcional)
log_info "Limpiando archivos de estado anteriores..."
if [ -d ".terraform" ]; then
    log_warning "Directorio .terraform existe. ¿Deseas limpiarlo?"
    read -p "Limpiar .terraform? (y/n): " clean
    if [ "$clean" = "y" ]; then
        rm -rf .terraform
        rm -f .terraform.lock.hcl
        log_info "Limpieza completada"
    fi
fi
echo ""

# Paso 2: Terraform Init
log_info "Paso 1/5: Inicializando Terraform..."
terraform init
if [ $? -eq 0 ]; then
    log_info "✅ Inicialización completada"
else
    log_error "❌ Error en la inicialización"
    exit 1
fi
echo ""

# Paso 3: Terraform Validate
log_info "Paso 2/5: Validando configuración..."
terraform validate
if [ $? -eq 0 ]; then
    log_info "✅ Validación exitosa"
else
    log_error "❌ Error en la validación"
    exit 1
fi
echo ""

# Paso 4: Terraform Format (opcional)
log_info "Paso 3/5: Formateando código..."
terraform fmt -recursive
log_info "✅ Formato aplicado"
echo ""

# Paso 5: Terraform Plan
log_info "Paso 4/5: Generando plan de ejecución..."
terraform plan -out=tfplan
if [ $? -eq 0 ]; then
    log_info "✅ Plan generado exitosamente"
else
    log_error "❌ Error al generar el plan"
    exit 1
fi
echo ""

# Revisar el plan
log_warning "Revisa el plan anterior cuidadosamente"
read -p "¿Deseas continuar con el despliegue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    log_warning "Despliegue cancelado por el usuario"
    exit 0
fi
echo ""

# Paso 6: Terraform Apply
log_info "Paso 5/5: Desplegando infraestructura..."
terraform apply tfplan
if [ $? -eq 0 ]; then
    log_info "✅ Despliegue completado exitosamente"
else
    log_error "❌ Error durante el despliegue"
    exit 1
fi
echo ""

# Mostrar outputs
echo "=========================================="
log_info "📊 INFORMACIÓN DE LA INFRAESTRUCTURA"
echo "=========================================="
terraform output
echo ""

# Guardar outputs en archivo
log_info "Guardando outputs en deployment-info.txt..."
terraform output > deployment-info.txt
echo ""

echo "=========================================="
log_info "🎉 DESPLIEGUE COMPLETADO"
echo "=========================================="
log_info "Información guardada en: deployment-info.txt"
echo ""
