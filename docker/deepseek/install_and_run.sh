#!/bin/bash

echo "Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

echo "Starting Ollama service..."
ollama serve &
OLLAMA_PID=$!

echo "Waiting for Ollama service to initialize..."
until curl -s http://127.0.0.1:11434/api/version > /dev/null; do
    sleep 2
    echo "Waiting for Ollama..."
done

echo "Ollama service is running. Pulling DeepSeek model..."
ollama pull deepseek-r1:7b

echo "Restarting Ollama in the foreground..."
kill $OLLAMA_PID
ollama serve