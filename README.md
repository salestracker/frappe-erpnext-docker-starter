# Frappe Docker Starter

#### Note: Unstable. Work In Progress

Frappe docker compose settings for development with containerized dependencies like mariadb and redis.

## Table of Contents
- [About](#about)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)


## About

Setting Frappe development environment takes time.
Here is the [frappe README](https://github.com/frappe/frappe)
The [development guidelines](https://github.com/frappe/frappe#development) lets you
choose an `easy-install` route which fetches [frappe-docker](https://github.com/frappe/frappe_docker)
repo and installs docker and relevant instances.

However, if you are starting to explore Frappe and ERPNET and already follow developer best practices, you already are using
an OCI compliant containerized practice, this might seem delivering too many things with less discretion.

Instead, it would be more in line with other python frameworks, to allow the
developer drive the development flow and structure without hijacking control.
Something which a virtual environment and containers can do.

This is where this repo comes in.

## Salient Features

- Have a template where you can keep frappe framework as an installable dependency via virtual environment and 
create as many projects.
- Use well known python project setup flow. 
- Use docker compose to build container services & don't corrupt existing configuration or settings on local.
- Ensure isolation for development environment.


## Getting Started

This works only on *nix and Mac OS X platforms for now.

### Prerequisites

Ensure you have gone through [ERPNext Installation Guide](https://github.com/D-codE-Hub/ERPNext-installation-Guide/blob/main/README.md) for reference.

1. Fork this repository and setup a new project using poetry environment. 
2. ~~Ensure you have installed git, `wkhtmltopdf`,  Python 3.6+, pip 20+, `node`, `npm` & yarn 1.12+.~~
3. Ensure you have docker-compliant engine installed, rootless like podman or rancher works.

### Installation

1. Setup a virtual environment 
2. Run `poetry install` to install frappe & it's dependencies.
3. Setup `.env` file like:
```bash
PYTHON_VERSION=${PYTHON_VERSION:?error}
MARIADB_DATABASE=${MARIADB_DATABASE:?error}
MARIADB_ROOT_PASSWORD=${MARIADB_ROOT_PASSWORD:?error}
MARIADB_USER=${MARIADB_USER:?error}
MARIADB_PASSWORD=${MARIADB_PASSWORD:?error}
FRAPPE_BRANCH=${FRAPPE_BRANCH:?error}
```
4. Add a `bench_setup_scripts.sh` like:
```bash
#!/bin/bash

echo "running bench setup script";

if [ ! -d "frappe-bench" ]; then
  echo "creating frappe-bench";
  bench init --dev --clone-without-update --verbose --ignore-exist --no-backups --no-procfile --skip-redis-config-generation --frappe-branch=${FRAPPE_BRANCH} frappe-bench
else
  echo "frappe-bench already exists";
fi;

echo "switching directory to frappe-bench";
cd frappe-bench/

bench set-mariadb-host mariadb
bench set-redis-cache-host redis-cache:6379
bench set-redis-queue-host redis-cache:6379
bench set-redis-socketio-host redis-cache:6379

# setup dummy site
if [ ! -d "sites/lms.localhost" ]; then
  bench get-app lms https://github.com/frappe/lms.git;
  bench new-site lms.localhost --force --admin-password=admin --db-host=mariadb --db-port=3306 --db-password=${MARIADB_PASSWORD} --db-user=${MARIADB_USER} --mariadb-root-password=${MARIADB_ROOT_PASSWORD} --mariadb-user-host-login-scope="%" --no-mariadb-socket --verbose --install-app lms
fi;

#bench reinstall --yes --admin-password=admin --mariadb-root-password=${MARIADB_ROOT_PASSWORD}

bench use lms.localhost

echo "starting frappe server..."
bench serve
```
This is an example script but you can change it dynamically 
to suit your bench requirements.

5. Run in terminal:
```bash
MARIADB_ROOT_PASSWORD=<MARIADB_PASSWORD> MARIADB_DATABASE=<MARIADB_DATABASE> MARIADB_USER=<MARIADB_USER> MARIADB_PASSWORD=<MARIADB_PASSWORD> PYTHON_VERSION=<PYTHON3_VERSION> FRAPPE_BRANCH=develop docker compose --project-name frappe-dev -f docker-compose.yml up --build
```

Ensure to fill placeholders. This will set `.env` variables and docker compose will pick up.

6. Hit your localhost:8000 to continue running frappe with usual setup.


*Note*: You can use frappe-branch version-14. This repository has been tested with this version.
