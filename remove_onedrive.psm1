function Remove-OneDrive {
    # ���� ���� ��� ���
    $pathsToRemove = @(
        "$env:UserProfile\OneDrive",
        "$env:LocalAppData\Microsoft\OneDrive",
        "$env:ProgramData\Microsoft OneDrive"
    )
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $regName = "OneDrive"

    
    Write-Host "`n[!] OneDrive ���� ���ϵ��� ���ŵ˴ϴ�:" -ForegroundColor Yellow
    $pathsToRemove | ForEach-Object { Write-Host " - $_" }
    Write-Host " - $regPath\$regName"

    $confirm = Read-Host "������ �����Ͻðڽ��ϱ�? (Y/N)"
    if ($confirm -ne 'Y') {
        Write-Host "`n[*] �۾��� ����߽��ϴ�."
        return
    }

    Write-Host "`n[+] OneDrive ��ġ ���� ����..."

    $exe = if ([Environment]::Is64BitOperatingSystem) {
        "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    }
    else {
        "$env:SystemRoot\System32\OneDriveSetup.exe"
    }

    if (Test-Path $exe) {
        Start-Process $exe -ArgumentList "/uninstall" -Wait
        Write-Host " - OneDrive ��ġ ���� �Ϸ�" -ForegroundColor Cyan
    }
    else {
        Write-Host " - OneDrive ��ġ ������ ã�� �� �����ϴ�." -ForegroundColor Red
        return
    }

    
    Write-Host "`n[+] OneDrive ���� ���� ����..."
    

    foreach ($path in $pathsToRemove) {        
        try {
            Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host " - ��� ���� �Ϸ�: $path" -ForegroundColor Cyan
            
        }
        catch {
            Write-Host " - ��� ���� ����: $path" -ForegroundColor Red
        }
    }

    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $regName = "OneDrive"
    try {
        Set-ItemProperty -Path $regPath  -Name $regName -Value $null -ErrorAction SilentlyContinue
        Write-Host " - ������Ʈ�� ���� �Ϸ�: $regPath\$regName" -ForegroundColor Cyan
        
    }
    catch {
        Write-Host " - ������Ʈ�� ���� ����: $regPath\$regName" -ForegroundColor Red
    }
    Write-Host "`n[*] OneDrive ���� �Ϸ�`n" -ForegroundColor Green
}


Export-ModuleMember -Function Remove-OneDrive