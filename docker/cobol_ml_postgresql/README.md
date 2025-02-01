# Build and push with Mac M1 chip

```bash
docker buildx build --platform linux/amd64 \
    -t 704855531002.dkr.ecr.us-east-1.amazonaws.com/eks_cobol/cobol_ml_postgresql:0 \
    --push \
    --provenance=false \
    --sbom=false \
    .
```

# Create table inside RDS DB

```bash
k exec -it -n cobol-ml cobol-ml-worker-pod -- \
    sh -c 'PGPASSWORD=$POSTGRES_PASSWORD \
    psql -h $POSTGRES_CONNECTION_ENDPOINT \
    -U $POSTGRES_USER \
    -d $POSTGRES_DATABASE_NAME \
    -c "CREATE TABLE IF NOT EXISTS transactions (id SERIAL PRIMARY KEY, transaction_date DATE NOT NULL, description TEXT NOT NULL, amount NUMERIC NOT NULL);"'
```

# Create needed directories on EFS
```bash
k exec -it -n cobol-ml cobol-ml-worker-pod -- \
  mkdir /output/ingested-data
```