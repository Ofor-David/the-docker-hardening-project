# Stage 1: Build the application
FROM python:3.12-slim AS builder

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y build-essential

COPY requirements.txt .
RUN pip install --prefix=/install --no-cache-dir -r requirements.txt
COPY main.py .

# Stage 2: Create the final image
FROM python:3.12-slim

# Create non-root user
RUN useradd -m appuser

WORKDIR /app
COPY --from=builder /install /usr/local
COPY --from=builder /app /app

# Use non-root user
USER appuser

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]