# QuickStart Structure Comparison: Lean RAG vs Reference RAG

**Reference Repository**: [rh-ai-quickstart/RAG](https://github.com/rh-ai-quickstart/RAG)  
**Comparison Date**: 2024-12-19

## Key Differences

### 1. **Deployment Approach**

**Reference RAG** (rh-ai-quickstart/RAG):
- ✅ Uses **Helm charts** for deployment (`deploy/helm/`)
- ✅ Has a **Makefile** with convenient commands (`make install`, `make list-models`)
- ✅ Uses **values.yaml** pattern with example file (`rag-values.yaml.example`)
- ✅ Supports multiple deployment targets (GPU, HPU, CPU)
- ✅ Includes local deployment option (`deploy/local/`)

**Your Lean RAG**:
- ⚠️ Planned to use **raw YAML files** (`kubectl apply -f`)
- ⚠️ No deployment automation (Makefile/scripts)
- ⚠️ No values file pattern
- ⚠️ Focused on optimization/serving, less on full deployment

**Recommendation**: Consider adopting Helm chart structure for consistency with other Red Hat quickstarts.

### 2. **Directory Structure**

**Reference RAG Structure**:
```
RAG/
├── README.md                    # Comprehensive main README
├── deploy/
│   ├── helm/                    # Helm chart deployment
│   │   ├── Makefile             # Deployment automation
│   │   ├── rag/                 # Helm chart
│   │   │   ├── Chart.yaml
│   │   │   ├── values.yaml
│   │   │   └── templates/       # K8s manifests
│   │   └── rag-values.yaml.example
│   └── local/                   # Local deployment option
├── docs/                        # Comprehensive documentation
│   ├── openshift_setup_guide.md
│   ├── local_setup_guide.md
│   ├── rag-reference-architecture.md
│   └── images/
├── frontend/                    # UI application
├── ingestion-service/           # Document ingestion
├── client-examples-python/      # Usage examples
├── notebooks/                   # Jupyter notebooks
└── tests/                       # Test suites
```

**Your Lean RAG Structure**:
```
lean-rag-accelerator/
├── README.md
├── BUSINESS-VALUE.md
├── ARCHITECTURE.md
├── 01-model-optimization/
│   ├── README.md
│   └── quantization-recipe.yaml
├── 02-inference-serving/        # EMPTY
├── 03-rag-application/          # EMPTY
├── benchmarks/                 # EMPTY
└── deployment/                 # EMPTY
```

**Key Observations**:
- Reference has **complete implementation** (frontend, services, tests)
- Your quickstart is **more focused** on optimization patterns/configs
- Reference uses **functional directory names** (deploy, docs, frontend)
- Your quickstart uses **sequential numbering** (01-, 02-, 03-)

### 3. **Documentation Approach**

**Reference RAG**:
- ✅ Single comprehensive `README.md` with table of contents
- ✅ Separate detailed guides in `docs/` directory
- ✅ Architecture diagrams in `docs/images/`
- ✅ Setup guides for different scenarios (OpenShift, local, Ollama)
- ✅ Inline code examples with syntax highlighting

**Your Lean RAG**:
- ⚠️ Multiple README files (unclear hierarchy)
- ⚠️ Separate `BUSINESS-VALUE.md` and `ARCHITECTURE.md` (good separation)
- ⚠️ Many FIXME placeholders
- ⚠️ Missing detailed setup guides

**Recommendation**: 
- Keep your business/architecture separation (good!)
- Add a comprehensive main README with TOC
- Create detailed setup guides in a `docs/` directory
- Complete or remove FIXME placeholders

### 4. **Configuration Management**

**Reference RAG**:
```yaml
# Uses Helm values pattern
llm-service:
  secret:
    hf_token: ""
global:
  models:
    llama-3-2-3b-instruct:
      id: meta-llama/Llama-3.2-3B-Instruct
      enabled: false
      tolerations: [...]
```

**Your Lean RAG** (Planned):
```yaml
# Raw Kubernetes CRDs
apiVersion: ai.redhat.com/v1alpha1
kind: QuantizationRecipe
spec:
  model:
    name: meta-llama/Llama-3.1-8B
  quantization:
    method: smoothquant
```

**Recommendation**: Your approach is fine for CRD-based resources, but consider:
- Adding a `values.yaml` or `config.yaml` for user customization
- Providing example configurations
- Documenting all configurable parameters

### 5. **Testing & Examples**

**Reference RAG**:
- ✅ `tests/` directory with unit, integration, and e2e tests
- ✅ `client-examples-python/` with working code examples
- ✅ `notebooks/` with Jupyter examples
- ✅ `pytest.ini` for test configuration

**Your Lean RAG**:
- ❌ No tests directory
- ❌ No client examples
- ❌ No notebooks

**Recommendation**: Consider adding at least:
- Basic validation scripts
- Example client code showing how to use the optimized model
- Simple test to verify deployment

### 6. **Deployment Automation**

**Reference RAG Makefile**:
```makefile
make install NAMESPACE=llama-stack-rag LLM=llama-3-2-3b-instruct
make list-models
make uninstall
```

**Your Lean RAG**:
- Manual `kubectl apply -f` commands
- No automation

**Recommendation**: Even if not using Helm, consider:
- Simple deployment script (`deploy.sh`)
- Or a Makefile with common operations
- Validation/verification scripts

## What to Adopt from Reference

### High Priority

1. **Helm Chart Structure** (if appropriate)
   - Standardizes deployment
   - Makes configuration easier
   - Consistent with other Red Hat quickstarts

2. **Comprehensive Main README**
   - Table of contents
   - Clear prerequisites
   - Step-by-step installation
   - Architecture overview

3. **Documentation Organization**
   - `docs/` directory for detailed guides
   - Separate setup guides for different scenarios
   - Architecture diagrams

4. **Example Values File**
   - `*-values.yaml.example` pattern
   - Shows all configurable options
   - Documented inline

### Medium Priority

5. **Client Examples**
   - Python examples showing usage
   - Different scenarios (basic, advanced)
   - Copy-paste ready code

6. **Testing Structure**
   - At minimum: validation scripts
   - Integration tests if possible
   - Verification after deployment

7. **Deployment Scripts**
   - Makefile or shell script
   - Common operations (install, uninstall, verify)
   - Error handling

### Low Priority (Nice to Have)

8. **Frontend/UI** (if applicable to your use case)
9. **Notebooks** (for experimentation)
10. **Local deployment option**

## What's Unique About Your Approach

**Your Lean RAG has some good differentiators**:

1. **Focus on Optimization** - Your quickstart is specifically about optimization techniques, which is valuable
2. **Business Value Documentation** - Separate `BUSINESS-VALUE.md` is excellent
3. **Sequential Learning Path** - The 01-, 02-, 03- structure suggests a learning progression
4. **Benchmarking Focus** - Dedicated benchmarks directory (when populated)

## Recommended Structure for Lean RAG

Based on the reference, here's a suggested structure:

```
lean-rag-accelerator/
├── README.md                    # Main entry point with TOC
├── BUSINESS-VALUE.md            # Keep this - it's good!
├── ARCHITECTURE.md              # Keep this - it's good!
├── deploy/
│   ├── helm/                    # OR raw YAMLs
│   │   ├── Makefile             # Deployment automation
│   │   ├── lean-rag/
│   │   │   ├── Chart.yaml
│   │   │   ├── values.yaml
│   │   │   └── templates/
│   │   └── values.yaml.example
│   └── scripts/                 # Alternative: shell scripts
│       ├── deploy.sh
│       └── verify.sh
├── docs/
│   ├── setup-guide.md
│   ├── optimization-guide.md
│   ├── benchmarking-guide.md
│   └── images/
├── 01-model-optimization/
│   ├── README.md
│   ├── quantization-recipe.yaml
│   └── model-config.yaml
├── 02-inference-serving/
│   ├── README.md
│   ├── vllm-runtime.yaml
│   └── inference-service.yaml
├── 03-rag-application/
│   ├── README.md
│   ├── rag-pipeline.yaml
│   └── docling-config.yaml
├── benchmarks/
│   ├── README.md
│   ├── guidellm-config.yaml
│   └── performance-baseline.md
├── examples/
│   └── python/
│       ├── optimize-model.py
│       ├── deploy-inference.py
│       └── test-rag.py
└── tests/
    └── verify-deployment.sh
```

## Action Items

1. **Decide on deployment approach**: Helm vs raw YAMLs
2. **Create missing directories**: Fill in empty directories or remove references
3. **Write comprehensive README**: Main entry point with clear navigation
4. **Add deployment automation**: Makefile or scripts
5. **Create example values/config**: Show all options
6. **Add validation**: Scripts to verify deployment
7. **Complete documentation**: Setup guides, troubleshooting

## Questions to Answer

1. **Is this a full application or configuration examples?**
   - Reference RAG = Full application
   - Your Lean RAG = Configuration patterns?
   
2. **Target audience?**
   - Reference = End users deploying RAG
   - Your = Developers learning optimization?

3. **Deployment complexity?**
   - Reference = One-command deploy
   - Your = Step-by-step learning?

The answer to these will determine how closely you should follow the reference structure.

