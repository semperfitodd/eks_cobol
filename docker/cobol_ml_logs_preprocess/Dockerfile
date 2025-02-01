FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY app.py requirements.txt ./

RUN pip install -r requirements.txt

ENTRYPOINT ["python", "app.py"]
