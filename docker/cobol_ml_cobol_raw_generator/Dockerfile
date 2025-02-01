FROM python:3.12-slim

WORKDIR /app

COPY generate_csv.py /app/generate_csv.py

RUN pip install --no-cache-dir --upgrade pip

CMD ["python", "/app/generate_csv.py"]
