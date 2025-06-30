function Remove-OneDrive {
    # 흔적 제거 경로 목록
    $pathsToRemove = @(
        "$env:UserProfile\OneDrive",
        "$env:LocalAppData\Microsoft\OneDrive",
        "$env:ProgramData\Microsoft OneDrive"
    )
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $regName = "OneDrive"

    
    Write-Host "`n[!] OneDrive 관련 파일들이 제거됩니다:" -ForegroundColor Yellow
    $pathsToRemove | ForEach-Object { Write-Host " - $_" }
    Write-Host " - $regPath\$regName"

    $confirm = Read-Host "정말로 제거하시겠습니까? (Y/N)"
    if ($confirm -ne 'Y') {
        Write-Host "`n[*] 작업을 취소했습니다."
        return
    }

    Write-Host "`n[+] OneDrive 설치 제거 시작..."

    $exe = if ([Environment]::Is64BitOperatingSystem) {
        "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    }
    else {
        "$env:SystemRoot\System32\OneDriveSetup.exe"
    }

    if (Test-Path $exe) {
        Start-Process $exe -ArgumentList "/uninstall" -Wait
        Write-Host " - OneDrive 설치 제거 완료" -ForegroundColor Cyan
    }
    else {
        Write-Host " - OneDrive 설치 파일을 찾을 수 없습니다." -ForegroundColor Red
        return
    }

    
    Write-Host "`n[+] OneDrive 흔적 제거 시작..."
    

    foreach ($path in $pathsToRemove) {        
        try {
            Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host " - 경로 제거 완료: $path" -ForegroundColor Cyan
            
        }
        catch {
            Write-Host " - 경로 제거 실패: $path" -ForegroundColor Red
        }
    }

    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $regName = "OneDrive"
    try {
        Set-ItemProperty -Path $regPath  -Name $regName -Value $null -ErrorAction SilentlyContinue
        Write-Host " - 레지스트리 제거 완료: $regPath\$regName" -ForegroundColor Cyan
        
    }
    catch {
        Write-Host " - 레지스트리 제거 실패: $regPath\$regName" -ForegroundColor Red
    }
    Write-Host "`n[*] OneDrive 제거 완료`n" -ForegroundColor Green
}


Export-ModuleMember -Function Remove-OneDrive