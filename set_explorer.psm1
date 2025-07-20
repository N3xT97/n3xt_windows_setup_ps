function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS", "STEP")]
        [string]$Level = "INFO"
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

function Set-Explorer {
    $registryChanges = @(
        @{ Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "Hidden"; Value = 1 },
        @{ Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "HideFileExt"; Value = 0 },
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState"; Name = "FullPath"; Value = 1 },
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState"; Name = "FullPathAddress"; Value = 1 },
        @{ Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "LaunchTo"; Value = 1 }
    )

    Write-Log "`n다음 Explorer 관련 레지스트리가 설정됩니다:" -Level "WARN"
    $registryChanges | ForEach-Object {
        Write-Host " - $($_.Path)\$($_.Name) = $($_.Value)"
    }
    $confirm = Read-Host "정말로 설정하시겠습니까? (Y/N)"
    if ($confirm -ne 'Y') {
        Write-Log "작업을 취소했습니다." -Level "WARN"
        return
    }

    
    Write-Log "Explorer 관련 레지스트리 설정을 시작합니다." -Level "STEP"
    foreach ($entry in $registryChanges) {
        try {
            Set-ItemProperty -Path $entry.Path -Name $entry.Name -Value $entry.Value -Force -ErrorAction Stop
            Write-Log "적용 완료: $($entry.Path)\$($entry.Name) = $($entry.Value)" -Level "INFO"
        }
        catch {
            Write-Log "적용 실패: $($entry.Path)\$($entry.Name) ($($_.Exception.Message))" -Level "ERROR"
        }
    }

    Write-Log "Explorer 레지스트리 설정이 완료됐습니다. (다시시작/로그오프 필요)" -Level "SUCCESS"
}

Export-ModuleMember -Function Set-Explorer
