# Inference Serving

## Overview

This directory contains configurations for deploying the optimized model using vLLM and KServe. The setup maximizes GPU utilization and throughput while maintaining low latency.

## Files

- `vllm-runtime.yaml`: KServe ServingRuntime for vLLM
- `kserve-inferenceservice.yaml`: KServe InferenceService definition
- `llm-d-configuration.yaml`: Optional llm-d configuration for distributed inference

## Architecture

```
┌─────────────────────────────────────┐
│     KServe InferenceService        │
│  ┌───────────────────────────────┐ │
│  │   vLLM ServingRuntime         │ │
│  │   - GPU Memory Optimization   │ │
│  │   - FP8 KV Cache              │ │
│  │   - Tensor Parallelism        │ │
│  └───────────────────────────────┘ │
│           │                        │
│           ▼                        │
│  Optimized Model (from step 1)     │
└─────────────────────────────────────┘
```

## Key Optimizations

### GPU Memory Utilization
- `--gpu-memory-utilization=0.9`: Maximizes GPU usage (90%)
- Allows more concurrent requests

### KV Cache Optimization
- `--kv-cache-dtype=fp8`: Uses FP8 for KV cache
- Reduces memory footprint by ~50%
- Maintains accuracy with minimal impact

### Tensor Parallelism
- Configurable based on GPU count
- Enables multi-GPU inference

## Usage

1. **Deploy vLLM Runtime**:
   ```bash
   kubectl apply -f vllm-runtime.yaml
   ```

2. **Deploy Inference Service**:
   ```bash
   kubectl apply -f kserve-inferenceservice.yaml
   ```

3. **Verify Deployment**:
   ```bash
   kubectl get inferenceservice lean-rag-inference
   kubectl get pods -l serving.kserve.io/inferenceservice=lean-rag-inference
   ```

4. **Test Inference**:
   ```bash
   # Get the service endpoint
   INGRESS_HOST=$(kubectl get inferenceservice lean-rag-inference -o jsonpath='{.status.url}')
   
   # Send a test request
   curl -X POST $INGRESS_HOST/v1/completions \
     -H "Content-Type: application/json" \
     -d '{"prompt": "Hello, world!", "max_tokens": 50}'
   ```

## Configuration

### Resource Requirements

- **GPU**: 1x NVIDIA A10G (or equivalent)
- **Memory**: 16-32 GiB
- **CPU**: 4-8 cores

### Scaling

- **Min Replicas**: 1 (for cost efficiency)
- **Max Replicas**: 10 (for high load)
- **Auto-scaling**: Based on request rate

## Expected Performance

- **Throughput**: 2x to 4x improvement over baseline
- **Latency**: <100ms time to first token (TTFT)
- **GPU Utilization**: 85-90%
- **Concurrent Requests**: 10-20 per GPU

## Troubleshooting

- **GPU OOM**: Reduce `--gpu-memory-utilization` or model size
- **Slow inference**: Check GPU availability and model loading
- **Service unavailable**: Verify model storage URI and permissions

