# ArgoCD Application Generator

This directory contains Helm charts and templates for generating ArgoCD Application manifests for GitOps deployment.

## Purpose

The ArgoCD Application Generator automates the creation of ArgoCD Application resources that deploy the Lean RAG Accelerator components via GitOps.

## Structure

```
argocd-appgenerator/
├── Chart.yaml              # Helm chart metadata
├── values.yaml             # Default values
├── templates/              # Helm templates
│   ├── application.yaml   # ArgoCD Application template
│   └── _helpers.tpl        # Helper templates
└── README.md              # This file
```

## Usage

### Generate ArgoCD Application

```bash
# Install Helm chart to generate ArgoCD Application
helm template . | kubectl apply -f -

# Or with custom values
helm template . -f custom-values.yaml | kubectl apply -f -
```

### Customize Deployment

Edit `values.yaml` to customize:
- Namespace
- Repository URLs
- Branch/tag references
- Component selection
- Resource limits

## Integration with ai-accelerator-examples

This follows the standard structure from `redhat-ai-services/ai-accelerator-examples`:
- Uses same GitOps patterns
- Compatible with bootstrap scripts
- Follows ArgoCD best practices

## Next Steps

1. **Create Chart.yaml**: Define Helm chart metadata
2. **Create values.yaml**: Define default configuration
3. **Create templates/**: Add ArgoCD Application templates
4. **Test Generation**: Validate ArgoCD Application manifests
5. **Document**: Add usage examples

**Note**: This is a placeholder structure. Actual Helm chart files should be created based on your specific ArgoCD setup and requirements.

