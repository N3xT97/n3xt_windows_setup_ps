function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS", "STEP")]
        [string]$Level
    )

    $prefix = switch ($Level) {
        "INFO" { "[+]" ; $color = "White" }
        "WARN" { "[!]" ; $color = "Yellow" }
        "ERROR" { "[-]" ; $color = "Red" }
        "SUCCESS" { "[*]" ; $color = "Green" }
        "STEP" { "[>]" ; $color = "Cyan" }
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$prefix [$timestamp] $Message" -ForegroundColor $color
}

function Test-OneDriveInstalled {
    $exePath = "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"
    if (Test-Path $exePath) {
        Write-Host " - OneDrive 설치가 확인됨."
        return $true
    }
    else {
        Write-Host " - OneDrive 설치가 확인되지 않음."
        return $false
    }
}

function Remove-OneDrive {
    Write-Log "`nOneDrive가 제거됩니다:" -Level "WARN"

    if (-not (Test-OneDriveInstalled)) {
        Write-Log "Onedrive가 설치돼있지 않습니다." -Level "SUCCESS"
        return
    }

    $confirm = Read-Host "정말로 제거하시겠습니까? (Y/N)"
    if ($confirm -ne 'Y') {
        Write-Log "작업을 취소했습니다." -Level "WARN"
        return
    }

    # 설치 제거
    Write-Log "OneDrive 설치 제거를 시작합니다." -Level "STEP"
    $onedriveExe = if ([Environment]::Is64BitOperatingSystem) {
        "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    }
    else {
        "$env:SystemRoot\System32\OneDriveSetup.exe"
    }

    if (Test-Path $onedriveExe) {
        try {
            Start-Process $onedriveExe -ArgumentList "/uninstall" -Wait -NoNewWindow
            Write-Log "OneDrive 설치 제거 완료." -Level "INFO"
        }
        catch {
            Write-Log "OneDrive 제거 실패: $($_.Exception.Message)" -Level "ERROR"
            return
        }
    }
    else {
        Write-Log "OneDrive 설치 파일을 찾을 수 없습니다: $onedriveExe" -Level "ERROR"
        return
    }

    Write-Log "OneDrive 제거 프로세스가 완료됐습니다." -Level "SUCCESS"
}

Export-ModuleMember -Function Remove-OneDrive
