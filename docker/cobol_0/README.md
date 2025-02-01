# Build and push with Mac M1 chip

```bash
docker buildx build --platform linux/amd64 \
    -t 704855531002.dkr.ecr.us-east-1.amazonaws.com/eks_cobol/cobol_0:0 \
    --push \
    --provenance=false \
    --sbom=false \
    .
```

# Create needed directories on EFS

```bash
k exec -it -n cobol-0 cobol-0-worker-pod -- \
  mkdir /output/input /output/output
```