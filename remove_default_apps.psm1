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

    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$prefix [$time] $Message" -ForegroundColor $color
}

function Remove-LocalApp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$appName
    )
    $localApp = Get-AppxPackage | Where-Object { $_.Name -like "*$appName*" }
    if (!$localApp) {
        Write-Log "Local 앱을 찾을 수 없음: $appName" -Level "WARN"
        return
    }

    try {
        $localApp | Remove-AppxPackage -ErrorAction Stop | Out-Null
        Write-Log "Local 앱 제거 완료: $appName" -Level "INFO"
    }
    catch {
        Write-Log "Local 앱 제거 실패: $appName ($($_.Exception.Message))" -Level "ERROR"
    }
}

function Remove-ProvisionedApp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$appName
    )
    $provApp = Get-ProvisionedAppxPackage -Online | Where-Object { $_.PackageName -like "*$appName*" }
    if (!$provApp) {
        Write-Log "Provisioned 앱을 찾을 수 없음: $appName" -Level "WARN"
        return
    }

    try {
        $provApp | Remove-ProvisionedAppxPackage -Online -ErrorAction Stop | Out-Null
        Write-Log "Provisioned 앱 제거 완료: $appName" -Level "INFO"
    }
    catch {
        Write-Log "Provisioned 앱 제거 실패: $appName ($($_.Exception.Message))" -Level "ERROR"
    }
}

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

    Write-Log "`n다음 기본 앱들이 제거됩니다:" -Level "WARN"
    $removableApps | ForEach-Object { Write-Host " - $_" }

    $confirm = Read-Host "정말로 이 앱들을 제거하시겠습니까? (Y/N)"
    if ($confirm -ne 'Y') {
        Write-Log "작업을 취소했습니다." -Level "WARN"
        return
    }

    Write-Log "기본 앱 제거를 시작합니다." -Level "STEP"

    foreach ($app in $removableApps) {
        Remove-LocalApp -appName $app
        Remove-ProvisionedApp -appName $app
    }

    Write-Log "기본 앱 제거가 완료됐습니다." -Level "SUCCESS"
}

Export-ModuleMember -Function Remove-DefaultApps
