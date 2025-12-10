# Benchmarks & Validation

## Overview

This directory contains benchmarking configurations and validation tools to measure the performance improvements of the Lean RAG Accelerator. Use GuideLLM to validate the 2x to 4x throughput improvement.

## Files

- `guidellm-config.yaml`: GuideLLM benchmarking configuration
- `performance-baseline.md`: Expected performance metrics and baseline measurements

## Benchmarking with GuideLLM

GuideLLM is a tool for simulating real-world traffic loads and validating throughput gains. It measures:

- **Throughput**: Requests per second
- **Latency**: Time to first token (TTFT) and inter-token latency (ITL)
- **GPU Utilization**: Resource usage efficiency
- **Error Rate**: Failed requests percentage

## Usage

1. **Configure Baseline Test**:
   ```bash
   # Update guidellm-config.yaml with baseline endpoint
   kubectl apply -f guidellm-config.yaml
   ```

2. **Run Baseline Benchmark**:
   ```bash
   # Monitor the benchmark job
   kubectl logs -f job/guidellm-baseline
   ```

3. **Configure Optimized Test**:
   ```bash
   # Update with optimized endpoint
   kubectl apply -f guidellm-config.yaml
   ```

4. **Run Optimized Benchmark**:
   ```bash
   kubectl logs -f job/guidellm-optimized
   ```

5. **Compare Results**:
   - Review metrics in performance-baseline.md
   - Calculate improvement percentage
   - Validate against expected 2x-4x improvement

## Expected Results

### Baseline (Before Optimization)

- **Throughput**: [TBD] requests/second
- **TTFT**: [TBD] ms
- **ITL**: [TBD] ms
- **GPU Utilization**: [TBD]%
- **Error Rate**: <1%

### Optimized (After Optimization)

- **Throughput**: 2x to 4x improvement
- **TTFT**: Maintained or improved
- **ITL**: Maintained or improved
- **GPU Utilization**: 85-90%
- **Error Rate**: <1%

## Metrics Explained

### Throughput
- **Definition**: Number of requests processed per second
- **Target**: 2x to 4x improvement
- **Measurement**: Requests/second over test duration

### Time to First Token (TTFT)
- **Definition**: Time from request to first token generation
- **Target**: <100ms
- **Impact**: User-perceived latency

### Inter-Token Latency (ITL)
- **Definition**: Time between consecutive tokens
- **Target**: <50ms
- **Impact**: Streaming response smoothness

### GPU Utilization
- **Definition**: Percentage of GPU resources used
- **Target**: 85-90%
- **Impact**: Cost efficiency

## Troubleshooting

- **Benchmark failures**: Check endpoint accessibility and authentication
- **Inconsistent results**: Increase test duration or sample size
- **High error rates**: Verify model availability and resource limits

