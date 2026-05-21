-- Purpose:
--   Initialization script executed by `init-db.sh` inside the `mssql-init` container.
--
-- What it does:
--   1. Creates the application database when it does not exist yet.
--   2. Creates the SQL login for the application when it does not exist yet.
--   3. Creates the matching database user inside that database.
--   4. Grants that user `db_owner` rights on the application database.
--
-- Where it is used:
--   Called from `/scripts/init-db.sh` through `sqlcmd` with these sqlcmd variables:
--   $(DB_NAME), $(DB_LOGIN), $(DB_PASSWORD)
--
-- Expected outcome:
--   Other containers can connect to the `mssql` service with the app credentials from
--   `.env`, while the script remains safe to rerun because every step checks first.

IF DB_ID(N'$(DB_NAME)') IS NULL
BEGIN
    EXEC(N'CREATE DATABASE [$(DB_NAME)]');
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = N'$(DB_LOGIN)')
BEGIN
    EXEC(N'CREATE LOGIN [$(DB_LOGIN)] WITH PASSWORD = ''$(DB_PASSWORD)'', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF');
END;
GO

USE [$(DB_NAME)];
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'$(DB_LOGIN)')
BEGIN
    EXEC(N'CREATE USER [$(DB_LOGIN)] FOR LOGIN [$(DB_LOGIN)]');
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    INNER JOIN sys.database_principals rolep ON drm.role_principal_id = rolep.principal_id
    INNER JOIN sys.database_principals userp ON drm.member_principal_id = userp.principal_id
    WHERE rolep.name = N'db_owner' AND userp.name = N'$(DB_LOGIN)'
)
BEGIN
    EXEC(N'ALTER ROLE [db_owner] ADD MEMBER [$(DB_LOGIN)]');
END;
GO