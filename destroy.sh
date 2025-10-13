#!/bin/bash

echo "=========================================="
echo "⚠️  DESTRUIR INFRAESTRUCTURA"
echo "=========================================="
echo ""

# Advertencia
echo "🚨 ADVERTENCIA: Esta acción eliminará TODOS los recursos creados"
echo "   - Máquinas virtuales"
echo "   - IPs públicas"
echo "   - Interfaces de red"
echo "   - Security groups"
echo "   - Redes virtuales"
echo "   - Resource groups"
echo ""

read -p "¿Estás SEGURO que deseas continuar? (escribe 'DESTROY' para confirmar): " confirm

if [ "$confirm" != "DESTROY" ]; then
    echo "❌ Operación cancelada"
    exit 0
fi
echo ""

# Mostrar qué se va a destruir
echo "📋 Recursos que serán destruidos:"
terraform state list
echo ""

read -p "¿Proceder con la destrucción? (yes/no): " final_confirm

if [ "$final_confirm" != "yes" ]; then
    echo "❌ Operación cancelada"
    exit 0
fi
echo ""

# Destruir
echo "🗑️  Destruyendo infraestructura..."
terraform destroy -auto-approve

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ INFRAESTRUCTURA DESTRUIDA"
    echo "=========================================="
else
    echo ""
    echo "❌ Error durante la destrucción"
    exit 1
fi
