# 1. Use a modern, minimal, and secure Python base image
FROM python:3.11-slim AS builder

# Set working directory
WORKDIR /app

# Install system dependencies needed to build some Python packages (if any)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip securely
RUN pip install --no-cache-dir --upgrade pip

# Copy and install dependencies to a virtual environment or local path
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt


# 2. Production Stage (Keeps the final image tiny and free of build tools)
FROM python:3.11-slim

WORKDIR /app

# Copy installed dependencies from the builder stage
COPY --from=builder /root/.local /root/.local
COPY . .

# Ensure the local pip binaries are in the PATH
ENV PATH=/root/.local/bin:$PATH
ENV FLASK_APP=app.py
ENV PYTHONUNBUFFERED=1

# Open port 5000
EXPOSE 5000

# Run with Gunicorn (as written in your text, which is safer than the scan's flask dev server)
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
