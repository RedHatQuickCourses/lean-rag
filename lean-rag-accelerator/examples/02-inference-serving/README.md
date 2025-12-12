# Inference Serving

## Overview

This directory contains configurations for deploying the optimized model using vLLM, llm-d, and KServe. The setup maximizes GPU utilization and throughput while maintaining low latency.

### Understanding vLLM and llm-d

**vLLM** is the high-performance inference engine—think of it as a Formula 1 car designed for raw speed and efficiency. It executes inference workloads, manages GPU memory, and delivers fast responses through innovations like PagedAttention, speculative decoding, and tensor parallelism.

**llm-d** is the cloud-native orchestrator—think of it as the pit crew, race strategist, and telemetry system combined. It orchestrates vLLM instances to provide production-grade capabilities like independent scaling of prefill/decode phases, KV cache-aware routing, and Kubernetes-native elasticity.

**Important**: llm-d does not replace vLLM—it enhances it. Together, they create a championship-ready inference system. You can start with vLLM alone and add llm-d when you need production-scale orchestration.

## Files

- `vllm-runtime.yaml`: KServe ServingRuntime for vLLM (the inference engine)
- `kserve-inferenceservice.yaml`: KServe InferenceService definition
- `llm-d-configuration.yaml`: Optional llm-d configuration for production-scale orchestration

## When to Use llm-d

Start with vLLM alone for:
- Single node deployments
- Development and testing
- Simpler workloads with predictable traffic

Add llm-d when you need:
- Independent scaling of prefill and decode workers
- MoE model support (models too large for single GPU)
- KV cache-aware routing for RAG systems with repeated prompts
- Kubernetes-native elasticity with KEDA/ArgoCD
- Production telemetry and observability

## Architecture

### Basic Setup (vLLM + KServe)

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

### Production Setup (vLLM + llm-d + KServe)

```
┌─────────────────────────────────────┐
│     KServe InferenceService        │
│  ┌───────────────────────────────┐ │
│  │   llm-d Coordinator           │ │
│  │   - Prefill/Decode Routing    │ │
│  │   - KV Cache-Aware Routing    │ │
│  │   - Kubernetes Elasticity     │ │
│  └───────────────────────────────┘ │
│           │                        │
│           ├──────────────────────┐ │
│           ▼                      ▼ │
│  ┌──────────────┐      ┌──────────────┐ │
│  │ vLLM Workers │      │ vLLM Workers │ │
│  │ (Prefill)    │      │ (Decode)     │ │
│  └──────────────┘      └──────────────┘ │
│           │                      │      │
│           └──────────┬───────────┘      │
│                      ▼                  │
│         Optimized Model (from step 1)   │
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

