# Architecture: Lean RAG Accelerator

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Lean RAG Accelerator                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐    ┌──────────────────┐               │
│  │  Model          │    │  Inference       │               │
│  │  Optimization   │───▶│  Serving         │               │
│  │  (LLM Compressor)│    │  (vLLM + llm-d   │               │
│  └──────────────────┘    │   + KServe)      │               │
│                          └──────────────────┘               │
│         │                        │                            │
│         │                        ▼                            │
│         │              ┌──────────────────┐                  │
│         │              │  RAG Application  │                  │
│         │              │  (Llama Stack)    │                  │
│         │              └──────────────────┘                  │
│         │                        │                            │
│         └────────────────────────┼──────────────────────────┘
│                                  │                            │
│                                  ▼                            │
│                        ┌──────────────────┐                  │
│                        │  Vector Store     │                  │
│                        │  (Milvus/Chroma)  │                  │
│                        └──────────────────┘                  │
│                                  │                            │
│                                  ▼                            │
│                        ┌──────────────────┐                  │
│                        │  Document         │                  │
│                        │  Ingestion        │                  │
│                        │  (Docling)        │                  │
│                        └──────────────────┘                  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Component Overview

### 1. Model Optimization Layer

**Technology**: LLM Compressor  
**Purpose**: Reduce model size and memory footprint  
**Methods**: SmoothQuant, GPTQ  
**Output**: Quantized model (INT8/INT4)

**Key Benefits**:
- Reduced memory requirements
- Faster inference
- Lower GPU costs

### 2. Inference Serving Layer

**Technology**: vLLM + llm-d + KServe  
**Purpose**: High-performance model serving with cloud-native orchestration

**vLLM: The High-Performance Engine**
- State-of-the-art inference engine designed for raw speed and efficiency
- Optimizations:
  - `--gpu-memory-utilization=0.9`: Maximize GPU usage
  - `--kv-cache-dtype=fp8`: Memory-efficient KV cache
  - PagedAttention for efficient memory management
  - Tensor parallelism for scaling
- Executes inference workloads and manages GPU memory on the node

**llm-d: The Cloud-Native Orchestrator**
- Orchestrates vLLM instances for production-scale deployments
- Key capabilities:
  - Independent scaling of prefill and decode workers (disaggregation)
  - Expert-parallel scheduling for MoE models
  - KV cache-aware routing for prefix cache reuse
  - Kubernetes-native elasticity with KEDA and ArgoCD
  - Granular telemetry with per-token metrics

**KServe: The Serving Framework**
- Kubernetes-native model serving framework
- Standardized API and integration layer

**Key Benefits**:
- High throughput (vLLM engine)
- Low latency (optimized memory management)
- Efficient GPU utilization
- Production-ready scaling and orchestration (llm-d)
- Cloud-native elasticity and observability

### 3. RAG Application Layer

**Technology**: Llama Stack + Docling  
**Purpose**: Standardized RAG pipeline  
**Components**:
- Document ingestion (Docling)
- Vector store integration (Milvus/Chroma)
- Response generation (standardized API)

**Key Benefits**:
- Consistent API
- Easy integration
- Scalable architecture

## Technology Stack

### Core Technologies

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Model Optimization | LLM Compressor | [TBD] | Quantization |
| Inference Engine | vLLM | [TBD] | High-performance model serving |
| Orchestration | llm-d | [TBD] | Cloud-native distributed inference |
| Serving Framework | KServe | [TBD] | Kubernetes-native serving |
| RAG Orchestration | Llama Stack | [TBD] | RAG pipeline |
| Document Processing | Docling | [TBD] | Document ingestion |
| Vector Store | Milvus/Chroma | [TBD] | Vector database |
| Benchmarking | GuideLLM | [TBD] | Performance testing |

### Infrastructure

- **Platform**: Red Hat OpenShift AI 3.0
- **Orchestration**: Kubernetes
- **GPU**: NVIDIA A10G or equivalent
- **Storage**: PVC or S3-compatible

## Data Flow

1. **Document Ingestion**
   - Documents (PDFs, etc.) → Docling → Chunked text → Vector embeddings

2. **Vector Storage**
   - Embeddings → Vector Store (Milvus/Chroma) → Indexed for retrieval

3. **Query Processing**
   - User query → Embedding → Vector search → Retrieved chunks

4. **Response Generation**
   - Retrieved chunks + Query → Optimized LLM (vLLM) → Generated response

## Design Decisions

### Why LLM Compressor?

- Industry-standard quantization tool
- Supports multiple quantization methods
- Integrates with RHOAI 3.0

### Why vLLM?

- High-performance inference engine designed for raw speed and efficiency
- Optimized memory management through PagedAttention
- Enterprise-grade with innovations like speculative decoding and tensor parallelism
- Ideal for single node or well-tuned multi-GPU clusters

### Why llm-d?

- Cloud-native distributed inference framework that orchestrates vLLM
- Enables production-scale deployments with disaggregated prefill/decode phases
- Provides Kubernetes-native elasticity, KV cache-aware routing, and expert-parallel scheduling
- Transforms a high-performance engine into a championship-ready inference system
- Note: llm-d does not replace vLLM—it enhances it by providing orchestration capabilities

### Why Llama Stack?

- Standardized RAG API
- Easy integration with vector stores
- Consistent response format

### Why Docling?

- Enterprise document processing
- Handles complex PDFs
- Structured output format

## Integration Points

### With RHOAI 3.0

- Uses KServe for model serving
- Leverages RHOAI model registry
- Integrates with RHOAI monitoring

### With Vector Stores

- Supports multiple backends (Milvus, Chroma)
- Standardized API via Llama Stack
- Easy to switch providers

### With Storage

- Model storage: PVC or S3
- Vector store: Persistent volumes
- Document storage: Configurable

## Scalability Considerations

### Horizontal Scaling

- Inference service: Multiple replicas
- Vector store: Cluster mode
- RAG application: Stateless design

### Vertical Scaling

- GPU allocation: Configurable per service
- Memory: Optimized through quantization
- CPU: Shared resources

## Security Considerations

- Model access: RBAC via Kubernetes
- Data encryption: At rest and in transit
- Network policies: Isolated namespaces
- Authentication: OAuth/OIDC integration

## Monitoring & Observability

- Metrics: Prometheus integration
- Logging: Centralized logging
- Tracing: Distributed tracing support
- Alerts: Performance and error alerts

## Future Enhancements

- Multi-model support
- Advanced caching strategies
- Auto-scaling based on load
- Cost optimization recommendations

