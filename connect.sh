#!/bin/bash

echo "=========================================="
echo "🔌 CONECTAR A MÁQUINAS VIRTUALES"
echo "=========================================="
echo ""

# Verificar que Terraform esté inicializado
if [ ! -d ".terraform" ]; then
    echo "❌ Terraform no está inicializado"
    echo "   Ejecuta: terraform init"
    exit 1
fi

# Obtener usuario de terraform.tfvars
user=$(grep 'user.*=' terraform.tfvars | cut -d'"' -f2 | xargs)

if [ -z "$user" ]; then
    echo "❌ No se pudo obtener el usuario de terraform.tfvars"
    exit 1
fi

# Obtener outputs de Terraform
echo "📋 Obteniendo información de las VMs..."
echo ""

# Mostrar output de Terraform directamente
terraform output ip_servers

echo ""
echo "Ingresa la IP de la VM a la que deseas conectarte:"
read -p "IP: " vm_ip

if [ -z "$vm_ip" ]; then
    echo "❌ IP no válida"
    exit 1
fi

echo ""
echo "🔌 Conectando a $vm_ip..."
echo "   Usuario: $user"
echo "   Contraseña: (definida en terraform.tfvars)"
echo ""

# Conectar por SSH
ssh -o StrictHostKeyChecking=no "$user@$vm_ip"
