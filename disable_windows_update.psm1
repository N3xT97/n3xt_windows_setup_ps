function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS", "STEP")]
        [string]$Level
    )

    $prefix = switch ($Level) {
        "INFO" { "[+]"; $color = "White" }
        "WARN" { "[!]"; $color = "Yellow" }
        "ERROR" { "[-]"; $color = "Red" }
        "SUCCESS" { "[+]"; $color = "Green" }
        "STEP" { "[>]"; $color = "Cyan" }
    }

    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$prefix [$time] $Message" -ForegroundColor $color
}

function Stop-WindowsUpdateService {
    $serviceStop = "wuauserv"
    Write-Log "`n다음 Windows 업데이트 관련 서비스가 중지 및 비활성화됩니다:" -Level "WARN"
    Write-Host " - $serviceStop"
    $confirm = Read-Host "정말로 중지 및 비활성화 하시겠습니까? (Y/N)"
    if ($confirm -ne 'Y') {
        Write-Log "작업이 취소되었습니다." -Level "WARN"
        return
    }

    Write-Log "Windows 업데이트 관련 서비스가 중지 및 비활성화를 시작합니다." -Level "STEP"
    try {
        Stop-Service -Name $serviceStop -Force -ErrorAction Stop
        Set-Service -Name $serviceStop -StartupType Disabled -ErrorAction Stop
        Write-Log "서비스 설정 완료: $serviceStop" -Level "INFO"
    }
    catch {
        Write-Log "서비스 설정 실패: $($_.Exception.Message)" -Level "ERROR"
    }
    Write-Log "Windows 업데이트 관련 서비스가 중지 및 비활성화가 완료됐습니다. (다시시작/로그오프 필요)" -Level "SUCCESS"
}

function Set-WindowsUpdateRegistry {
    $registryChanges = @(
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"; Name = "NoAutoUpdate"; Value = 1 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"; Name = "NoAutoRebootWithLoggedOnUsers"; Value = 1 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"; Name = "DODownloadMode"; Value = 0 }
    )

    Write-Log "`n다음 Windows 업데이트 비활성화 관련 레지스트리가 설정됩니다:" -Level "STEP"
    $registryChanges | ForEach-Object {
        Write-Host " - $($_.Path)\$($_.Name) = $($_.Value)"
    }
    $confirm = Read-Host "정말로 비활성화 하시겠습니까? (Y/N)"
    if ($confirm -ne 'Y') {
        Write-Log "작업이 취소되었습니다." -Level "WARN"
        return
    }


    Write-Log "Windows 업데이트 비활성화 관련 레지스트리가 설정을 시작합니다." -Level "STEP"
    foreach ($entry in $registryChanges) {
        try {
            # 경로가 없다면 생성
            if (-not (Test-Path $entry.Path)) {
                New-Item -Path $entry.Path -Force | Out-Null
            }

            Set-ItemProperty -Path $entry.Path -Name $entry.Name -Value $entry.Value -Force -ErrorAction Stop
            Write-Log "적용 완료: $($entry.Path)\$($entry.Name) = $($entry.Value)" -Level "INFO"
        }
        catch {
            Write-Log "적용 실패: $($entry.Path)\$($entry.Name) ($($_.Exception.Message))" -Level "ERROR"
        }
    }
    Write-Log "Windows 업데이트 비활성화 관련 레지스트리 설정이 완료됐습니다. (다시시작/로그오프 필요)" -Level "SUCCESS"
}

function Disable-WindowsUpdate {
    Set-WindowsUpdateRegistry
    Stop-WindowsUpdateService
}

Export-ModuleMember -Function Disable-WindowsUpdate
