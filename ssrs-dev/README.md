# SQL Server + SSRS (Power BI Report Server) Development Environment

This setup provides SQL Server 2025 and Power BI Report Server in a Windows container.

## Current Status

Container is running with:
- **SQL Server 2025** on port 1433
- **Power BI Report Server** on port 80

## Quick Start

### Start the container
```powershell
cd C:\ssrs-dev
docker start ssrs-dev
```

### Stop the container
```powershell
docker stop ssrs-dev
```

### View logs
```powershell
docker logs ssrs-dev
```

## Access URLs

| Service | URL/Connection |
|---------|----------------|
| SQL Server | `localhost,1433` |
| Report Manager | http://localhost/reports |
| Report Server Web Service | http://localhost/reportserver |

## Credentials

| Service | Username | Password |
|---------|----------|----------|
| SQL Server SA | `sa` | `MyStr0ng!Pass#2024` |
| PBIRS Admin | `pbirsAdmin` | (default from image) |

## Connection Strings

### For your ASP.NET VB.NET application:
```
Server=localhost,1433;Database=YourDB;User Id=sa;Password=MyStr0ng!Pass#2024;TrustServerCertificate=True;
```

### For SSMS (SQL Server Management Studio):
- Server: `localhost,1433`
- Authentication: SQL Server Authentication
- Login: `sa`
- Password: `MyStr0ng!Pass#2024`

## Rebuilding the Container

If you need to rebuild from scratch:

```powershell
# Stop and remove existing container
docker stop ssrs-dev
docker rm ssrs-dev

# Rebuild the image (takes 30-60 minutes)
cd C:\ssrs-dev\ssrs-build
docker build -t ssrs-local:latest .

# Run new container
docker run -d -p 1433:1433 -p 80:80 `
  -e ACCEPT_EULA=Y `
  -e sa_password="MyStr0ng!Pass#2024" `
  -e pbirs_user=SSRSAdmin `
  -e pbirs_password="SSRSAdmin!Pass#2024" `
  --memory 6g `
  --name ssrs-dev `
  ssrs-local:latest
```

## Troubleshooting

### Check container status
```powershell
docker ps -a
```

### Check container logs
```powershell
docker logs ssrs-dev
```

### Test SQL Server connection
```powershell
docker exec ssrs-dev powershell -Command "Invoke-Sqlcmd -Query 'SELECT @@VERSION' -ServerInstance 'localhost' -Username 'sa' -Password 'MyStr0ng!Pass#2024'"
```

### Restart container
```powershell
docker restart ssrs-dev
```
