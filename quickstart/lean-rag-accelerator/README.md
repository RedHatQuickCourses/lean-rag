<!-- omit from toc -->
# Optimize RAG for Cost and Performance with Lean RAG Accelerator

[![GitHub release](https://img.shields.io/github/v/release/rh-ai-quickstart/lean-rag-accelerator)](https://github.com/rh-ai-quickstart/lean-rag-accelerator/releases)

Optimize your existing RAG deployments to reduce GPU costs by 50%+ and improve throughput by 2x-4x through model quantization, high-performance serving, and optimized inference configurations.

<!-- omit from toc -->
## Table of Contents
- [Detailed description](#detailed-description)
  - [Architecture diagrams](#architecture-diagrams)
- [Requirements](#requirements)
  - [Minimum hardware requirements](#minimum-hardware-requirements)
  - [Minimum software requirements](#minimum-software-requirements)
  - [Required user permissions](#required-user-permissions)
- [Deploy](#deploy)
  - [Prerequisites](#prerequisites)
  - [Supported Models](#supported-models)
  - [Installation Steps](#installation-steps)
  - [Optimizing Existing RAG Deployments](#optimizing-existing-rag-deployments)
- [Tags](#tags)

## Detailed description

**Most GenAI pilots fail not because the model isn't smart, but because it becomes too expensive to run at scale. You are likely utilizing less than 40% of your expensive GPU capacity.**

The Lean RAG Accelerator leverages **Red Hat OpenShift AI 3.0's AI Factory** approach to optimize your RAG deployments. This QuickStart demonstrates how to use RHOAI 3.0's industrialized model serving capabilities to achieve production-ready performance and cost efficiency.

### Red Hat OpenShift AI 3.0 Capabilities

This QuickStart showcases key RHOAI 3.0 features:

- **AI Factory Approach**: Industrialized model serving with standardized components and automated workflows
- **LLM Compressor**: RHOAI 3.0's model compression tool for quantization (SmoothQuant, GPTQ)
- **RHOAI 3.0 Inference Stack**: vLLM and llm-d as core inference engines with KServe integration
- **Model Registry**: Integration with RHOAI 3.0's model catalog for validated, pre-optimized models
- **Llama Stack API**: Standardized RAG interface for consistent response generation and vector IO
- **KServe Native Integration**: Kubernetes-native model serving with auto-scaling and versioning

### Optimization Benefits

Whether you've deployed using the [Reference RAG QuickStart](https://github.com/rh-ai-quickstart/RAG) or have your own RAG system, this guide shows you how to leverage RHOAI 3.0 to:

- **Reduce GPU costs by 50%+** through RHOAI 3.0's LLM Compressor quantization
- **Improve throughput by 2x-4x** with RHOAI 3.0's optimized vLLM serving configurations
- **Maximize GPU utilization** from <40% to 85-90% using RHOAI 3.0's memory optimization features
- **Validate improvements** with GuideLLM benchmarking tools integrated with RHOAI 3.0 monitoring

This QuickStart provides:
- Step-by-step model optimization recipes using **RHOAI 3.0's LLM Compressor** (SmoothQuant, GPTQ)
- High-performance inference serving configurations using **RHOAI 3.0's vLLM and llm-d** inference stack
- Performance benchmarking and validation workflows integrated with **RHOAI 3.0 observability**
- Business value documentation with ROI analysis aligned with RHOAI 3.0's AI Factory principles

### Architecture diagrams

![Lean RAG Accelerator Architecture](docs/architecture-diagram.png)

*This diagram illustrates the three-stage optimization approach: Model Optimization → Inference Serving → RAG Application. For more details see [architecture documentation](docs/architecture.md).*

| Layer/Component | Technology | Purpose/Description |
|-----------------|------------|---------------------|
| **Orchestration** | **RHOAI 3.0 AI Factory** | Industrialized model serving with standardized components |
| **Model Optimization** | **RHOAI 3.0 LLM Compressor** | Quantizes models (SmoothQuant/GPTQ) to reduce memory footprint |
| **Inference Runtime** | **RHOAI 3.0 vLLM** | High-performance serving with PagedAttention and optimized batching |
| **Distributed Inference** | **RHOAI 3.0 llm-d** | Separates prefill and decode phases for maximum throughput |
| **Serving Framework** | **RHOAI 3.0 KServe** | Kubernetes-native model serving with auto-scaling |
| **Model Registry** | **RHOAI 3.0 Model Catalog** | Repository of validated, pre-optimized models |
| **RAG Orchestration** | **RHOAI 3.0 Llama Stack API** | Standardized RAG pipeline with consistent API |
| **Document Processing** | Docling | Enterprise document ingestion and chunking |
| **Vector Store** | Milvus/Chroma | Vector database for semantic search |
| **Benchmarking** | GuideLLM | Performance validation integrated with RHOAI 3.0 monitoring |

See [docs/business-value-driver.md](./docs/business-value-driver.md) for detailed problem statement and ROI analysis.

### How This QuickStart Leverages RHOAI 3.0

This QuickStart is built specifically for **Red Hat OpenShift AI 3.0** and demonstrates the platform's key capabilities:

1. **AI Factory Approach**: Implements RHOAI 3.0's industrialized model serving methodology with standardized components, automated workflows, and GitOps integration

2. **LLM Compressor Integration**: Uses RHOAI 3.0's native LLM Compressor for model quantization, reducing memory footprint by 50-75% while maintaining >95% accuracy

3. **RHOAI 3.0 Inference Stack**: Leverages the complete inference stack:
   - **vLLM**: Optimized for maximum throughput with PagedAttention
   - **llm-d**: Distributed inference separating prefill and decode phases
   - **KServe**: Kubernetes-native serving with auto-scaling and versioning

4. **Model Registry Integration**: Can utilize RHOAI 3.0's Model Catalog for validated, pre-optimized models, or optimize your own models using LLM Compressor

5. **Llama Stack API**: Uses RHOAI 3.0's standardized Llama Stack API for consistent RAG orchestration, response generation, and vector IO operations

6. **Observability**: Integrates with RHOAI 3.0's monitoring and observability features for performance tracking and optimization

This QuickStart is not just a deployment guide—it's a demonstration of how RHOAI 3.0's AI Factory approach solves real-world inference economics challenges.

## Requirements

### Minimum hardware requirements

- 1 GPU with 24GB of VRAM for the LLM (NVIDIA A10G, L4, or equivalent)
- Refer to the [supported models chart](#supported-models) for specific hardware requirements
- Additional GPU optional for distributed inference (llm-d)

### Minimum software requirements

- OpenShift Client CLI - [oc](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/cli_tools/openshift-cli-oc#installing-openshift-cli)
- OpenShift Cluster 4.18+
- **Red Hat OpenShift AI (RHOAI) 3.0** with the following components:
  - **AI Factory** infrastructure enabled
  - **LLM Compressor** available for model optimization
  - **vLLM and llm-d** inference engines configured
  - **KServe** installed and configured (included in RHOAI 3.0)
  - **Model Registry/Catalog** accessible
  - **Llama Stack API** available for RAG orchestration
- Storage: PVC or S3-compatible storage for models (RHOAI 3.0 compatible)

### Required user permissions

- Regular user permission for default deployment
- Cluster admin required for advanced configurations (CRD creation, namespace setup)

## Deploy

*The instructions below will help you optimize your RAG deployment for cost and performance.*

*If you don't have a RAG system yet, start with the [Reference RAG QuickStart](https://github.com/rh-ai-quickstart/RAG) to deploy a working RAG application, then return here to optimize it.*

### Prerequisites

- Existing RAG deployment (optional - can optimize during initial setup)
- [Hugging Face Token](https://huggingface.co/settings/tokens) for model access
- Access to [Meta Llama models](https://huggingface.co/meta-llama) (Llama 3.1 8B recommended)
- kubectl configured with cluster access

### Supported Models

| Function   | Model Name                           | Hardware    | Optimization Method |
|------------|--------------------------------------|-------------|---------------------|
| Generation | `meta-llama/Llama-3.1-8B-Instruct`  | A10G/L4/HPU | SmoothQuant (INT8) |
| Generation | `meta-llama/Llama-3.1-8B-Instruct`  | A10G/L4/HPU | GPTQ (INT4)        |
| Generation | `meta-llama/Llama-3.2-3B-Instruct`  | L4/HPU      | SmoothQuant (INT8) |
| Embedding  | `all-MiniLM-L6-v2`                   | CPU/GPU/HPU | N/A (lightweight)  |

**Note**: The optimization recipes in this QuickStart focus on Llama 3.1 8B, but can be adapted for other models. See [examples/01-model-optimization/README.md](./examples/01-model-optimization/README.md) for details.

### Installation Steps

1. **Clone Repository**

```bash
git clone https://github.com/rh-ai-quickstart/lean-rag-accelerator
cd lean-rag-accelerator
```

2. **Login to OpenShift**

```bash
oc login --server="<cluster-api-endpoint>" --token="sha256~XYZ"
```

3. **Hardware Configuration**

Determine what hardware acceleration is available in your cluster and configure accordingly.

**For NVIDIA GPU nodes**: If GPU nodes are tainted, find the taint key:

```bash
oc get nodes -l nvidia.com/gpu.present=true -o yaml | grep -A 3 taint 
```

**For Intel Gaudi HPU nodes**: If HPU nodes are tainted, find the taint key:

```bash
oc get nodes -l habana.ai/gaudi.present=true -o yaml | grep -A 3 taint 
```

The output may show:
```
taints:
  - effect: NoSchedule
    key: nvidia.com/gpu  # or habana.ai/gaudi for HPU
    value: "true"
```

4. **Validate GPU Resources**

```bash
./scripts/validate_gpu_resources.sh
```

5. **Deploy Optimization Components**

You can deploy all components at once using the bootstrap script, or deploy step-by-step:

**Option A: Makefile Deployment (Recommended)**

```bash
# Show available commands
make help

# Validate prerequisites
make validate

# Deploy all components
make deploy-all NAMESPACE=lean-rag-accelerator

# Or deploy step-by-step
make optimize-model NAMESPACE=lean-rag-accelerator
make deploy-inference NAMESPACE=lean-rag-accelerator
make deploy-rag NAMESPACE=lean-rag-accelerator
```

**Option B: Bootstrap Script**

```bash
./bootstrap.sh
```

The script will:
- Check prerequisites (kubectl, cluster access, GPU resources)
- Validate your environment
- Deploy components interactively
- Provide next steps

**Option B: Manual Step-by-Step Deployment**

**Step 1: Model Optimization with RHOAI 3.0 LLM Compressor**

```bash
cd examples/01-model-optimization

# Review and customize the RHOAI 3.0 LLM Compressor quantization recipe
# Update model source (can use RHOAI 3.0 Model Registry), storage, and calibration dataset
vim quantization-recipe.yaml

# Apply quantization recipe (uses RHOAI 3.0 LLM Compressor)
kubectl apply -f quantization-recipe.yaml

# Monitor quantization job (this may take 30-60 minutes)
# RHOAI 3.0 provides observability for the compression process
kubectl get quantizationrecipe llama-3.1-8b-quantization -w

# Or use the Jupyter notebook for interactive quantization with RHOAI 3.0 LLM Compressor
# See notebook.ipynb for step-by-step guidance
```

**Step 2: Inference Serving with RHOAI 3.0 Inference Stack**

```bash
cd ../02-inference-serving

# Update RHOAI 3.0 vLLM runtime configuration with your optimized model storage
# The model can be from RHOAI 3.0 Model Registry or your storage
vim vllm-runtime.yaml

# Deploy RHOAI 3.0 vLLM runtime (part of RHOAI 3.0 Inference Stack)
kubectl apply -f vllm-runtime.yaml

# Deploy KServe inference service (RHOAI 3.0 native integration)
kubectl apply -f kserve-inferenceservice.yaml

# Optional: Deploy RHOAI 3.0 llm-d for distributed inference (higher throughput)
# llm-d is part of RHOAI 3.0's AI Factory inference stack
kubectl apply -f llm-d-configuration.yaml
```

**Step 3: RAG Application with RHOAI 3.0 Llama Stack** (if not already deployed)

```bash
cd ../03-rag-application

# Deploy RAG pipeline using RHOAI 3.0 Llama Stack API
# Llama Stack provides standardized RAG orchestration in RHOAI 3.0
kubectl apply -f rag-pipeline.yaml

# Deploy document ingestion job
kubectl apply -f docling-job.yaml
```

**Step 4: Validation and Benchmarking**

```bash
cd ../benchmarks

# Deploy GuideLLM benchmarking configuration
kubectl apply -f guidellm-config.yaml

# Monitor benchmark results
# See docs/benchmarks.md for detailed performance reports
```

6. **Monitor Deployment**

```bash
# Check inference service status
kubectl get inferenceservice lean-rag-inference

# Watch pods (wait for all to reach Running status)
oc get pods -n <your-namespace> -w

# Key pods to watch:
oc get pods -l component=predictor
```

Look for **3/3** under the Ready column for predictor pods.

7. **Verify Installation**

```bash
# Get inference service endpoint
INGRESS_HOST=$(kubectl get inferenceservice lean-rag-inference -o jsonpath='{.status.url}')

# Test inference
curl -X POST $INGRESS_HOST/v1/completions \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Hello, world!", "max_tokens": 50}'
```

For detailed post-installation verification, configuration options, and usage instructions, see the [complete deployment guide](docs/deployment-guide.md).

### Optimizing Existing RAG Deployments

If you already have a RAG deployment (e.g., from the [Reference RAG QuickStart](https://github.com/rh-ai-quickstart/RAG)), you can optimize it:

1. **Export your current model configuration**
2. **Apply quantization recipe** from `examples/01-model-optimization/`
3. **Update your InferenceService** to use the optimized model
4. **Apply vLLM optimizations** from `examples/02-inference-serving/`
5. **Run benchmarks** to validate improvements

See [docs/optimizing-existing-rag.md](./docs/optimizing-existing-rag.md) for detailed instructions.

## Directory Structure

```
lean-rag-accelerator/
├── bootstrap.sh                     # Interactive deployment script
├── README.md                        # This file
├── docs/                            # Documentation
│   ├── business-value-driver.md     # Business narrative and ROI
│   ├── architecture.md              # Technical architecture
│   ├── architecture-diagram.png     # Visual architecture (placeholder)
│   └── benchmarks.md                # GuideLLM benchmark reports
├── examples/                        # Core deployment components
│   ├── 01-model-optimization/       # LLM Compressor stage
│   │   ├── quantization-recipe.yaml # Quantization config
│   │   ├── model-config.yaml        # Model metadata
│   │   └── notebook.ipynb           # Jupyter notebook for compression
│   ├── 02-inference-serving/        # vLLM & llm-d stage
│   │   ├── vllm-runtime.yaml        # ServingRuntime with PagedAttention
│   │   ├── llm-d-configuration.yaml # Distributed inference config
│   │   └── kserve-inferenceservice.yaml # KServe definition
│   └── 03-rag-application/          # RAG pipeline stage
│       ├── rag-pipeline.yaml        # Llama Stack config
│       ├── docling-job.yaml         # Document ingestion job
│       ├── docling-config.yaml      # Docling configuration
│       └── vector-store-config.yaml # Vector DB config
├── charts/                          # Helm charts for GitOps
│   └── argocd-appgenerator/         # ArgoCD Application generator
└── scripts/                         # Utility scripts
    └── validate_gpu_resources.sh    # GPU resource validation
```

## Expected Results

After optimization, you should see:

- **Throughput**: 2x to 4x improvement over baseline
- **GPU Utilization**: Increased from <40% to 85-90%
- **Cost Reduction**: 50%+ reduction in GPU requirements
- **Latency**: Maintained or improved response times (TTFT <100ms)
- **Memory Efficiency**: 50-75% reduction in model memory footprint

See [docs/benchmarks.md](./docs/benchmarks.md) for GuideLLM benchmark reports and detailed performance metrics.

## Troubleshooting

Common issues and solutions:

- **Model loading failures**: Check storage URI and permissions in quantization recipe
- **GPU out of memory**: Reduce `--gpu-memory-utilization` in vLLM runtime (try 0.7 instead of 0.9)
- **Quantization job fails**: Verify calibration dataset is accessible and properly formatted
- **Inference service unavailable**: Check model storage path and KServe configuration
- **Vector store connection errors**: Verify Milvus/Chroma deployment and network policies

For more troubleshooting guidance, see [docs/troubleshooting.md](./docs/troubleshooting.md).

## Additional Resources

### Red Hat OpenShift AI 3.0 Resources

- [Red Hat OpenShift AI 3.0 Documentation](https://docs.redhat.com/) - Complete RHOAI 3.0 platform documentation
- [RHOAI 3.0 AI Factory Guide](https://docs.redhat.com/) - Industrialized model serving approach
- [RHOAI 3.0 Inference Stack](https://docs.redhat.com/) - vLLM, llm-d, and KServe integration
- [RHOAI 3.0 Model Registry](https://docs.redhat.com/) - Model catalog and management
- [RHOAI 3.0 LLM Compressor](https://docs.redhat.com/) - Model quantization and optimization

### QuickStart Resources

- [Reference RAG QuickStart](https://github.com/rh-ai-quickstart/RAG) - Deploy a complete RAG application
- [KServe Documentation](https://kserve.github.io/website/) - Kubernetes-native model serving
- [vLLM Documentation](https://docs.vllm.ai/) - High-performance inference engine
- [Llama Stack Documentation](https://llamastack.ai/) - Standardized RAG API

## Tags

* **Product:** Red Hat OpenShift AI 3.0
* **RHOAI 3.0 Capabilities:** AI Factory, LLM Compressor, vLLM, llm-d, Model Registry, Llama Stack API
* **Use case:** RAG Optimization, Cost Reduction, Performance Tuning, Industrialized Model Serving
* **Business challenge:** Reduce inference costs, Scale AI deployments, Address GPU underutilization
* **Technology:** RHOAI 3.0 Inference Stack, LLM Compressor, vLLM, llm-d, KServe, Llama Stack

