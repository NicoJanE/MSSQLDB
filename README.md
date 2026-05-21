# MSSQL - Docker Support Container

## ℹ️ Introduction

This is a **Microsoft SQL Server** supporting container, using the same external Docker network pattern as the other stacks in this repository.

## ⚡Setup

For details on creating and using this container:

- Click here for the general page: [General](https://nicojane.github.io/MSSQLDB/Howtos/setup)
- Or click here to go to the Setup page direct: [Setup](https://nicojane.github.io/MSSQLDB/Howtos/setup)

### ⚡🏃‍♂️ Quick Setup

- `docker network create --subnet=172.40.0.0/24 dev1-net`
- `docker compose -f compose.yaml up -d --force-recreate --remove-orphans`

### Default Access

- Host: `localhost,14330`
- Container host name: `mssql`
- Database: `docker`
- Login: `docker`
- Password: `DockerUser123!`
