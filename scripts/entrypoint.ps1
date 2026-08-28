param(
    [string]$sa_password    = $env:SA_PASSWORD,
    [string]$ACCEPT_EULA    = $env:ACCEPT_EULA,
    [string]$attach_dbs     = $env:attach_dbs,
    [string]$pbirs_user     = $env:pbirs_user,
    [string]$pbirs_password = $env:pbirs_password
)

Write-Host "=========================================="
Write-Host "  PBIRS Docker Container Starting..."
Write-Host "=========================================="
Write-Host "  User: $pbirs_user"
Write-Host "  Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host ""

try {
    # Stage 1 - SQL Server
    Write-Host "[1/4] Starting SQL Server..."
    C:/scripts/start-mssql.ps1 -sa_password $sa_password -ACCEPT_EULA $ACCEPT_EULA -attach_dbs "$attach_dbs"
    Write-Host "[OK] SQL Server service started"

    $timeout = 60
    $elapsed = 0
    $connected = $false
    do {
        try {
            $conn = New-Object System.Data.SqlClient.SqlConnection(
                "Server=localhost;Database=master;User Id=sa;Password=$sa_password;TrustServerCertificate=true;Encrypt=false;"
            )
            $conn.Open()
            $conn.Close()
            $connected = $true
        } catch {
            Start-Sleep 5
            $elapsed += 5
            Write-Host "  ... waiting for MSSQLSERVER ($elapsed s)"
        }
    } while (-not $connected -and $elapsed -lt $timeout)

    if (-not $connected) { throw "SQL Server failed to start within ${timeout}s" }
    Write-Host "[OK] SQL Server connection established (localhost:1433)"
    Write-Host ""

    # Stage 2 - PBIRS service
    Write-Host "[2/4] Starting PBIRS service..."
    Start-Service PowerBIReportServer -ErrorAction SilentlyContinue
    Write-Host "[OK] PowerBIReportServer started"
    Write-Host ""

    # Stage 3 - Configuration
    Write-Host "[3/4] Configuring PBIRS..."
    C:/scripts/configure-pbirs.ps1
    Write-Host "[OK] PBIRS configured"

    C:/scripts/configure-admin.ps1 -username $pbirs_user -password $pbirs_password
    Write-Host "[OK] Admin account provisioned: $pbirs_user"

    C:/scripts/restore-pbirs-key.ps1
    Write-Host "[OK] Encryption key restored"
    Write-Host ""

    # Stage 4 - Health loop
    Write-Host "[4/4] Container ready!"
    Write-Host "=========================================="
    Write-Host "  Reports:  http://localhost/reports"
    Write-Host "  API:      http://localhost/reports/api/v2.0"
    Write-Host "  SQL:      localhost:1433"
    Write-Host "  User:     $pbirs_user"
    Write-Host "  Password: $pbirs_password"
    Write-Host "=========================================="
    Write-Host ""

    $uptimeSeconds = 0
    while ($true) {
        Start-Sleep 30
        $uptimeSeconds += 30
        $uptime = if ($uptimeSeconds -ge 3600) {
            "{0}h {1}m" -f [math]::Floor($uptimeSeconds/3600), [math]::Floor(($uptimeSeconds%3600)/60)
        } else {
            "{0}m" -f [math]::Floor($uptimeSeconds/60)
        }

        $statuses = [ordered]@{}
        foreach ($svc in @("MSSQLSERVER", "PowerBIReportServer")) {
            $s = Get-Service $svc -ErrorAction SilentlyContinue
            $statuses[$svc] = ($s -and $s.Status -eq "Running")
            if (-not $statuses[$svc]) {
                Write-Host "[WARN] Service $svc is down, restarting..."
                try { Start-Service $svc -ErrorAction Stop }
                catch { Write-Host "[ERROR] Could not restart $svc - $($_.Exception.Message)" }
            }
        }

        $statusLine = "Health check ($uptime): "
        foreach ($name in $statuses.Keys) {
            $ok = $statuses[$name]
            if ($ok) { $statusLine += "$name=OK " }
            else { $statusLine += "$name=DOWN " }
        }
        Write-Host $statusLine
    }
}
catch {
    Write-Host ""
    Write-Host "[ERROR] Container startup failed: $($_.Exception.Message)"
    exit 1
}
