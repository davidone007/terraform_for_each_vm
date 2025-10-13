#!/bin/bash

echo "=========================================="
echo "🔍 VERIFICACIÓN PRE-DESPLIEGUE"
echo "=========================================="
echo ""

# 1. Verificar Terraform instalado
echo "1️⃣  Verificando Terraform..."
if command -v terraform &> /dev/null; then
    echo "✅ Terraform instalado: $(terraform version | head -n 1)"
else
    echo "❌ Terraform NO está instalado"
    echo "   Instalar con: brew install terraform"
    exit 1
fi
echo ""

# 2. Verificar Azure CLI
echo "2️⃣  Verificando Azure CLI..."
if command -v az &> /dev/null; then
    echo "✅ Azure CLI instalado: $(az version --query '"azure-cli"' -o tsv)"
else
    echo "❌ Azure CLI NO está instalado"
    echo "   Instalar con: brew install azure-cli"
    exit 1
fi
echo ""

# 3. Verificar sesión Azure
echo "3️⃣  Verificando sesión de Azure..."
if az account show &> /dev/null; then
    echo "✅ Sesión activa en Azure"
    echo "   Suscripción: $(az account show --query name -o tsv)"
    echo "   ID: $(az account show --query id -o tsv)"
else
    echo "❌ NO hay sesión activa en Azure"
    echo "   Ejecutar: az login"
    exit 1
fi
echo ""

# 4. Verificar archivos necesarios
echo "4️⃣  Verificando archivos del proyecto..."
files=("main.tf" "variables.tf" "providers.tf" "terraform.tfvars" "modules/vm/main.tf")
all_exist=true

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file existe"
    else
        echo "❌ $file NO existe"
        all_exist=false
    fi
done
echo ""

if [ "$all_exist" = false ]; then
    echo "⚠️  Faltan archivos necesarios"
    exit 1
fi

# 5. Verificar terraform.tfvars
echo "5️⃣  Verificando configuración..."
if grep -q "password.*=.*#" terraform.tfvars; then
    echo "⚠️  ADVERTENCIA: La contraseña contiene '#########'"
    echo "   Debes cambiarla por una contraseña real"
    read -p "¿Continuar de todas formas? (y/n): " continue
    if [ "$continue" != "y" ]; then
        exit 1
    fi
fi
echo ""

echo "=========================================="
echo "✅ VERIFICACIÓN COMPLETADA"
echo "=========================================="
echo "Puedes proceder con el despliegue"
echo ""
