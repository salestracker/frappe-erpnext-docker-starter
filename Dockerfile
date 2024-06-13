# Use a base image with Python 3 and Ubuntu (adjust the base image as needed)
# Use multi-stage builds for smaller final images

ARG PYTHON_VERSION

ENV PYTHON_VERSION=$PYTHON_VERSION

FROM python:${PYTHON_VERSION}-slim AS builder

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        cron \
        libssl-dev \
        libffi-dev \
        util-linux \
        gcc

# Install dependencies in a separate stage
WORKDIR /app

# Build the final image with a minimal base
ARG PYTHON_VERSION
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
# Ensure the /app/bench_apps/ directory exists

RUN mkdir -p /app/node_modules/ #&& chown -R localuser:localuser /app/node_modules/

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    xz-utils && apt-get clean

RUN curl -fsSL https://nodejs.org/dist/v20.14.0/node-v20.14.0-linux-arm64.tar.xz \
    -o /tmp/node-v20.14.0-linux-arm64.tar.xz \
    && tar -xJf /tmp/node-v20.14.0-linux-arm64.tar.xz -C /usr/local --strip-components=1 --no-same-owner \
    && rm /tmp/node-v20.14.0-linux-arm64.tar.xz \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

RUN apt-get update && apt-get install \
    --no-install-recommends -y gcc \
    python3-dev make cron g++ supervisor \
    mariadb-client-10.5

RUN chown -R localuser:localuser /app/
RUN chown -R localuser:localuser /usr/bin/
RUN chown -R localuser:localuser /app/node_modules/

USER localuser

RUN npm install yarn corepack
RUN ln -s /app/node_modules/yarn/bin/yarn /usr/bin/yarn

# Environment variables (consider moving to .env file)
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1


USER root
RUN chmod 0644 /var/spool/cron/crontabs/
RUN chown -R localuser:crontab /var/spool/cron/crontabs/
RUN chmod -R 770 /var/spool/cron/crontabs/

USER localuser
#this is needed to allow modifying crontabs/ in non-root accounts
RUN touch /var/spool/cron/crontabs/localuser

COPY requirements.txt .
RUN python3 -m pip install -r requirements.txt

RUN ln -s /home/localuser/.local/bin/bench /usr/bin/bench && chmod +x /usr/bin/bench
RUN ln -s /home/localuser/.local/bin/honcho /usr/bin/honcho && chmod +x /usr/bin/bench
WORKDIR /app/bench_apps

ARG FRAPPE_BRANCH
ENV FRAPPE_BRANCH=${FRAPPE_BRANCH}




