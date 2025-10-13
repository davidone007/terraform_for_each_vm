#!/bin/bash

set -e

echo "=========================================="
echo "☁️  CONFIGURAR BACKEND REMOTO EN AZURE"
echo "=========================================="
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Verificar Azure CLI
if ! command -v az &> /dev/null; then
    log_error "Azure CLI no está instalado"
    exit 1
fi

# Verificar sesión
if ! az account show &> /dev/null; then
    log_error "No hay sesión activa en Azure. Ejecuta: az login"
    exit 1
fi

echo "Este script creará:"
echo "  1. Un Resource Group para el backend"
echo "  2. Una Storage Account"
echo "  3. Un Container para el archivo tfstate"
echo "  4. Configurará el backend en providers.tf"
echo ""

# Configuración por defecto
DEFAULT_BACKEND_RG="terraform-backend-rg"
DEFAULT_LOCATION="East US"
DEFAULT_STORAGE_ACCOUNT="tfstate$(date +%s | tail -c 6)"
DEFAULT_CONTAINER="tfstate"

# Solicitar configuración
log_step "Paso 1/5: Configuración del Backend"
echo ""
read -p "Nombre del Resource Group [${DEFAULT_BACKEND_RG}]: " BACKEND_RG
BACKEND_RG=${BACKEND_RG:-$DEFAULT_BACKEND_RG}

read -p "Región [${DEFAULT_LOCATION}]: " LOCATION
LOCATION=${LOCATION:-$DEFAULT_LOCATION}

read -p "Nombre de la Storage Account [${DEFAULT_STORAGE_ACCOUNT}]: " STORAGE_ACCOUNT
STORAGE_ACCOUNT=${STORAGE_ACCOUNT:-$DEFAULT_STORAGE_ACCOUNT}

read -p "Nombre del Container [${DEFAULT_CONTAINER}]: " CONTAINER_NAME
CONTAINER_NAME=${CONTAINER_NAME:-$DEFAULT_CONTAINER}

echo ""
log_info "Configuración:"
echo "  Resource Group: $BACKEND_RG"
echo "  Región: $LOCATION"
echo "  Storage Account: $STORAGE_ACCOUNT"
echo "  Container: $CONTAINER_NAME"
echo ""

read -p "¿Continuar? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    log_warning "Operación cancelada"
    exit 0
fi
echo ""

# Crear Resource Group
log_step "Paso 2/5: Creando Resource Group..."
if az group show --name "$BACKEND_RG" &> /dev/null; then
    log_warning "El Resource Group '$BACKEND_RG' ya existe"
else
    az group create --name "$BACKEND_RG" --location "$LOCATION"
    log_info "✅ Resource Group creado"
fi
echo ""

# Crear Storage Account
log_step "Paso 3/5: Creando Storage Account..."
if az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$BACKEND_RG" &> /dev/null; then
    log_warning "La Storage Account '$STORAGE_ACCOUNT' ya existe"
else
    az storage account create \
        --name "$STORAGE_ACCOUNT" \
        --resource-group "$BACKEND_RG" \
        --location "$LOCATION" \
        --sku Standard_LRS \
        --encryption-services blob \
        --https-only true \
        --min-tls-version TLS1_2 \
        --allow-blob-public-access false
    log_info "✅ Storage Account creada"
fi
echo ""

# Obtener la clave de la Storage Account
ACCOUNT_KEY=$(az storage account keys list \
    --resource-group "$BACKEND_RG" \
    --account-name "$STORAGE_ACCOUNT" \
    --query '[0].value' -o tsv)

# Crear Container
log_step "Paso 4/5: Creando Container..."
if az storage container show \
    --name "$CONTAINER_NAME" \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$ACCOUNT_KEY" &> /dev/null; then
    log_warning "El Container '$CONTAINER_NAME' ya existe"
else
    az storage container create \
        --name "$CONTAINER_NAME" \
        --account-name "$STORAGE_ACCOUNT" \
        --account-key "$ACCOUNT_KEY"
    log_info "✅ Container creado"
fi
echo ""

# Configurar backend en providers.tf
log_step "Paso 5/5: Configurando providers.tf..."

# Hacer backup del providers.tf actual
if [ -f "providers.tf" ]; then
    cp providers.tf providers.tf.backup
    log_info "✅ Backup creado: providers.tf.backup"
fi

# Crear nuevo providers.tf con backend
cat > providers.tf << EOF
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Backend remoto en Azure Storage
  backend "azurerm" {
    resource_group_name  = "$BACKEND_RG"
    storage_account_name = "$STORAGE_ACCOUNT"
    container_name       = "$CONTAINER_NAME"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
EOF

log_info "✅ providers.tf configurado con backend remoto"
echo ""

# Guardar configuración en archivo
cat > backend-config.txt << EOF
# Configuración del Backend Remoto
# Generado: $(date)

Resource Group:    $BACKEND_RG
Storage Account:   $STORAGE_ACCOUNT
Container:         $CONTAINER_NAME
Región:            $LOCATION
Estado remoto:     terraform.tfstate

# Para reconfigurar manualmente:
terraform init -reconfigure \\
  -backend-config="resource_group_name=$BACKEND_RG" \\
  -backend-config="storage_account_name=$STORAGE_ACCOUNT" \\
  -backend-config="container_name=$CONTAINER_NAME" \\
  -backend-config="key=terraform.tfstate"

# Para migrar estado existente:
terraform init -migrate-state
EOF

log_info "✅ Configuración guardada en: backend-config.txt"
echo ""

echo "=========================================="
log_info "🎉 BACKEND REMOTO CONFIGURADO"
echo "=========================================="
echo ""
echo "📋 Próximos pasos:"
echo ""
echo "1. Inicializar Terraform con el nuevo backend:"
echo "   terraform init"
echo ""
echo "2. Si ya tenías estado local, migrar con:"
echo "   terraform init -migrate-state"
echo ""
echo "3. Verificar que el backend funciona:"
echo "   terraform plan"
echo ""
echo "4. Continuar con el despliegue:"
echo "   ./deploy.sh"
echo ""
log_warning "IMPORTANTE: El archivo 'backend-config.txt' contiene información sensible."
log_warning "NO lo subas a Git. Ya está en .gitignore"
echo ""
