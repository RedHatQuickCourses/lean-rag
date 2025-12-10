# Optimizing Existing RAG Deployments

This guide shows you how to optimize an existing RAG deployment, such as one created with the [Reference RAG QuickStart](https://github.com/rh-ai-quickstart/RAG).

## Overview

If you already have a working RAG system, you can apply the Lean RAG Accelerator optimizations to:
- Reduce GPU costs by 50%+
- Improve throughput by 2x-4x
- Increase GPU utilization from <40% to 85-90%

## Prerequisites

- Existing RAG deployment (e.g., from Reference RAG QuickStart)
- Access to the cluster where your RAG is deployed
- kubectl configured with appropriate permissions
- Hugging Face token for model access

## Step-by-Step Optimization

### Step 1: Export Current Configuration

First, export your current model and inference service configuration:

```bash
# Export current InferenceService
kubectl get inferenceservice <your-inference-service-name> -o yaml > current-inference-service.yaml

# Export current model configuration (if using custom runtime)
kubectl get servingruntime <your-runtime-name> -o yaml > current-runtime.yaml

# Note your current model location/storage URI
kubectl get inferenceservice <your-inference-service-name> -o jsonpath='{.spec.predictor.model.storageUri}'
```

### Step 2: Optimize the Model

1. **Navigate to model optimization directory**:

```bash
cd examples/01-model-optimization
```

2. **Update quantization recipe** with your current model:

```yaml
# In quantization-recipe.yaml, update:
spec:
  model:
    name: <your-current-model>  # e.g., meta-llama/Llama-3.1-8B-Instruct
    source:
      uri: <your-current-model-storage-uri>
```

3. **Apply quantization recipe**:

```bash
kubectl apply -f quantization-recipe.yaml
```

4. **Monitor quantization job**:

```bash
kubectl get quantizationrecipe -w
kubectl describe quantizationrecipe llama-3.1-8b-quantization
```

5. **Wait for completion** (30-60 minutes depending on model size):

```bash
# Check job status
kubectl get jobs -l app=quantization

# Once complete, note the optimized model location
kubectl get quantizationrecipe llama-3.1-8b-quantization -o jsonpath='{.status.output.storage.uri}'
```

### Step 3: Update Inference Service with Optimized Model

1. **Navigate to inference serving directory**:

```bash
cd ../02-inference-serving
```

2. **Update vLLM runtime** (if not already using vLLM):

```bash
# Apply optimized vLLM runtime
kubectl apply -f vllm-runtime.yaml
```

3. **Update InferenceService** to use optimized model:

```yaml
# Update kserve-inferenceservice.yaml:
spec:
  predictor:
    model:
      storageUri: <optimized-model-uri-from-step-2>
    runtime: vllm-runtime  # Use optimized runtime
```

4. **Apply updated InferenceService**:

```bash
kubectl apply -f kserve-inferenceservice.yaml
```

5. **Verify deployment**:

```bash
kubectl get inferenceservice lean-rag-inference
kubectl get pods -l serving.kserve.io/inferenceservice=lean-rag-inference
```

### Step 4: Apply vLLM Optimizations

If you're already using vLLM, update your runtime configuration with optimizations:

1. **Review current runtime configuration**:

```bash
kubectl get servingruntime <your-runtime-name> -o yaml
```

2. **Compare with optimized configuration** in `vllm-runtime.yaml`:

Key optimizations to add:
- `--gpu-memory-utilization=0.9` (maximize GPU usage)
- `--kv-cache-dtype=fp8` (memory-efficient KV cache)
- `--tensor-parallel-size=1` (adjust based on GPU count)

3. **Update your runtime** or create a new optimized runtime:

```bash
kubectl apply -f vllm-runtime.yaml
```

4. **Update InferenceService** to use optimized runtime:

```bash
kubectl patch inferenceservice <your-service> --type='merge' -p='{"spec":{"predictor":{"runtime":"vllm-runtime"}}}'
```

### Step 5: Update RAG Pipeline (Optional)

If you want to optimize the RAG pipeline itself:

1. **Navigate to RAG application directory**:

```bash
cd ../03-rag-application
```

2. **Review current RAG pipeline configuration**:

```bash
# If using Llama Stack
kubectl get ragpipeline <your-pipeline-name> -o yaml
```

3. **Update pipeline** to use optimized inference service:

```yaml
# In rag-pipeline.yaml, update:
spec:
  responseGeneration:
    modelEndpoint: <your-optimized-inference-service-endpoint>
```

4. **Apply updated pipeline**:

```bash
kubectl apply -f rag-pipeline.yaml
```

### Step 6: Validate Improvements

1. **Run benchmarks**:

```bash
cd ../benchmarks
kubectl apply -f guidellm-config.yaml
```

2. **Compare performance**:

- **Before**: Baseline metrics from your original deployment
- **After**: New metrics from optimized deployment

Expected improvements:
- Throughput: 2x-4x increase
- GPU Utilization: 85-90% (up from <40%)
- Cost per request: 50%+ reduction
- Latency: Maintained or improved

3. **Review benchmark reports**:

```bash
# Check GuideLLM results
kubectl get guidellmconfig -o yaml

# See docs/benchmarks.md for detailed reports
```

## Rollback Plan

If you need to rollback to the original configuration:

1. **Restore original InferenceService**:

```bash
kubectl apply -f current-inference-service.yaml
```

2. **Restore original runtime** (if changed):

```bash
kubectl apply -f current-runtime.yaml
```

3. **Verify original deployment**:

```bash
kubectl get inferenceservice <your-service>
kubectl get pods -l serving.kserve.io/inferenceservice=<your-service>
```

## Troubleshooting

### Model Loading Issues

If the optimized model fails to load:

```bash
# Check model storage URI
kubectl get inferenceservice <service> -o jsonpath='{.spec.predictor.model.storageUri}'

# Verify model exists at location
# Check PVC or S3 bucket access
```

### Performance Not Improved

If you don't see expected improvements:

1. **Verify optimizations are applied**:

```bash
# Check vLLM runtime args
kubectl get servingruntime vllm-runtime -o jsonpath='{.spec.containers[0].args}'

# Should include:
# - --gpu-memory-utilization=0.9
# - --kv-cache-dtype=fp8
```

2. **Check GPU utilization**:

```bash
# Monitor GPU usage
oc get pods -l component=predictor -o jsonpath='{.items[*].metadata.name}' | xargs -I {} kubectl exec {} -- nvidia-smi
```

3. **Review benchmark results** to identify bottlenecks

## Next Steps

- Review [performance baseline](benchmarks/performance-baseline.md) for expected metrics
- See [troubleshooting guide](troubleshooting.md) for common issues
- Explore [architecture documentation](architecture.md) for deeper understanding

## Related Resources

- [Reference RAG QuickStart](https://github.com/rh-ai-quickstart/RAG) - Original RAG deployment
- [Deployment Guide](deployment-guide.md) - Complete deployment instructions
- [Business Value](business-value-driver.md) - ROI analysis and cost savings

