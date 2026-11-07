---
layout: default_c
RefPages:
---

# Microsoft SQL Server - Docker Setup & Usage Guide

## ℹ️ Introduction

This guide explains how to set up and access Microsoft SQL Server using Docker Compose. By default this stack uses the shared external Docker network so other containers can reach the database directly.

## ⚡🏃‍♂️ Quick Setup

1. **Make sure the external network exists (or create it)**

```powershell
docker network create --subnet=172.40.0.0/24 dev1-net
docker network ls
```

2 **Clone the this template**
```powershell
git clone https://github.com/NicoJanE/MSSQLDB.git
```

3 **Create and start the container stack**

In the folder: MSSQLDB execute:

```powershell
docker compose -f compose.yaml up -d --force-recreate --remove-orphans
```

4 **Verify the network**

- Verify that both containers are on the same network: `docker network inspect dev1-net`
- Verify the SQL Server service from the host: `sqlcmd -S localhost,14330 -U sa -P DockerMssql123! -Q "SELECT name FROM sys.databases"`

---

## ▶️ Usage

In your preferred (GUI) tool use the following to access the stock database instance

### Default Credentials

- **Server name inside Docker:** `mssql`
- **Server name from host:** `localhost,14330`
- **Admin login:** `sa`
- **Admin password:** `DockerMssql123!`
- **Default database:** `docker`
- **App login:** `docker`
- **App password:** `DockerUser123!`

### Access the Database from Another Container

When another Docker container is attached to the same external network, use these values:

- `DB_HOST=mssql`
- `DB_PORT=1433`
- `DB_NAME=docker`
- `DB_USER=docker`
- `DB_PASSWORD=DockerUser123!`

#### Example: Web Application Compose File

```yaml
webapp:
  build: ./webapp
  environment:
    DB_HOST: mssql
    DB_PORT: 1433
    DB_NAME: docker
    DB_USER: docker
    DB_PASSWORD: DockerUser123!
```

### Access from Host or External Machine

Use the host port from `compose.yaml`:

```text
DB_HOST=127.0.0.1
DB_PORT=14330
DB_NAME=docker
DB_USER=docker
DB_PASSWORD=DockerUser123!
```

### HeidiSQL on Windows

If HeidiSQL shows a warning about `SQLOLEDB` and insecure TLS 1.0, that warning comes from the old Windows client provider, not from this Docker container.

Use this approach on the host:

- Install the current **Microsoft OLE DB Driver for SQL Server** on Windows.
- In HeidiSQL, avoid the legacy `SQLOLEDB` provider when connecting to this server.
- Use the same host settings shown above: `localhost`, port `14330`, database `docker`, user `docker` or `sa`.
- For local development, use encrypted connections with `TrustServerCertificate=True` when the client asks for certificate-related settings.

### Example Connection Strings

```text
Server=mssql,1433;Database=docker;User Id=docker;Password=DockerUser123!;TrustServerCertificate=True;

Server=localhost,14330;Database=docker;User Id=docker;Password=DockerUser123!;TrustServerCertificate=True;
```

### Notes

- SQL Server requires a strong password. Change `MSSQL_SA_PASSWORD` and `MSSQL_PASSWORD` in `.env` before using this stack outside local development.
- The `mssql-init` sidecar creates the `docker` database and `docker` login the first time the stack starts.
