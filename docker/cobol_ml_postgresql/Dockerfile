FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN pip install --no-cache-dir psycopg2-binary

COPY app.py .

ENTRYPOINT ["python", "app.py"]
