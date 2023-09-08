# Frappe Docker Starter

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
2. Ensure you have installed git, `wkhtmltopdf`,  Python 3.6+, pip 20+, `node`, `npm` & yarn 1.12+.

### Installation

1. Run `poetry install` to install frappe & it's dependencies.
2. Run `docker compose up -f docker-compose.yml --build`
3. Follow [steps 13](https://github.com/D-codE-Hub/ERPNext-installation-Guide/blob/main/README.md#step-13-initilise-the-frappe-bench--install-frappe-latest-version) onwards
4. Update mariadb environment in `docker-compose.yml` file to match your new app setup like:
```bash
bench new-site mynewsite.localhost --no-mariadb-socket --mariadb-root-password MARIADB_PASSWORD --db-type mariadb --db-root-username root --db-name DBNAME --db-password DBPWD [--set-default [--verbose]]
```

Note: You can use frappe-branch version-14. This repository has been tested with this version.
