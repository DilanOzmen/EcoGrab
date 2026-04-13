# SQL Server and Azure SQL Setup

Bu proje SQL Server/SSMS veya Azure SQL ile calisir.

## Secenek 1: Lokal SQL Server (IP ile ortak kullanim)

1. Bir ekip bilgisayarina SQL Server (ornek `SQLEXPRESS`) ve SSMS kur.
2. SSMS ile baglanip su scripti calistir:

```sql
IF DB_ID('FoodWasteDb') IS NULL
BEGIN
    CREATE DATABASE FoodWasteDb;
END
GO

USE FoodWasteDb;
GO

IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = 'foodwaste_app')
BEGIN
    CREATE LOGIN foodwaste_app WITH PASSWORD = 'AppPassword!123', CHECK_POLICY = OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'foodwaste_app')
BEGIN
    CREATE USER foodwaste_app FOR LOGIN foodwaste_app;
END
GO

ALTER ROLE db_owner ADD MEMBER foodwaste_app;
GO
```

3. Host PC ayarlari:
- SQL Server Configuration Manager > TCP/IP: Enabled
- SQL Server Browser: Running
- Firewall: 1433 portuna izin

4. Ekip arkadaslari baglanti stringi:

```json
"DefaultConnection": "Server=<HOST_IP>\\SQLEXPRESS;Database=FoodWasteDb;User Id=foodwaste_app;Password=AppPassword!123;TrustServerCertificate=True"
```

## Secenek 2: Azure SQL (daha kolay ekip baglantisi)

1. Azure Portal > SQL Database olustur.
2. Yeni veya mevcut SQL Server sec.
3. Server firewall ayarinda ekip IP'lerini ekle.
4. SSMS ile test baglantisi yap.
5. API connection string:

```json
"DefaultConnection": "Server=tcp:<server-name>.database.windows.net,1433;Initial Catalog=FoodWasteDb;Persist Security Info=False;User ID=<user>;Password=<password>;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
```

## Notlar

- Mobil taraf Flutter'dir; backend ASP.NET Core API'ye baglanir.
- Ortak ekip calismasi icin Azure SQL genelde daha stabil ve kolaydir.
- `appsettings.Development.json` icinde bir `AzureSqlExample` ornegi eklidir.
