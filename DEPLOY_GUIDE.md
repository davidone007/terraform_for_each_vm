# 🚀 Guía Rápida de Despliegue

## Scripts Disponibles

### 0. **setup-backend.sh** - Configurar Backend Remoto (RECOMENDADO)
Configura un backend remoto en Azure Storage para almacenar el estado de Terraform de forma segura.

```bash
./setup-backend.sh
```

**¿Por qué usar backend remoto?**
- ✅ Estado centralizado y seguro
- ✅ Trabajo en equipo (múltiples usuarios)
- ✅ Bloqueo de estado (evita conflictos)
- ✅ Backup automático
- ✅ Encriptación en reposo

**Crea automáticamente:**
- Resource Group para el backend
- Storage Account con encriptación
- Container para el archivo tfstate
- Configura `providers.tf` con el backend

⚠️ **Nota**: Ejecuta este script ANTES del primer despliegue si quieres usar backend remoto.

---

### 1. **pre-deploy.sh** - Verificación Previa
Verifica que tengas todo lo necesario antes de desplegar.

```bash
./pre-deploy.sh
```

**Verifica:**
- ✅ Terraform instalado
- ✅ Azure CLI instalado
- ✅ Sesión activa en Azure
- ✅ Archivos del proyecto
- ✅ Configuración en terraform.tfvars

---

### 2. **deploy.sh** - Despliegue Completo
Despliega toda la infraestructura de forma automatizada.

```bash
./deploy.sh
```

**Pasos que ejecuta:**
1. Inicializa Terraform
2. Valida la configuración
3. Formatea el código
4. Genera el plan de ejecución
5. Aplica los cambios (previa confirmación)
6. Guarda la información en `deployment-info.txt`

---

### 3. **status.sh** - Ver Estado
Muestra el estado actual de la infraestructura desplegada.

```bash
./status.sh
```

**Muestra:**
- 📋 Lista de recursos creados
- 🔹 IPs públicas de las VMs
- 🔹 Información de la suscripción de Azure

---

### 4. **connect.sh** - Conectar a VMs
Conéctate por SSH a las máquinas virtuales desplegadas.

```bash
./connect.sh
```

Te permite elegir a qué VM conectarte (jenkins o nginx).

---

### 5. **destroy.sh** - Destruir Todo
Elimina TODA la infraestructura creada.

```bash
./destroy.sh
```

⚠️ **CUIDADO:** Esta acción es irreversible.

---

## Uso Rápido con Makefile

Si prefieres comandos más cortos:

```bash
make help      # Ver todos los comandos
make check     # Verificar prerrequisitos
make deploy    # Desplegar infraestructura
make status    # Ver estado
make connect   # Conectar a VM
make destroy   # Destruir todo
make clean     # Limpiar archivos locales
```

---

## 🎯 Flujo Recomendado

### Primera vez

**Opción A: Con Backend Remoto (Recomendado para producción)**

```bash
# 1. Dar permisos de ejecución
chmod +x *.sh

# 2. Login en Azure
az login

# 3. Configurar backend remoto
./setup-backend.sh

# 4. Verificar prerrequisitos
./pre-deploy.sh

# 5. Desplegar
./deploy.sh

# 6. Ver resultado
./status.sh

# 7. Conectar a una VM (opcional)
./connect.sh
```

**Opción B: Con Backend Local (Para desarrollo/pruebas)**

```bash
# 1. Dar permisos de ejecución
chmod +x *.sh

# 2. Login en Azure
az login

# 3. Verificar prerrequisitos
./pre-deploy.sh

# 4. Desplegar
./deploy.sh

# 5. Ver resultado
./status.sh

# 6. Conectar a una VM (opcional)
./connect.sh
```

---

### Después del despliegue

```bash
# Ver estado
./status.sh

# Conectar a VMs
./connect.sh

# Hacer cambios
# ... editar archivos .tf ...
terraform plan
terraform apply

# Destruir cuando termines
./destroy.sh
```

---

## 📝 Notas Importantes

1. **Antes de desplegar**, asegúrate de:
   - Cambiar la contraseña en `terraform.tfvars`
   - Tener sesión activa en Azure (`az login`)
   - Tener permisos en la suscripción de Azure

2. **Los scripts generan archivos**:
   - `deployment-info.txt` - Información del despliegue
   - `tfplan` - Plan de ejecución de Terraform
   - `terraform.tfstate` - Estado actual de la infraestructura

3. **Para limpiar todo**:
   ```bash
   make clean
   # o
   rm -rf .terraform .terraform.lock.hcl terraform.tfstate* tfplan
   ```

---

## 🆘 Solución de Problemas

### Error: "Terraform not found"
```bash
brew install terraform
```

### Error: "Azure CLI not found"
```bash
brew install azure-cli
```

### Error: "No active Azure session"
```bash
az login
```

### Error: "Permission denied"
```bash
chmod +x *.sh
```

---

## 📞 Comandos Útiles Adicionales

```bash
# Ver versiones
terraform version
az version

# Ver suscripciones de Azure
az account list --output table

# Cambiar suscripción
az account set --subscription "SUBSCRIPTION_ID"

# Ver outputs específicos
terraform output vm_public_ips

# Ver estado completo
terraform show

# Importar recurso existente
terraform import azurerm_resource_group.rg /subscriptions/.../resourceGroups/...
```
