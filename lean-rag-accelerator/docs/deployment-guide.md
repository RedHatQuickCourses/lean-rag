# Complete Deployment Guide

This guide provides comprehensive instructions for deploying the Lean RAG Accelerator from scratch.

## Overview

The Lean RAG Accelerator deployment consists of three main stages:

1. **Model Optimization**: Quantize models using LLM Compressor
2. **Inference Serving**: Deploy optimized models with vLLM
3. **RAG Application**: Set up RAG pipeline with Llama Stack

## Prerequisites

### Cluster Requirements

- OpenShift 4.18+
- Red Hat OpenShift AI (RHOAI) 3.0 installed
- KServe installed and configured
- GPU nodes available (NVIDIA A10G, L4, or equivalent)
- Storage: PVC or S3-compatible storage for models

### Software Requirements

- `oc` CLI configured with cluster access
- `kubectl` configured
- Hugging Face token ([get one here](https://huggingface.co/settings/tokens))

### Permissions

- Regular user permissions for default deployment
- Cluster admin for advanced configurations (CRD creation)

## Pre-Deployment Validation

### 1. Verify Cluster Access

```bash
oc whoami
oc get nodes
```

### 2. Check GPU Availability

```bash
# For NVIDIA GPUs
oc get nodes -l nvidia.com/gpu.present=true

# For Intel Gaudi HPUs
oc get nodes -l habana.ai/gaudi.present=true
```

### 3. Verify KServe Installation

```bash
oc get crd | grep kserve
oc get inferenceservice -A
```

### 4. Check Storage

```bash
# List available PVCs
oc get pvc -A

# Or verify S3 access if using S3 storage
```

### 5. Run Validation Script

```bash
./scripts/validate_gpu_resources.sh
```

## Stage 1: Model Optimization

### Step 1.1: Prepare Quantization Recipe

1. **Navigate to model optimization directory**:

```bash
cd examples/01-model-optimization
```

2. **Review quantization recipe**:

```bash
cat quantization-recipe.yaml
```

3. **Update configuration**:

Key parameters to configure:
- `model.source.uri`: Model location (HuggingFace, S3, PVC)
- `quantization.calibration.dataset`: Calibration dataset location
- `output.storage`: Where to store optimized model

Example for HuggingFace model:

```yaml
spec:
  model:
    name: meta-llama/Llama-3.1-8B-Instruct
    source:
      uri: huggingface://meta-llama/Llama-3.1-8B-Instruct
      format: safetensors
  quantization:
    method: smoothquant
    targetPrecision: int8
    calibration:
      dataset: <your-calibration-dataset-uri>
      numSamples: 512
  output:
    storage:
      type: pvc
      pvc:
        name: model-storage-pvc
        path: models/llama-3.1-8b-quantized
```

### Step 1.2: Apply Quantization Recipe

```bash
kubectl apply -f quantization-recipe.yaml
```

### Step 1.3: Monitor Quantization Job

```bash
# Watch quantization recipe status
kubectl get quantizationrecipe llama-3.1-8b-quantization -w

# Check job logs
kubectl get jobs -l app=quantization
kubectl logs -l app=quantization --tail=100 -f

# Describe for detailed status
kubectl describe quantizationrecipe llama-3.1-8b-quantization
```

### Step 1.4: Verify Optimized Model

Once complete, verify the optimized model:

```bash
# Get optimized model location
kubectl get quantizationrecipe llama-3.1-8b-quantization -o jsonpath='{.status.output.storage.uri}'

# Verify model exists (if using PVC)
oc rsh <pod-with-pvc-access> ls -lh <model-path>
```

**Expected Duration**: 30-60 minutes depending on model size

## Stage 2: Inference Serving

### Step 2.1: Configure vLLM Runtime

1. **Navigate to inference serving directory**:

```bash
cd ../02-inference-serving
```

2. **Update vLLM runtime configuration**:

Key parameters in `vllm-runtime.yaml`:
- `image`: vLLM container image
- `args`: Optimization parameters
- `volumes`: Model storage mount

Update model storage:

```yaml
volumes:
  - name: model-storage
    persistentVolumeClaim:
      claimName: model-storage-pvc  # Your PVC name
```

### Step 2.2: Deploy vLLM Runtime

```bash
kubectl apply -f vllm-runtime.yaml
```

Verify deployment:

```bash
kubectl get servingruntime vllm-runtime
```

### Step 2.3: Configure Inference Service

1. **Update InferenceService**:

In `kserve-inferenceservice.yaml`, update:
- `storageUri`: Location of optimized model from Stage 1
- `namespace`: Your target namespace
- `resources`: GPU requirements

Example:

```yaml
spec:
  predictor:
    model:
      storageUri: pvc://model-storage-pvc/models/llama-3.1-8b-quantized
    runtime: vllm-runtime
    resources:
      limits:
        nvidia.com/gpu: 1
```

2. **Apply InferenceService**:

```bash
kubectl apply -f kserve-inferenceservice.yaml
```

### Step 2.4: Monitor Inference Service

```bash
# Watch service status
kubectl get inferenceservice lean-rag-inference -w

# Check pods
kubectl get pods -l serving.kserve.io/inferenceservice=lean-rag-inference

# Wait for predictor pod to be Ready (3/3)
kubectl get pods -l component=predictor
```

### Step 2.5: Verify Inference Service

```bash
# Get service endpoint
INGRESS_HOST=$(kubectl get inferenceservice lean-rag-inference -o jsonpath='{.status.url}')

# Test inference
curl -X POST $INGRESS_HOST/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "What is the capital of France?",
    "max_tokens": 50,
    "temperature": 0.7
  }'
```

**Expected Duration**: 10-20 minutes for model loading

### Step 2.6: Optional - Deploy llm-d for Distributed Inference

For higher throughput, deploy llm-d:

```bash
kubectl apply -f llm-d-configuration.yaml
```

This separates prefill and decode phases for maximum efficiency.

## Stage 3: RAG Application

### Step 3.1: Configure RAG Pipeline

1. **Navigate to RAG application directory**:

```bash
cd ../03-rag-application
```

2. **Update RAG pipeline configuration**:

In `rag-pipeline.yaml`, configure:
- `responseGeneration.modelEndpoint`: Your inference service endpoint
- `vectorStore.provider`: Milvus or Chroma
- `ingestion.provider`: Docling configuration

Example:

```yaml
spec:
  responseGeneration:
    modelEndpoint: http://lean-rag-inference.default.svc.cluster.local
  vectorStore:
    provider: milvus
    config:
      collectionName: lean-rag-docs
  ingestion:
    provider: docling
```

### Step 3.2: Deploy RAG Pipeline

```bash
kubectl apply -f rag-pipeline.yaml
```

### Step 3.3: Configure Document Ingestion

1. **Update Docling configuration**:

In `docling-config.yaml`, configure:
- Document sources (S3, PVC, URLs)
- Chunking strategy
- Embedding model

2. **Deploy ingestion job**:

```bash
kubectl apply -f docling-job.yaml
```

### Step 3.4: Verify RAG Pipeline

```bash
# Check pipeline status
kubectl get ragpipeline lean-rag-pipeline

# Check ingestion job
kubectl get jobs -l app=docling-ingestion

# Test RAG query
curl -X POST <rag-pipeline-endpoint>/query \
  -H "Content-Type: application/json" \
  -d '{"query": "What is in the documents?"}'
```

## Stage 4: Validation and Benchmarking

### Step 4.1: Deploy Benchmarking

```bash
cd ../benchmarks
kubectl apply -f guidellm-config.yaml
```

### Step 4.2: Run Benchmarks

```bash
# Monitor benchmark job
kubectl get guidellmconfig -w

# Check benchmark results
kubectl get guidellmconfig lean-rag-benchmark -o yaml
```

### Step 4.3: Review Performance Metrics

See [benchmarks/performance-baseline.md](../benchmarks/performance-baseline.md) for expected metrics.

Compare your results:
- **Throughput**: Should be 2x-4x baseline
- **GPU Utilization**: Should be 85-90%
- **Latency**: TTFT <100ms, ITL <50ms

## Post-Deployment

### Verify All Components

```bash
# Check all pods are running
oc get pods -n <your-namespace>

# Verify services
oc get svc -n <your-namespace>

# Check routes (if exposed)
oc get routes -n <your-namespace>
```

### Test End-to-End

1. **Ingest a test document**:

```bash
# Upload document to S3 or PVC
# Trigger ingestion job
kubectl create job --from=cronjob/docling-ingestion test-ingestion-$(date +%s)
```

2. **Query RAG system**:

```bash
curl -X POST <rag-endpoint>/query \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Your test question",
    "max_tokens": 200
  }'
```

### Monitor Performance

```bash
# Check GPU utilization
oc get pods -l component=predictor -o jsonpath='{.items[*].metadata.name}' | \
  xargs -I {} kubectl exec {} -- nvidia-smi

# Check inference metrics
curl <inference-service-endpoint>/metrics
```

## Troubleshooting

See [troubleshooting guide](troubleshooting.md) for common issues and solutions.

## Next Steps

- Review [architecture documentation](architecture.md)
- Explore [business value analysis](business-value-driver.md)
- Optimize further based on benchmark results

## Related Resources

- [Optimizing Existing RAG](optimizing-existing-rag.md) - Apply to existing deployments
- [Reference RAG QuickStart](https://github.com/rh-ai-quickstart/RAG) - Full RAG application
- [Troubleshooting Guide](troubleshooting.md) - Common issues and solutions

