.PHONY: help check backend deploy plan apply destroy status connect clean

help:
	@echo "=========================================="
	@echo "🛠️  COMANDOS DISPONIBLES"
	@echo "=========================================="
	@echo "make backend  - Configurar backend remoto en Azure"
	@echo "make check    - Verificar prerrequisitos"
	@echo "make plan     - Generar plan de Terraform"
	@echo "make deploy   - Desplegar infraestructura completa"
	@echo "make apply    - Aplicar cambios"
	@echo "make status   - Ver estado de la infraestructura"
	@echo "make connect  - Conectar a una VM"
	@echo "make destroy  - Destruir toda la infraestructura"
	@echo "make clean    - Limpiar archivos de Terraform"
	@echo ""

backend:
	@bash setup-backend.sh

check:
	@bash pre-deploy.sh

plan:
	@terraform init
	@terraform plan

deploy:
	@bash deploy.sh

apply:
	@terraform apply

status:
	@bash status.sh

connect:
	@bash connect.sh

destroy:
	@bash destroy.sh

clean:
	@rm -rf .terraform .terraform.lock.hcl terraform.tfstate* tfplan
	@echo "✅ Archivos de Terraform limpiados"
