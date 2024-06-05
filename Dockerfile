# Use a base image with Python 3 and Ubuntu (adjust the base image as needed)
# Use multi-stage builds for smaller final images
ARG PYTHON_VERSION
FROM python:$PYTHON_VERSION-slim AS builder

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        mariadb-client-10.5 \
        cron \
        libssl-dev \
        libffi-dev \
        util-linux

# Install dependencies in a separate stage
WORKDIR /app

# Build the final image with a minimal base
FROM python:${PYTHON_VERSION}-slim AS final

# Set the working directory
WORKDIR /app
RUN apt-get update && apt-get install -y git

# Create a non-privileged user with a static UID
ARG UID=10001
RUN adduser --disabled-password \
    --gecos "" \
    --shell /bin/bash \
    --uid "${UID}"  \
    localuser

# Assign privileges to non-privileged localuser for bench creation
RUN chown -R localuser:localuser /usr/bin/
RUN chown -R localuser:localuser /app/bench_apps/

USER localuser

# Leverage cache for requirements.txt
COPY requirements.txt .

# Environment variables (consider moving to .env file)
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN python3 -m pip install -r requirements.txt && echo $(python -m pip freeze)

# Define environment variables
ARG FRAPPE_BRANCH
ARG FRAPPE_PATH

RUN ln -s /home/localuser/.local/bin/bench /usr/bin/bench && chmod +x /usr/bin/bench
RUN bench init --frappe-branch=$FRAPPE_BRANCH --frappe-path=$FRAPPE_PATH bench_apps/frappe-bench
