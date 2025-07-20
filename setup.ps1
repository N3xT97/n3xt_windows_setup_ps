Import-Module ".\remove_default_apps.psm1"
Import-Module ".\remove_onedrive.psm1"
# Import-Module ".\set_startmenu.psm1"
Import-Module ".\set_explorer.psm1"
Import-Module ".\set_taskbar.psm1"
Import-Module ".\disable_windows_update.psm1"

# Powershell 5.1 버전에서 한글을 출력하려면,
# PS1 파일을 UTF8 with BOM 포맷으로 저장 후 아래 명령어를 실행해야 함.
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# SetUp 함수들 출력
Remove-DefaultApps


Remove-OneDrive


Set-Explorer


Set-Taskbar


Disable-WindowsUpdate

# Set-StartMenu -layoutXmlPath ".\start_menu_layout.xml"
