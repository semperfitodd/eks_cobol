# Build and push with Mac M1 chip

```bash
docker buildx build --platform linux/amd64 \
    -t 704855531002.dkr.ecr.us-east-1.amazonaws.com/eks_cobol/cobol_ml_logs_preprocess:0 \
    --push \
    --provenance=false \
    --sbom=false \
    .
```