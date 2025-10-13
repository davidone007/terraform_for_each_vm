#!/bin/bash

echo "=========================================="
echo "⚡ INICIO RÁPIDO - DESPLIEGUE TERRAFORM"
echo "=========================================="
echo ""

# Función para mostrar comandos
show_command() {
    echo "💡 Comando a ejecutar: $1"
    echo ""
}

echo "Este es un despliegue rápido sin confirmaciones."
echo "Para un despliegue con más control, usa: ./deploy.sh"
echo ""
read -p "¿Continuar con el despliegue rápido? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Operación cancelada"
    exit 0
fi
echo ""

# 1. Login Azure
echo "🔐 Paso 1: Verificando sesión de Azure..."
if az account show &> /dev/null; then
    echo "✅ Ya hay sesión activa"
    echo "   Suscripción: $(az account show --query name -o tsv)"
else
    echo "⚠️  No hay sesión activa"
    show_command "az login"
    az login
fi
echo ""

# 2. Init
echo "📦 Paso 2: Inicializando Terraform..."
show_command "terraform init"
terraform init
echo ""

# 3. Validate
echo "✔️  Paso 3: Validando..."
show_command "terraform validate"
terraform validate
echo ""

# 4. Plan
echo "📋 Paso 4: Generando plan..."
show_command "terraform plan"
terraform plan
echo ""

# 5. Apply
echo "🚀 Paso 5: Desplegando..."
show_command "terraform apply -auto-approve"
terraform apply -auto-approve
echo ""

# 6. Output
echo "=========================================="
echo "📊 INFORMACIÓN DE LA INFRAESTRUCTURA"
echo "=========================================="
terraform output
echo ""

# Guardar info
terraform output > deployment-info.txt

echo "=========================================="
echo "✅ DESPLIEGUE COMPLETADO"
echo "=========================================="
echo ""
echo "📄 Información guardada en: deployment-info.txt"
echo ""
echo "Para conectarte a las VMs, ejecuta:"
echo "   ./connect.sh"
echo ""
echo "Para ver el estado:"
echo "   ./status.sh"
echo ""
echo "Para destruir todo:"
echo "   ./destroy.sh"
echo ""
