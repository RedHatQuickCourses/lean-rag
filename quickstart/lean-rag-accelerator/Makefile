# Makefile for Lean RAG Accelerator Deployment
# Provides convenient commands for deploying and managing the optimization stack

# Use bash if available, otherwise use sh
SHELL := $(shell which bash 2>/dev/null || which sh)

# Color definitions
BLUE := $(shell tput setaf 4 2>/dev/null || echo '\033[0;34m')
GREEN := $(shell tput setaf 2 2>/dev/null || echo '\033[0;32m')
YELLOW := $(shell tput setaf 3 2>/dev/null || echo '\033[0;33m')
RED := $(shell tput setaf 1 2>/dev/null || echo '\033[0;31m')
NC := $(shell tput sgr0 2>/dev/null || echo '\033[0m')

# Default values
NAMESPACE ?= lean-rag-accelerator
MODEL ?= llama-3.1-8b-instruct
QUANTIZATION_METHOD ?= smoothquant
TARGET_PRECISION ?= int8

# Set default target
.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help message
	@echo -e "$(GREEN)Lean RAG Accelerator - Deployment Commands$(NC)\n"
	@echo "Usage: make [target] [VARIABLE=value]"
	@echo ""
	@echo "Variables:"
	@echo "  NAMESPACE          Target namespace (default: lean-rag-accelerator)"
	@echo "  MODEL              Model to optimize (default: llama-3.1-8b-instruct)"
	@echo "  QUANTIZATION_METHOD Quantization method: smoothquant or gptq (default: smoothquant)"
	@echo "  TARGET_PRECISION   Target precision: int8 or int4 (default: int8)"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(BLUE)%-20s$(NC) %s\n", $$1, $$2}'

.PHONY: validate
validate: ## Validate prerequisites and environment
	@echo -e "$(YELLOW)[INFO]$(NC) Validating prerequisites..."
	@command -v kubectl >/dev/null 2>&1 || { echo -e "$(RED)[ERROR]$(NC) kubectl not found"; exit 1; }
	@command -v oc >/dev/null 2>&1 || { echo -e "$(YELLOW)[WARN]$(NC) oc not found (optional for OpenShift)"; }
	@kubectl cluster-info >/dev/null 2>&1 || { echo -e "$(RED)[ERROR]$(NC) Cannot connect to cluster"; exit 1; }
	@echo -e "$(GREEN)[OK]$(NC) Prerequisites validated"

.PHONY: namespace
namespace: ## Create namespace if it doesn't exist
	@echo -e "$(YELLOW)[INFO]$(NC) Creating namespace $(NAMESPACE)..."
	@kubectl create namespace $(NAMESPACE) 2>/dev/null || echo -e "$(GREEN)[OK]$(NC) Namespace already exists"

.PHONY: optimize-model
optimize-model: validate namespace ## Deploy model optimization (Stage 1)
	@echo -e "$(YELLOW)[INFO]$(NC) Deploying model optimization..."
	@cd examples/01-model-optimization && \
		kubectl apply -f quantization-recipe.yaml -n $(NAMESPACE)
	@echo -e "$(GREEN)[OK]$(NC) Quantization recipe applied"
	@echo -e "$(YELLOW)[INFO]$(NC) Monitor progress with: kubectl get quantizationrecipe -n $(NAMESPACE) -w"

.PHONY: deploy-inference
deploy-inference: validate namespace ## Deploy inference serving (Stage 2)
	@echo -e "$(YELLOW)[INFO]$(NC) Deploying inference serving..."
	@cd examples/02-inference-serving && \
		kubectl apply -f vllm-runtime.yaml -n $(NAMESPACE) && \
		kubectl apply -f kserve-inferenceservice.yaml -n $(NAMESPACE)
	@echo -e "$(GREEN)[OK]$(NC) Inference serving deployed"
	@echo -e "$(YELLOW)[INFO]$(NC) Monitor with: kubectl get inferenceservice -n $(NAMESPACE) -w"

.PHONY: deploy-rag
deploy-rag: validate namespace ## Deploy RAG application (Stage 3)
	@echo -e "$(YELLOW)[INFO]$(NC) Deploying RAG application..."
	@cd examples/03-rag-application && \
		kubectl apply -f rag-pipeline.yaml -n $(NAMESPACE) && \
		kubectl apply -f docling-job.yaml -n $(NAMESPACE)
	@echo -e "$(GREEN)[OK]$(NC) RAG application deployed"

.PHONY: deploy-benchmarks
deploy-benchmarks: validate namespace ## Deploy benchmarking configuration
	@echo -e "$(YELLOW)[INFO]$(NC) Deploying benchmarking..."
	@cd examples/benchmarks && \
		kubectl apply -f guidellm-config.yaml -n $(NAMESPACE)
	@echo -e "$(GREEN)[OK]$(NC) Benchmarking deployed"

.PHONY: deploy-all
deploy-all: optimize-model deploy-inference deploy-rag deploy-benchmarks ## Deploy all components
	@echo -e "$(GREEN)[OK]$(NC) All components deployed!"
	@echo -e "$(YELLOW)[INFO]$(NC) Next steps:"
	@echo "  1. Monitor quantization: kubectl get quantizationrecipe -n $(NAMESPACE) -w"
	@echo "  2. Check inference service: kubectl get inferenceservice -n $(NAMESPACE)"
	@echo "  3. Review benchmarks: kubectl get guidellmconfig -n $(NAMESPACE)"

.PHONY: status
status: ## Show deployment status
	@echo -e "$(BLUE)=== Deployment Status ===$(NC)\n"
	@echo -e "$(YELLOW)Quantization:$(NC)"
	@kubectl get quantizationrecipe -n $(NAMESPACE) 2>/dev/null || echo "  No quantization recipes found"
	@echo ""
	@echo -e "$(YELLOW)Inference Services:$(NC)"
	@kubectl get inferenceservice -n $(NAMESPACE) 2>/dev/null || echo "  No inference services found"
	@echo ""
	@echo -e "$(YELLOW)Pods:$(NC)"
	@kubectl get pods -n $(NAMESPACE) 2>/dev/null || echo "  No pods found"
	@echo ""
	@echo -e "$(YELLOW)RAG Pipelines:$(NC)"
	@kubectl get ragpipeline -n $(NAMESPACE) 2>/dev/null || echo "  No RAG pipelines found"

.PHONY: logs
logs: ## Show logs from predictor pods
	@echo -e "$(YELLOW)[INFO]$(NC) Fetching logs from predictor pods..."
	@kubectl logs -l component=predictor -n $(NAMESPACE) --tail=50 || echo "No predictor pods found"

.PHONY: test-inference
test-inference: ## Test inference service endpoint
	@echo -e "$(YELLOW)[INFO]$(NC) Testing inference service..."
	@INGRESS_HOST=$$(kubectl get inferenceservice lean-rag-inference -n $(NAMESPACE) -o jsonpath='{.status.url}' 2>/dev/null) && \
		if [ -z "$$INGRESS_HOST" ]; then \
			echo -e "$(RED)[ERROR]$(NC) Inference service not found or not ready"; \
		else \
			echo -e "$(GREEN)[OK]$(NC) Endpoint: $$INGRESS_HOST"; \
			curl -X POST $$INGRESS_HOST/v1/completions \
				-H "Content-Type: application/json" \
				-d '{"prompt": "Hello, world!", "max_tokens": 50}' || \
				echo -e "$(RED)[ERROR]$(NC) Request failed"; \
		fi

.PHONY: clean
clean: ## Remove all deployed resources (WARNING: destructive)
	@echo -e "$(RED)[WARNING]$(NC) This will delete all resources in namespace $(NAMESPACE)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
		echo; \
		if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
			kubectl delete namespace $(NAMESPACE) || echo "Namespace already deleted"; \
			echo -e "$(GREEN)[OK]$(NC) Cleanup complete"; \
		else \
			echo "Cancelled"; \
		fi

.PHONY: uninstall
uninstall: clean ## Alias for clean

.PHONY: verify-gpu
verify-gpu: ## Verify GPU resources are available
	@echo -e "$(YELLOW)[INFO]$(NC) Checking GPU resources..."
	@./scripts/validate_gpu_resources.sh || echo -e "$(RED)[ERROR]$(NC) GPU validation failed"

.PHONY: list-models
list-models: ## List available models for optimization
	@echo -e "$(GREEN)Available Models:$(NC)"
	@echo "  llama-3.1-8b-instruct (meta-llama/Llama-3.1-8B-Instruct)"
	@echo "  llama-3.2-3b-instruct (meta-llama/Llama-3.2-3B-Instruct)"
	@echo "  llama-3.2-1b-instruct (meta-llama/Llama-3.2-1B-Instruct)"
	@echo ""
	@echo -e "$(YELLOW)Quantization Methods:$(NC)"
	@echo "  smoothquant - INT8 quantization (recommended)"
	@echo "  gptq - INT4 quantization (maximum compression)"

