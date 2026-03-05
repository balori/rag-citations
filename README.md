# RAG Q&A with Citations

A hands-on lab: build a Retrieval-Augmented Generation (RAG) system that answers
questions from your own documents with grounded, inline citations. Runs fully locally
on CPU with open-source tools — no API keys and no external model server.

## What you build
An `ask()` pipeline that chains: document chunking with citation metadata -> embeddings
and vector search -> sparse BM25 + dense hybrid fusion -> cross-encoder reranking ->
grounded generation that cites its sources -> an automated faithfulness check.

## Open-source stack
- **LLM:** `transformers` (`Qwen/Qwen2.5-1.5B-Instruct`, runs on CPU; use `Qwen/Qwen2.5-0.5B-Instruct` for speed)
- **Embeddings:** `sentence-transformers` (`BAAI/bge-small-en-v1.5`)
- **Vector store:** Chroma
- **Sparse retrieval:** `rank-bm25`
- **Reranker:** `sentence-transformers` CrossEncoder
- **PDF parsing:** `pypdf`

## Setup
This folder is self-contained. From **inside it** (Python 3.10-3.12, needs `torch` wheels):

```bash
./provision.sh                    # create .venv + register the "GenAI: rag_citations" kernel
PYTHON=python3.12 ./provision.sh  # pick the interpreter if the default lacks torch wheels
./provision.sh --clean            # tear it back down
```

Prefer to do it by hand? Use a **Python 3.10-3.12** interpreter — `torch` has no
wheels for Python 3.13+, which is what causes `No matching distribution found for torch`:

```bash
python3.12 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt ipykernel
python -m ipykernel install --user --name genai-rag_citations --display-name "GenAI: rag_citations"
```

## Run
Open `rag_citations.ipynb` in VS Code (or `jupyter lab`), select the
**GenAI: rag_citations** kernel, and run the cells top to bottom. The notebook writes
its own sample corpus, so it is self-contained; drop your own `.md` / `.txt` / `.pdf`
files into `corpus/` to use real documents. Model weights download on first run.

## Files
- `rag_citations.ipynb` — the lab, in 12 systematic steps
- `requirements.txt` — Python dependencies
- `provision.sh` — one-command setup for this project (venv + kernel)
