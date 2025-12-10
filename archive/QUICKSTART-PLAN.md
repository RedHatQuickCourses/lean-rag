# Lean RAG Accelerator QuickStart - Implementation Plan

## Overview
This document outlines the plan for creating a deployable Lean RAG Accelerator quickstart that customers can bring into their environment to experiment with. The quickstart includes both business value documentation and deployable code.

## Project Structure

```
lean-rag-accelerator/
├── README.md                          # Main quickstart overview and getting started
├── BUSINESS-VALUE.md                  # Problem statement, ROI, use cases
├── ARCHITECTURE.md                    # Technical architecture and design decisions
│
├── 01-model-optimization/
│   ├── README.md                      # Explanation of model optimization approach
│   ├── quantization-recipe.yaml      # LLM Compressor configuration (SmoothQuant/GPTQ)
│   └── model-config.yaml              # Model-specific settings for Llama 3.1 8B
│
├── 02-inference-serving/
│   ├── README.md                      # Inference serving setup guide
│   ├── vllm-runtime.yaml              # KServe ServingRuntime CRD for vLLM
│   ├── inference-service.yaml         # KServe InferenceService definition
│   └── llm-d-config.yaml              # llm-d configuration (if needed)
│
├── 03-rag-application/
│   ├── README.md                      # RAG application setup guide
│   ├── rag-pipeline.yaml              # Llama Stack pipeline configuration
│   ├── docling-config.yaml            # Docling ingestion configuration
│   └── vector-store-config.yaml       # Vector database configuration (Milvus/Chroma)
│
├── benchmarks/
│   ├── README.md                      # Benchmarking guide
│   ├── guidellm-config.yaml           # GuideLLM benchmarking configuration
│   └── performance-baseline.md         # Expected performance metrics
│
└── deployment/
    ├── README.md                      # Deployment instructions
    ├── bootstrap.sh                   # GitOps bootstrap script (if needed)
    └── argocd-app.yaml                # ArgoCD application manifest (if needed)
```

## File Specifications

### 1. Business Value Documentation

#### BUSINESS-VALUE.md
**Purpose**: Articulate the business problem and ROI
**Content**:
- Problem Statement: Critical GPU Underutilization
- Cost Reduction Opportunities
- Performance Improvements (2x to 4x throughput)
- Use Cases and Scenarios
- ROI Calculator/Estimates

#### ARCHITECTURE.md
**Purpose**: Technical architecture documentation
**Content**:
- System Architecture Diagram
- Component Interactions
- Technology Stack Justification
- Design Decisions
- Integration Points

### 2. Model Optimization (`01-model-optimization/`)

#### quantization-recipe.yaml
**Purpose**: LLM Compressor quantization configuration
**Key Parameters**:
- Model: Llama 3.1 8B
- Quantization Method: SmoothQuant or GPTQ
- Target Precision: INT8 or INT4
- Calibration Dataset: (to be specified)
- Output Format: ONNX or native format

**Structure**:
```yaml
apiVersion: ai.redhat.com/v1alpha1
kind: QuantizationRecipe
metadata:
  name: llama-3.1-8b-quantization
spec:
  model:
    name: meta-llama/Llama-3.1-8B
    baseModel: llama-3.1-8b
  quantization:
    method: smoothquant  # or gptq
    targetPrecision: int8
    calibrationDataset: <dataset-reference>
  output:
    format: onnx
    storage: <pvc-or-s3-reference>
```

### 3. Inference Serving (`02-inference-serving/`)

#### vllm-runtime.yaml
**Purpose**: KServe ServingRuntime for vLLM
**Key Parameters**:
- Image: vLLM container image
- GPU Memory Utilization: Optimized settings
- KV Cache Dtype: fp8 for memory efficiency
- Tensor Parallelism: (to be configured)
- Max Model Length: (model-specific)

**Structure**:
```yaml
apiVersion: serving.kserve.io/v1alpha1
kind: ServingRuntime
metadata:
  name: vllm-runtime
spec:
  supportedModelFormats:
    - name: llama
      version: "1"
      autoSelect: true
  multiModel: false
  grpcDataEndpoint: port:8001
  containers:
    - name: vllm
      image: <vllm-image>
      args:
        - --gpu-memory-utilization=0.9
        - --kv-cache-dtype=fp8
        - --tensor-parallel-size=1
      resources:
        limits:
          nvidia.com/gpu: 1
```

#### inference-service.yaml
**Purpose**: KServe InferenceService definition
**Key Parameters**:
- Model Location: PVC or S3 bucket reference
- GPU Resources: 1x NVIDIA A10G (or equivalent)
- Scaling: Min/max replicas
- Model Format: Optimized model from step 1

**Structure**:
```yaml
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: lean-rag-inference
spec:
  predictor:
    model:
      modelFormat:
        name: llama
      storageUri: <optimized-model-uri>
    runtime: vllm-runtime
    resources:
      limits:
        nvidia.com/gpu: 1
```

### 4. RAG Application (`03-rag-application/`)

#### rag-pipeline.yaml
**Purpose**: Llama Stack pipeline configuration
**Key Components**:
- Document Ingestion: Docling integration
- Vector Store: Milvus or Chroma configuration
- Response Generation: Standardized API endpoints
- Retrieval Strategy: Embedding model and chunking strategy

**Structure**:
```yaml
apiVersion: llama.redhat.com/v1alpha1
kind: RAGPipeline
metadata:
  name: lean-rag-pipeline
spec:
  ingestion:
    provider: docling
    config:
      chunkSize: 512
      chunkOverlap: 50
  vectorStore:
    provider: milvus  # or chroma
    config:
      collectionName: lean-rag-docs
      embeddingModel: <embedding-model-reference>
  responseGeneration:
    modelEndpoint: <inference-service-endpoint>
    temperature: 0.7
    maxTokens: 512
```

#### docling-config.yaml
**Purpose**: Docling document processing configuration
**Key Parameters**:
- Supported Formats: PDF, DOCX, etc.
- Processing Pipeline: OCR, table extraction, etc.
- Output Format: Structured chunks

### 5. Benchmarks (`benchmarks/`)

#### guidellm-config.yaml
**Purpose**: GuideLLM benchmarking configuration
**Key Parameters**:
- Test Scenarios: Various load patterns
- Metrics: Throughput, latency, TTFT, ITL
- Baseline: Before optimization metrics
- Target: After optimization metrics (2x-4x improvement)

**Structure**:
```yaml
apiVersion: benchmark.redhat.com/v1alpha1
kind: GuideLLMConfig
metadata:
  name: lean-rag-benchmark
spec:
  targetEndpoint: <inference-service-endpoint>
  scenarios:
    - name: baseline
      concurrentUsers: 10
      requestsPerSecond: 5
      duration: 300s
    - name: optimized
      concurrentUsers: 20
      requestsPerSecond: 10
      duration: 300s
  metrics:
    - throughput
    - latency
    - timeToFirstToken
    - interTokenLatency
```

## Implementation Phases

### Phase 1: Planning & Structure ✅
- [x] Create plan document
- [x] Define folder structure
- [ ] Gather business value context from NotebookLM
- [ ] Review architecture requirements

### Phase 2: Business Value Documentation
- [ ] Draft BUSINESS-VALUE.md with problem statement
- [ ] Create ARCHITECTURE.md with technical details
- [ ] Add ROI calculations and use cases
- [ ] Create presentation slides (optional)

### Phase 3: Model Optimization
- [ ] Create quantization-recipe.yaml
- [ ] Document LLM Compressor parameters
- [ ] Add model-config.yaml with Llama 3.1 8B settings
- [ ] Test quantization recipe (if environment available)

### Phase 4: Inference Serving
- [ ] Create vllm-runtime.yaml with optimized settings
- [ ] Create inference-service.yaml
- [ ] Document GPU resource requirements
- [ ] Add llm-d configuration if needed

### Phase 5: RAG Application
- [ ] Create rag-pipeline.yaml for Llama Stack
- [ ] Configure Docling for document ingestion
- [ ] Set up vector store configuration
- [ ] Document API endpoints and usage

### Phase 6: Benchmarks & Validation
- [ ] Create guidellm-config.yaml
- [ ] Document expected performance metrics
- [ ] Create before/after comparison guide
- [ ] Add validation scripts

### Phase 7: Deployment & Documentation
- [ ] Create deployment scripts/instructions
- [ ] Add GitOps configuration (if applicable)
- [ ] Write comprehensive README.md
- [ ] Add troubleshooting guide

## Dependencies & Prerequisites

### Required Infrastructure
- Red Hat OpenShift AI (RHOAI) 3.0
- KServe installed and configured
- GPU nodes available (NVIDIA A10G or equivalent)
- Storage: PVC or S3-compatible storage for models
- Vector database: Milvus or Chroma

### Required Tools
- LLM Compressor (for model optimization)
- vLLM (for inference serving)
- llm-d (optional, for additional serving capabilities)
- Docling (for document ingestion)
- Llama Stack (for RAG orchestration)
- GuideLLM (for benchmarking)

### Required Access
- Cluster admin or appropriate permissions
- Access to model registry/storage
- Ability to create CRDs and deployments

## Next Steps

1. **Gather Context**: Receive NotebookLM context for business value documentation
2. **Review Architecture**: Validate technical approach with existing modules
3. **Create Templates**: Generate initial YAML/config files with placeholders
4. **Iterate**: Refine based on feedback and testing
5. **Validate**: Test deployment in target environment (if available)

## Notes

- All YAML structures are initial templates and may need adjustment based on actual API specifications
- Configuration values marked with `<placeholder>` need to be filled in with actual values
- This plan follows the "ai-accelerator-examples" repository structure standards
- The quickstart should be self-contained and deployable without external dependencies (except infrastructure)

