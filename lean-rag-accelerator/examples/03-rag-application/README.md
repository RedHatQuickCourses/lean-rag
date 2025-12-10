# RAG Application

## Overview

This directory contains configurations for building a standardized RAG (Retrieval-Augmented Generation) application using Llama Stack and Docling. The application ingests documents, creates vector embeddings, and provides a query interface.

## Files

- `rag-pipeline.yaml`: Llama Stack pipeline configuration
- `docling-config.yaml`: Docling document ingestion configuration
- `vector-store-config.yaml`: Vector database configuration (Milvus/Chroma)

## Architecture

```
┌─────────────────────────────────────┐
│      Document Ingestion             │
│      (Docling)                      │
│  PDFs → Chunks → Embeddings         │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│      Vector Store                    │
│      (Milvus/Chroma)                 │
│  Store & Index Embeddings            │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│      RAG Pipeline                   │
│      (Llama Stack)                  │
│  Query → Retrieve → Generate        │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│      Inference Service              │
│      (vLLM from step 2)             │
│  Generate Response                   │
└─────────────────────────────────────┘
```

## Components

### 1. Document Ingestion (Docling)

**Purpose**: Process and chunk enterprise documents (PDFs, DOCX, etc.)

**Features**:
- OCR for scanned documents
- Table extraction
- Structured chunking
- Metadata extraction

### 2. Vector Store (Milvus/Chroma)

**Purpose**: Store and index document embeddings

**Features**:
- Dense vector storage
- Similarity search
- Scalable architecture
- Multi-tenant support

### 3. RAG Pipeline (Llama Stack)

**Purpose**: Orchestrate retrieval and generation

**Features**:
- Standardized API
- Response generation
- Vector IO operations
- Workflow orchestration

## Usage

1. **Configure Vector Store**:
   ```bash
   kubectl apply -f vector-store-config.yaml
   ```

2. **Configure Document Ingestion**:
   ```bash
   kubectl apply -f docling-config.yaml
   ```

3. **Deploy RAG Pipeline**:
   ```bash
   kubectl apply -f rag-pipeline.yaml
   ```

4. **Ingest Documents**:
   ```bash
   # Upload documents to the ingestion endpoint
   curl -X POST <docling-endpoint>/ingest \
     -F "file=@document.pdf"
   ```

5. **Query the RAG System**:
   ```bash
   curl -X POST <rag-pipeline-endpoint>/query \
     -H "Content-Type: application/json" \
     -d '{"query": "What is the main topic?", "top_k": 5}'
   ```

## Configuration

### Document Processing

- **Chunk Size**: 512 tokens (configurable)
- **Chunk Overlap**: 50 tokens
- **Supported Formats**: PDF, DOCX, TXT, MD

### Vector Store

- **Embedding Model**: [To be specified]
- **Dimension**: 768 or 1536 (model-dependent)
- **Index Type**: HNSW or IVF_FLAT

### RAG Pipeline

- **Retrieval Strategy**: Semantic search
- **Top K**: 5 documents (configurable)
- **Temperature**: 0.7
- **Max Tokens**: 512

## Expected Performance

- **Ingestion Speed**: ~100 pages/minute
- **Query Latency**: <2 seconds (including retrieval + generation)
- **Accuracy**: High relevance in retrieved documents
- **Throughput**: 10-20 queries/second

## Troubleshooting

- **Document ingestion failures**: Check file format and size limits
- **Vector store connection errors**: Verify Milvus/Chroma deployment
- **Low retrieval quality**: Adjust chunk size or embedding model
- **Slow queries**: Optimize vector index or reduce top_k

