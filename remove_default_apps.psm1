function Remove-DefaultApps {
    $removableApps = @(
        # "Microsoft.AAD.BrokerPlugin",
        # "Microsoft.AccountsControl",
        # "Microsoft.AsyncTextService",
        # "Microsoft.BioEnrollment",
        # "Microsoft.CredDialogHost",
        # "Microsoft.ECApp",
        # "Microsoft.LockApp",
        # "Microsoft.MicrosoftEdgeDevToolsClient",
        # "Microsoft.MicrosoftEdge",
        # "Microsoft.MicrosoftEdge.Stable",
        # "Microsoft.Win32WebViewHost",
        # "Microsoft.Windows.Apprep.ChxApp",
        # "Microsoft.Windows.AssignedAccessLockApp",
        # "Microsoft.Windows.CallingShellApp",
        # "Microsoft.Windows.CapturePicker",
        # "Microsoft.Windows.CloudExperienceHost",
        # "Microsoft.Windows.ContentDeliveryManager",
        # "Microsoft.Windows.NarratorQuickStart",
        # "Microsoft.Windows.OOBENetworkCaptivePortal",
        # "Microsoft.Windows.OOBENetworkConnectionFlow",
        # "Microsoft.Windows.ParentalControls",
        # "Microsoft.Windows.PeopleExperienceHost",
        # "Microsoft.Windows.PinningConfirmationDialog",
        # "Microsoft.Windows.Search",
        # "Microsoft.Windows.SecHealthUI",
        # "Microsoft.Windows.SecureAssessmentBrowser",
        # "Microsoft.Windows.ShellExperienceHost",
        # "Microsoft.Windows.StartMenuExperienceHost",
        # "Microsoft.Windows.XGpuEjectDialog",
        # "Microsoft.XboxGameCallableUI",
        # "MicrosoftWindows.Client.CBS",
        # "MicrosoftWindows.UndockedDevKit",
        # "NcsiUwpApp",
        # "Windows.CBSPreview",
        # "windows.immersivecontrolpanel",
        # "Windows.PrintDialog",
        # "Microsoft.549981C3F5F10",
        # "Microsoft.Services.Store.Engagement",
        # "Microsoft.Services.Store.Engagement",
        # "Microsoft.UI.Xaml.2.0",
        # "Microsoft.NET.Native.Runtime.1.7",
        # "Microsoft.NET.Native.Framework.1.7",
        # "Microsoft.VCLibs.140.00",
        # "Microsoft.VCLibs.140.00.UWPDesktop",
        # "Microsoft.NET.Native.Runtime.2.2",
        # "Microsoft.NET.Native.Framework.2.2",
        # "Microsoft.Advertising.Xaml",
        "Microsoft.BingWeather",
        # "Microsoft.DesktopAppInstaller",
        # "Microsoft.GetHelp",
        "Microsoft.Getstarted",
        # "Microsoft.HEIFImageExtension",
        "Microsoft.Microsoft3DViewer",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.MicrosoftStickyNotes",
        # "Microsoft.MixedReality.Portal",
        # "Microsoft.MSPaint",
        "Microsoft.Office.OneNote",
        "Microsoft.People",
        # "Microsoft.ScreenSketch",
        "Microsoft.SkypeApp",
        # "Microsoft.StorePurchaseApp",
        # "Microsoft.VP9VideoExtensions",
        # "Microsoft.Wallet",
        # "Microsoft.WebMediaExtensions",
        # "Microsoft.WebpImageExtension",
        "Microsoft.Windows.Photos",
        "Microsoft.WindowsAlarms",
        "Microsoft.WindowsCalculator",
        "Microsoft.WindowsCamera",
        "microsoft.windowscommunicationsapps",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.WindowsMaps",
        "Microsoft.WindowsSoundRecorder",
        # "Microsoft.WindowsStore",
        "Microsoft.Xbox.TCUI",
        "Microsoft.XboxApp",
        "Microsoft.XboxGameOverlay",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.YourPhone",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo"
    )
    
    Write-Host "`n[!] 다음 기본 앱들이 제거됩니다:" -ForegroundColor Yellow
    $removableApps | ForEach-Object { Write-Host " - $_" }

    $confirm = Read-Host "정말로 이 앱들을 제거하시겠습니까? (Y/N)"
    if ($confirm -ne 'Y') {
        Write-Host "`n[*] 작업을 취소했습니다."
        return
    }

    Write-Host "`n[+] 기본 앱 제거 시작..."
    foreach ($app in $removableApps) {
        try {
            Get-AppxPackage -Name $app | Remove-AppxPackage -ErrorAction Stop
            Write-Host " - Local 앱 제거 완료: $app" -ForegroundColor Cyan
        }
        catch {
            Write-Host " - Local 앱 제거 실패: $app ($($_.Exception.Message))" -ForegroundColor Red
        }

        try {
            $provApp = Get-ProvisionedAppxPackage -Online | Where-Object { $_.PackageName -like "*$app*" }
            if ($provApp) {
                $provApp | Remove-ProvisionedAppxPackage -Online -ErrorAction Stop | Out-Null
                Write-Host " - Provisioned 앱 제거 완료: $app" -ForegroundColor Cyan
            }
        }
        catch {
            Write-Host " - Provisioned 앱 제거 실패: $app ($($_.Exception.Message))" -ForegroundColor Red
        }
    }
    Write-Host "`n[*] 기본 앱 제거 완료`n" -ForegroundColor Green
}

Export-ModuleMember -Function Remove-defaultApps

