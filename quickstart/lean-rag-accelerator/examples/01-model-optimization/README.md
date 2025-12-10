# Model Optimization

## Overview

This directory contains configurations for optimizing the Llama 3.1 8B model using LLM Compressor. The optimization process reduces model size and memory footprint while maintaining acceptable accuracy.

## Files

- `quantization-recipe.yaml`: LLM Compressor quantization configuration
- `model-config.yaml`: Model-specific settings for Llama 3.1 8B

## Quantization Methods

### SmoothQuant
- **Best for**: General-purpose quantization
- **Precision**: INT8
- **Accuracy**: High retention
- **Use case**: Production deployments

### GPTQ
- **Best for**: Maximum compression
- **Precision**: INT4
- **Accuracy**: Good retention with calibration
- **Use case**: Resource-constrained environments

## Usage

1. Review and customize `quantization-recipe.yaml` for your environment
2. Update model storage references (PVC or S3)
3. Apply the quantization recipe:
   ```bash
   kubectl apply -f quantization-recipe.yaml
   ```
4. Monitor the quantization job until completion
5. Verify the optimized model is available at the specified storage location

## Configuration

### Key Parameters

- **Model**: `meta-llama/Llama-3.1-8B`
- **Quantization Method**: SmoothQuant (default) or GPTQ
- **Target Precision**: INT8 (SmoothQuant) or INT4 (GPTQ)
- **Calibration Dataset**: [To be specified]
- **Output Format**: ONNX or native format

## Expected Results

- **Model Size**: ~50% reduction (INT8) or ~75% reduction (INT4)
- **Memory Footprint**: Reduced GPU memory requirements
- **Inference Speed**: 1.5x to 2x faster
- **Accuracy**: <5% degradation (typically)

## Troubleshooting

- **Calibration dataset errors**: Ensure dataset is accessible and properly formatted
- **Out of memory**: Reduce batch size or use a smaller calibration dataset
- **Quantization failures**: Check model format compatibility

