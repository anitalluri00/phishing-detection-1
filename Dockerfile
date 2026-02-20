# Start from Amazon Linux 2 base image
FROM amazonlinux:2

# Install necessary system packages
RUN yum update -y && \
    yum install -y python3 python3-pip && \
    yum clean all

# Install Gunicorn
RUN pip3 install --upgrade pip && \
    pip3 install gunicorn

# Set working directory
WORKDIR /app

# Copy requirements.txt first
COPY requirements.txt .

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the entire application code
COPY . .

# Set environment variables
ENV FLASK_APP=app.py
ENV PYTHONUNBUFFERED=1

# Expose the port that Flask will run on
EXPOSE 5000

# Command to run the app with Gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
