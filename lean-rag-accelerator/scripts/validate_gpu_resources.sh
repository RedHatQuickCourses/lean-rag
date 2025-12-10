#!/bin/bash

# GPU Resource Validation Script
# Ensures the cluster has required GPU hardware for the Lean RAG Accelerator

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Validating GPU resources...${NC}"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

# Check cluster access
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Error: Cannot access Kubernetes cluster${NC}"
    exit 1
fi

# Function to check for GPU nodes
check_gpu_nodes() {
    echo -e "${YELLOW}Checking for GPU nodes...${NC}"
    
    # Check for nodes with GPU labels
    GPU_NODES=$(kubectl get nodes -l nvidia.com/gpu.present=true --no-headers 2>/dev/null | wc -l)
    
    if [ "$GPU_NODES" -eq 0 ]; then
        # Try alternative label
        GPU_NODES=$(kubectl get nodes -l accelerator=nvidia-tesla --no-headers 2>/dev/null | wc -l)
    fi
    
    if [ "$GPU_NODES" -eq 0 ]; then
        # Check all nodes for GPU resources
        GPU_NODES=$(kubectl get nodes -o json | jq -r '.items[] | select(.status.capacity."nvidia.com/gpu" != null) | .metadata.name' 2>/dev/null | wc -l)
    fi
    
    if [ "$GPU_NODES" -gt 0 ]; then
        echo -e "${GREEN}✓ Found $GPU_NODES GPU node(s)${NC}"
        
        # List GPU nodes
        echo "GPU Nodes:"
        kubectl get nodes -o json | jq -r '.items[] | select(.status.capacity."nvidia.com/gpu" != null) | "  - \(.metadata.name): \(.status.capacity."nvidia.com/gpu") GPU(s)"' 2>/dev/null || \
        kubectl get nodes -l nvidia.com/gpu.present=true -o custom-columns=NAME:.metadata.name,GPUS:.status.capacity.'nvidia\.com/gpu' 2>/dev/null || \
        echo "  (GPU node details available)"
        
        return 0
    else
        echo -e "${RED}✗ No GPU nodes found${NC}"
        echo "  The Lean RAG Accelerator requires GPU nodes with NVIDIA GPUs"
        echo "  Please ensure your cluster has GPU nodes configured"
        return 1
    fi
}

# Function to check for GPU device plugin
check_gpu_plugin() {
    echo -e "${YELLOW}Checking for GPU device plugin...${NC}"
    
    # Check for NVIDIA device plugin daemonset
    if kubectl get daemonset -n kube-system nvidia-device-plugin-daemonset &> /dev/null || \
       kubectl get daemonset -A | grep -i nvidia &> /dev/null; then
        echo -e "${GREEN}✓ NVIDIA device plugin found${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ NVIDIA device plugin not found${NC}"
        echo "  The device plugin may be installed in a different namespace"
        echo "  This is not critical if GPU nodes are already configured"
        return 0
    fi
}

# Function to check GPU resources in a namespace
check_gpu_resources() {
    local namespace=${1:-default}
    echo -e "${YELLOW}Checking GPU resources in namespace: $namespace${NC}"
    
    if kubectl get namespace "$namespace" &> /dev/null; then
        # Check for available GPU resources
        AVAILABLE_GPUS=$(kubectl describe node | grep -i "nvidia.com/gpu" | head -1 | awk '{print $2}' 2>/dev/null || echo "0")
        
        if [ "$AVAILABLE_GPUS" != "0" ] && [ -n "$AVAILABLE_GPUS" ]; then
            echo -e "${GREEN}✓ GPU resources available${NC}"
        else
            echo -e "${YELLOW}⚠ GPU resource availability unclear${NC}"
            echo "  This may be normal if GPUs are allocated via node selectors"
        fi
    else
        echo -e "${YELLOW}Namespace '$namespace' does not exist${NC}"
    fi
}

# Function to check for required GPU types
check_gpu_types() {
    echo -e "${YELLOW}Checking GPU types...${NC}"
    
    # Recommended: NVIDIA A10G or equivalent
    # Minimum: Any CUDA-compatible GPU with 16GB+ memory
    
    echo "Recommended GPU: NVIDIA A10G (24GB) or equivalent"
    echo "Minimum GPU: 16GB VRAM, CUDA-compatible"
    echo ""
    echo "Current GPU nodes:"
    kubectl get nodes -o json | jq -r '.items[] | select(.status.capacity."nvidia.com/gpu" != null) | "  \(.metadata.name): \(.status.capacity."nvidia.com/gpu") GPU(s)"' 2>/dev/null || \
    echo "  (Run 'kubectl describe nodes' for detailed GPU information)"
}

# Main execution
main() {
    echo ""
    
    # Check GPU nodes
    if ! check_gpu_nodes; then
        echo ""
        echo -e "${RED}GPU validation failed. Please ensure your cluster has GPU nodes configured.${NC}"
        exit 1
    fi
    
    echo ""
    
    # Check GPU device plugin
    check_gpu_plugin
    
    echo ""
    
    # Check GPU types
    check_gpu_types
    
    echo ""
    
    # Check GPU resources in default namespace
    check_gpu_resources "default"
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}GPU Validation Complete${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "If GPU nodes are present, you can proceed with deployment."
    echo "If not, please configure GPU nodes before deploying the Lean RAG Accelerator."
    echo ""
}

# Run main function
main "$@"

