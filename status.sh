#!/bin/bash

echo "=========================================="
echo "📊 ESTADO DE LA INFRAESTRUCTURA"
echo "=========================================="
echo ""

# Verificar si el estado existe
if [ ! -f "terraform.tfstate" ]; then
    echo "❌ No hay infraestructura desplegada"
    echo "   El archivo terraform.tfstate no existe"
    exit 1
fi

# Mostrar recursos creados
echo "🔹 Recursos creados:"
terraform state list
echo ""

# Mostrar outputs
echo "🔹 Outputs (IPs y conexiones):"
terraform output
echo ""

# Información de Azure
echo "🔹 Suscripción de Azure actual:"
az account show --query "{Nombre:name, ID:id}" -o table
echo ""

echo "=========================================="
