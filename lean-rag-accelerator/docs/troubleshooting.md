# Troubleshooting Guide

Common issues and solutions for Lean RAG Accelerator deployment.

## Model Optimization Issues

### Quantization Job Fails

**Symptoms**:
- QuantizationRecipe status shows `Failed`
- Job pods in `Error` or `CrashLoopBackOff` state

**Solutions**:

1. **Check calibration dataset**:
```bash
kubectl describe quantizationrecipe llama-3.1-8b-quantization
# Verify calibration dataset URI is accessible
```

2. **Verify model source**:
```bash
# Check model URI is correct
kubectl get quantizationrecipe llama-3.1-8b-quantization -o jsonpath='{.spec.model.source.uri}'

# Test model access
oc rsh <pod> curl -I <model-uri>
```

3. **Check resource limits**:
```bash
# Increase memory/CPU if needed
kubectl edit quantizationrecipe llama-3.1-8b-quantization
# Update resources.requests and resources.limits
```

4. **Review job logs**:
```bash
kubectl logs -l app=quantization --tail=100
```

### Quantization Takes Too Long

**Expected Duration**: 30-60 minutes for Llama 3.1 8B

**If taking longer**:

1. **Check GPU availability**:
```bash
oc get nodes -l nvidia.com/gpu.present=true
kubectl get pods -l app=quantization -o wide
```

2. **Reduce calibration samples**:
```yaml
# In quantization-recipe.yaml
quantization:
  calibration:
    numSamples: 256  # Reduce from 512
```

3. **Use smaller batch size**:
```yaml
calibration:
  batchSize: 4  # Reduce from 8
```

## Inference Serving Issues

### GPU Out of Memory (OOM)

**Symptoms**:
- Pods restarting with OOM errors
- `nvidia-smi` shows high memory usage

**Solutions**:

1. **Reduce GPU memory utilization**:
```yaml
# In vllm-runtime.yaml
args:
  - --gpu-memory-utilization
  - "0.7"  # Reduce from 0.9
```

2. **Use smaller model or further quantization**:
```yaml
# Use INT4 quantization instead of INT8
quantization:
  targetPrecision: int4
```

3. **Reduce max model length**:
```yaml
args:
  - --max-model-len
  - "4096"  # Reduce from 8192
```

### Model Fails to Load

**Symptoms**:
- InferenceService status shows `ModelLoadFailed`
- Pod logs show model loading errors

**Solutions**:

1. **Verify model storage URI**:
```bash
kubectl get inferenceservice lean-rag-inference -o jsonpath='{.spec.predictor.model.storageUri}'

# Check if model exists at location
oc rsh <pod-with-pvc> ls -lh <model-path>
```

2. **Check storage permissions**:
```bash
# Verify PVC is mounted correctly
kubectl describe pod <predictor-pod> | grep -A 5 "Mounts"

# Check PVC access
oc get pvc <model-storage-pvc>
```

3. **Verify model format**:
```bash
# Check if model format matches runtime expectations
kubectl get inferenceservice lean-rag-inference -o jsonpath='{.spec.predictor.model.modelFormat}'
```

### Slow Inference Performance

**Symptoms**:
- High latency (TTFT >500ms)
- Low throughput (<1 req/s)

**Solutions**:

1. **Verify optimizations are applied**:
```bash
kubectl get servingruntime vllm-runtime -o jsonpath='{.spec.containers[0].args}'

# Should include:
# - --gpu-memory-utilization=0.9
# - --kv-cache-dtype=fp8
```

2. **Check GPU utilization**:
```bash
oc get pods -l component=predictor -o jsonpath='{.items[*].metadata.name}' | \
  xargs -I {} kubectl exec {} -- nvidia-smi
```

3. **Increase concurrent requests**:
```yaml
# In vllm-runtime.yaml
args:
  - --max-num-seqs
  - "20"  # Increase from default
```

4. **Enable tensor parallelism** (if multiple GPUs):
```yaml
args:
  - --tensor-parallel-size
  - "2"  # For 2 GPUs
```

### Inference Service Unavailable

**Symptoms**:
- Service returns 503 or connection refused
- No predictor pods running

**Solutions**:

1. **Check service status**:
```bash
kubectl get inferenceservice lean-rag-inference
kubectl describe inferenceservice lean-rag-inference
```

2. **Check pod status**:
```bash
kubectl get pods -l serving.kserve.io/inferenceservice=lean-rag-inference
kubectl describe pod <predictor-pod>
```

3. **Check events**:
```bash
kubectl get events --sort-by='.lastTimestamp' | grep lean-rag-inference
```

4. **Verify KServe installation**:
```bash
oc get pods -n knative-serving
oc get pods -n istio-system
```

## RAG Pipeline Issues

### Vector Store Connection Errors

**Symptoms**:
- RAG queries fail with connection errors
- Vector store pods not accessible

**Solutions**:

1. **Verify vector store deployment**:
```bash
kubectl get pods -l app=milvus  # or chroma
kubectl get svc -l app=milvus
```

2. **Check network policies**:
```bash
kubectl get networkpolicies -n <namespace>
```

3. **Verify connection string in config**:
```yaml
# In vector-store-config.yaml
# Check connection string is correct
```

### Document Ingestion Fails

**Symptoms**:
- Docling jobs fail or timeout
- No documents in vector store

**Solutions**:

1. **Check document source**:
```bash
# Verify document source is accessible
kubectl describe job <docling-job>
```

2. **Check Docling configuration**:
```bash
kubectl get configmap docling-config -o yaml
```

3. **Review ingestion logs**:
```bash
kubectl logs -l app=docling-ingestion --tail=100
```

4. **Verify embedding model**:
```bash
# Check if embedding model is accessible
kubectl get inferenceservice <embedding-service>
```

## Performance Issues

### Not Seeing Expected Throughput Improvement

**Symptoms**:
- Throughput is similar to baseline
- GPU utilization still low

**Solutions**:

1. **Verify all optimizations are applied**:
```bash
# Check vLLM args
kubectl get servingruntime vllm-runtime -o yaml | grep -A 20 args

# Check quantization was successful
kubectl get quantizationrecipe llama-3.1-8b-quantization -o jsonpath='{.status.phase}'
```

2. **Run benchmarks to identify bottlenecks**:
```bash
cd benchmarks
kubectl apply -f guidellm-config.yaml
# Review benchmark results
```

3. **Check for resource constraints**:
```bash
# CPU throttling
kubectl top pods -l component=predictor

# Memory pressure
kubectl describe nodes | grep -A 5 "MemoryPressure"
```

4. **Verify model is actually quantized**:
```bash
# Check model size (should be smaller)
oc rsh <pod-with-model> du -sh <model-path>
```

### High Latency

**Symptoms**:
- TTFT >200ms
- ITL >100ms

**Solutions**:

1. **Check GPU availability**:
```bash
oc get nodes -l nvidia.com/gpu.present=true
# Verify GPU is not oversubscribed
```

2. **Reduce batch size**:
```yaml
# In vllm-runtime.yaml
args:
  - --max-num-seqs
  - "10"  # Reduce concurrent requests
```

3. **Use smaller model**:
- Consider Llama 3.2 3B instead of 8B
- Or use INT4 quantization

4. **Check network latency**:
```bash
# Test endpoint latency
curl -w "@-" -o /dev/null -s <inference-endpoint>/health
```

## General Issues

### Pods Stuck in Pending

**Symptoms**:
- Pods show `Pending` status
- No events or errors

**Solutions**:

1. **Check resource availability**:
```bash
kubectl describe pod <pod-name> | grep -A 10 "Events"
```

2. **Check node taints**:
```bash
oc get nodes -l nvidia.com/gpu.present=true -o yaml | grep -A 3 taint
```

3. **Verify tolerations**:
```yaml
# In deployment YAMLs, ensure tolerations match node taints
tolerations:
  - key: nvidia.com/gpu
    operator: Exists
    effect: NoSchedule
```

### Permission Denied Errors

**Symptoms**:
- Jobs fail with permission errors
- Cannot access storage

**Solutions**:

1. **Check service account**:
```bash
kubectl get serviceaccount -n <namespace>
kubectl describe serviceaccount default
```

2. **Verify RBAC**:
```bash
kubectl get rolebindings -n <namespace>
kubectl get clusterrolebindings | grep <service-account>
```

3. **Check storage permissions**:
```bash
# For PVC
oc get pvc <pvc-name> -o yaml

# For S3
# Verify credentials and bucket policies
```

## Getting Help

If you continue to experience issues:

1. **Collect diagnostic information**:
```bash
# Save cluster state
oc get all -n <namespace> -o yaml > cluster-state.yaml
kubectl describe inferenceservice lean-rag-inference > inference-service-describe.txt
kubectl logs -l component=predictor > predictor-logs.txt
```

2. **Check documentation**:
- [Deployment Guide](deployment-guide.md)
- [Architecture Documentation](architecture.md)
- [Reference RAG QuickStart](https://github.com/rh-ai-quickstart/RAG)

3. **Contact Support**:
- Open an issue in the repository
- Contact Red Hat support with diagnostic information

## Related Resources

- [Deployment Guide](deployment-guide.md) - Complete deployment instructions
- [Optimizing Existing RAG](optimizing-existing-rag.md) - Optimization workflow
- [Architecture Documentation](architecture.md) - System architecture details

