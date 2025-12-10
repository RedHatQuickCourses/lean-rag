# Lean RAG Accelerator - Training & QuickStart

This repository contains both **training content** and **deployable quickstart code** for the Lean RAG Accelerator.

## Repository Structure

```
lean-rag/
├── README.md                    # This file
├── lean-rag-accelerator/       # Deployable QuickStart code
│   ├── README.md               # QuickStart main documentation
│   ├── bootstrap.sh            # Deployment script
│   ├── Makefile                # Make targets for deployment
│   ├── examples/               # Deployment YAML files
│   ├── docs/                   # QuickStart documentation
│   ├── scripts/                # Utility scripts
│   └── charts/                 # Helm charts
├── modules/                     # Training modules (Antora)
│   ├── module-1-*/            # Module 1: Inference Economics
│   ├── module-2-*/            # Module 2: Model Optimization
│   ├── module-3-*/            # Module 3: High-Performance Serving
│   ├── module-4-*/            # Module 4: Standardized RAG
│   └── module-5-*/            # Module 5: Validation & Benchmarking
└── antora.yml                  # Antora configuration
```

## Two Ways to Use This Repository

### 1. Training Content (Antora Documentation)

The training modules provide conceptual learning and best practices:

- **View Online**: The rendered training content is available via GitHub Pages (when configured)
- **Build Locally**: Use Antora to build and view the documentation locally
- **Modules**: Cover inference economics, model optimization, serving, RAG implementation, and benchmarking

**To view training content:**
- Navigate to the rendered documentation (GitHub Pages)
- Or build locally: `antora antora-playbook.yml`

### 2. Deployable QuickStart Code

The `lean-rag-accelerator/` directory contains ready-to-deploy code:

- **README.md**: Complete quickstart guide with deployment instructions
- **bootstrap.sh**: Interactive deployment script
- **Makefile**: Automated deployment targets
- **examples/**: Kubernetes YAML files for model optimization, inference serving, and RAG application
- **docs/**: Business value, architecture, and benchmarking documentation

**To deploy the quickstart:**

```bash
cd lean-rag-accelerator
./bootstrap.sh
```

Or use the Makefile:

```bash
cd lean-rag-accelerator
make help
make deploy-all NAMESPACE=lean-rag-accelerator
```

## Quick Links

### Training Content
- [Course Home](modules/ROOT/pages/index.adoc) - Start here for training modules
- [Module 1: Inference Economics](modules/module-1-inference-economics-rhoai-30-architecture/pages/module-1-inference-economics-rhoai-30-architecture.adoc)
- [Module 2: Model Optimization](modules/module-2-model-optimization-with-llm-compressor/pages/module-2-model-optimization-with-llm-compressor.adoc)
- [Module 3: High-Performance Serving](modules/module-3-high-performance-serving-with-vllm-llm-d/pages/module-3-high-performance-serving-with-vllm-llm-d.adoc)
- [Module 4: Standardized RAG](modules/module-4-standardized-rag-implementation/pages/module-4-standardized-rag-implementation.adoc)
- [Module 5: Validation & Benchmarking](modules/module-5-validation-benchmarking/pages/module-5-validation-benchmarking.adoc)

### QuickStart Code
- [QuickStart README](lean-rag-accelerator/README.md) - Main quickstart documentation
- [Business Value](lean-rag-accelerator/docs/business-value-driver.md) - ROI and problem statement
- [Architecture](lean-rag-accelerator/docs/architecture.md) - Technical architecture
- [Deployment Guide](lean-rag-accelerator/docs/deployment-guide.md) - Step-by-step deployment
- [Benchmarking](lean-rag-accelerator/docs/benchmarks.md) - Performance validation

## Getting Started

### For Training (Learning)

1. Review the training modules in order (Module 1 → Module 5)
2. Follow along with the concepts and best practices
3. Reference the quickstart code for hands-on practice

### For Deployment (QuickStart)

1. Navigate to `lean-rag-accelerator/` directory
2. Read the [QuickStart README](lean-rag-accelerator/README.md)
3. Follow the deployment instructions
4. Use `bootstrap.sh` or `Makefile` for automated deployment

## Prerequisites

- **For Training**: No prerequisites - the modules explain concepts
- **For QuickStart**: 
  - Red Hat OpenShift AI 3.0
  - Kubernetes cluster with GPU nodes
  - kubectl/oc CLI configured
  - See [QuickStart Requirements](lean-rag-accelerator/README.md#requirements) for details

## Support

- **Training Questions**: Review the training modules
- **QuickStart Issues**: See [Troubleshooting Guide](lean-rag-accelerator/docs/troubleshooting.md)
- **General**: Refer to the main repository or contact Red Hat support

## Related Resources

- [Red Hat OpenShift AI 3.0 Documentation](https://docs.redhat.com/)
- [Reference RAG QuickStart](https://github.com/rh-ai-quickstart/RAG)
- [KServe Documentation](https://kserve.github.io/website/)
- [vLLM Documentation](https://docs.vllm.ai/)
