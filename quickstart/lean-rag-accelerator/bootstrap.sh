#!/bin/bash

# Lean RAG Accelerator - Bootstrap Script
# This interactive script checks prerequisites and deploys the QuickStart via GitOps

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Lean RAG Accelerator - Bootstrap${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Function to check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed${NC}"
        return 1
    fi
    return 0
}

# Function to check Kubernetes cluster access
check_k8s_access() {
    echo -e "${YELLOW}Checking Kubernetes cluster access...${NC}"
    if ! kubectl cluster-info &> /dev/null; then
        echo -e "${RED}Error: Cannot access Kubernetes cluster${NC}"
        echo "Please ensure you are logged in and have cluster access:"
        echo "  kubectl cluster-info"
        return 1
    fi
    echo -e "${GREEN}✓ Kubernetes cluster accessible${NC}"
    return 0
}

# Function to check GPU resources
check_gpu_resources() {
    echo -e "${YELLOW}Checking GPU resources...${NC}"
    if [ -f "$SCRIPT_DIR/scripts/validate_gpu_resources.sh" ]; then
        bash "$SCRIPT_DIR/scripts/validate_gpu_resources.sh"
    else
        echo -e "${YELLOW}Warning: GPU validation script not found, skipping...${NC}"
    fi
}

# Function to check namespace
check_namespace() {
    local namespace=${1:-default}
    echo -e "${YELLOW}Checking namespace: $namespace${NC}"
    if ! kubectl get namespace "$namespace" &> /dev/null; then
        echo -e "${YELLOW}Namespace '$namespace' does not exist. Creating...${NC}"
        kubectl create namespace "$namespace"
        echo -e "${GREEN}✓ Namespace '$namespace' created${NC}"
    else
        echo -e "${GREEN}✓ Namespace '$namespace' exists${NC}"
    fi
}

# Function to deploy components
deploy_component() {
    local component=$1
    local path=$2
    echo -e "${YELLOW}Deploying $component...${NC}"
    
    if [ -d "$path" ]; then
        # Apply all YAML files in the directory
        for file in "$path"/*.yaml; do
            if [ -f "$file" ]; then
                echo "  Applying $(basename $file)..."
                kubectl apply -f "$file" || echo -e "${RED}  Warning: Failed to apply $file${NC}"
            fi
        done
        echo -e "${GREEN}✓ $component deployed${NC}"
    else
        echo -e "${YELLOW}Warning: $path not found, skipping $component${NC}"
    fi
}

# Main execution
main() {
    echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"
    
    # Check required commands
    check_command kubectl || exit 1
    check_command oc || echo -e "${YELLOW}Warning: 'oc' command not found (OpenShift CLI)${NC}"
    
    # Check cluster access
    check_k8s_access || exit 1
    
    # Check GPU resources
    check_gpu_resources
    
    echo ""
    echo -e "${YELLOW}Step 2: Configuration${NC}"
    
    # Get namespace
    read -p "Enter target namespace [default]: " NAMESPACE
    NAMESPACE=${NAMESPACE:-default}
    check_namespace "$NAMESPACE"
    
    # Export namespace for kubectl
    export KUBECTL_NAMESPACE=$NAMESPACE
    
    echo ""
    echo -e "${YELLOW}Step 3: Deployment Options${NC}"
    echo "1. Full deployment (all components)"
    echo "2. Model optimization only"
    echo "3. Inference serving only"
    echo "4. RAG application only"
    echo "5. Exit"
    read -p "Select option [1]: " DEPLOY_OPTION
    DEPLOY_OPTION=${DEPLOY_OPTION:-1}
    
    echo ""
    echo -e "${YELLOW}Step 4: Deploying components...${NC}"
    
    case $DEPLOY_OPTION in
        1)
            deploy_component "Model Optimization" "$SCRIPT_DIR/examples/01-model-optimization"
            deploy_component "Inference Serving" "$SCRIPT_DIR/examples/02-inference-serving"
            deploy_component "RAG Application" "$SCRIPT_DIR/examples/03-rag-application"
            ;;
        2)
            deploy_component "Model Optimization" "$SCRIPT_DIR/examples/01-model-optimization"
            ;;
        3)
            deploy_component "Inference Serving" "$SCRIPT_DIR/examples/02-inference-serving"
            ;;
        4)
            deploy_component "RAG Application" "$SCRIPT_DIR/examples/03-rag-application"
            ;;
        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Deployment Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Monitor deployment: kubectl get pods -n $NAMESPACE"
    echo "2. Check services: kubectl get svc -n $NAMESPACE"
    echo "3. Review logs: kubectl logs -n $NAMESPACE <pod-name>"
    echo "4. Run benchmarks: See docs/benchmarks.md"
    echo ""
    echo "For more information, see:"
    echo "  - Business Value: docs/business-value-driver.md"
    echo "  - Architecture: docs/architecture.md"
    echo "  - Benchmarks: docs/benchmarks.md"
    echo ""
}

# Run main function
main "$@"

