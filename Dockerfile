# 1. Builder Stage
FROM python:3.11-slim AS builder

WORKDIR /app

# Install system dependencies needed for compiling certain wheel structures
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create a clean virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install requirements inside the venv
RUN pip install --no-cache-dir --upgrade pip
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# 2. Production Stage
FROM python:3.11-slim

WORKDIR /app

# Copy the entire virtual environment from the builder stage
COPY --from=builder /opt/venv /opt/venv
# Copy application files
COPY . .

# Point PATH to the virtual environment so gunicorn and python use it directly
ENV PATH="/opt/venv/bin:$PATH"
ENV FLASK_APP=app.py
ENV PYTHONUNBUFFERED=1

EXPOSE 5000

# Reverted back to app:app to match your app.py configuration
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
