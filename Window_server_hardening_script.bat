

:: Create the directory on D drive if it doesn't exist
mkdir "C:\VAPT_Output"

:: Run commands and direct output to the folder
ipconfig /all >> "C:\VAPT_Output\ip.txt"
ipconfig /displaydns >> "C:\VAPT_Output\dns.txt"
systeminfo >> "C:\VAPT_Output\sys.txt"
powershell -command "Get-LocalUser | select-Object * | Export-Csv 'C:\VAPT_Output\localusers.csv'"
netstat -anob >> "C:\VAPT_Output\netstat.txt"
powershell -command "get-smbserverconfiguration >> 'C:\VAPT_Output\smb.txt'"
netsh advfirewall show allprofiles >> "C:\VAPT_Output\fw.txt"
net accounts >> "C:\VAPT_Output\passpol.txt"
powershell -command "Get-SMBShare >> 'C:\VAPT_Output\shares.txt'"
auditpol.exe /get /category:* >> "C:\VAPT_Output\auditpol.txt"
w32tm /query /peers >> "C:\VAPT_Output\ntp.txt"
tasklist -v >> "C:\VAPT_Output\tasks.txt"
gpresult /V >> "C:\VAPT_Output\gpo.txt"
schtasks >> "C:\VAPT_Output\sch.txt"
manage-bde -status >> "C:\VAPT_Output\bitlock.txt"
powershell -command "Get-Hotfix >> 'C:\VAPT_Output\hotfix.txt'"
powershell -command "Get-WmiObject -Namespace 'root\SecurityCenter2' -Class AntiVirusProduct >> 'C:\VAPT_Output\avstatus.txt'"
powershell -command "Get-Service | Select-Object * | Export-Csv 'C:\VAPT_Output\services.csv'"
powershell -command "Get-WmiObject win32_videocontroller | select * | Export-csv 'C:\VAPT_Output\videocard.csv'"
dism /online /get-features /format:table | find "Enabled" >> "C:\VAPT_Output\features.txt"
cmdkey /list >> "C:\VAPT_Output\credman.txt"
powershell -command "Confirm-SecureBootUEFI >> 'C:\VAPT_Output\Secure-Boot.txt'"
powershell -command "Get-FileHash -Algorithm SHA1 C:\Windows\System32\drivers\* >> 'C:\VAPT_Output\loldrivers.txt'"

:: Additional wmic and w32tm commands
wmic logicaldisk get caption, description >> "C:\VAPT_Output\logicaldisk.txt"
wmic qfe list >> "C:\VAPT_Output\qfe.txt"
wmic bios get serialnumber >> "C:\VAPT_Output\bios_serial.txt"
wmic csproduct get name >> "C:\VAPT_Output\csproduct_name.txt"
wmic csproduct get vendor >> "C:\VAPT_Output\csproduct_vendor.txt"
wmic csproduct get version >> "C:\VAPT_Output\csproduct_version.txt"
wmic computersystem get pcSystemType >> "C:\VAPT_Output\pcSystemType.txt"
w32tm /query /status >> "C:\VAPT_Output\w32tm_status.txt"

:: New command for OS Name and OS Version
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" >> "C:\VAPT_Output\os_info.txt"

:: New netsh commands for firewall and wlan
netsh firewall show state >> "C:\VAPT_Output\netsh_firewall_state.txt"
netsh advfirewall show allprofiles state >> "C:\VAPT_Output\netsh_advfirewall_state.txt"
netsh advfirewall show allprofiles firewallpolicy >> "C:\VAPT_Output\netsh_advfirewall_policy.txt"
netsh advfirewall show allprofiles settings >> "C:\VAPT_Output\netsh_advfirewall_settings.txt"
netsh advfirewall show allprofiles logging >> "C:\VAPT_Output\netsh_advfirewall_logging.txt"
netsh wlan show profiles >> "C:\VAPT_Output\netsh_wlan_profiles.txt"

:: New commands for net share, net user, and net accounts
net share >> "C:\VAPT_Output\net_share.txt"
net user >> "C:\VAPT_Output\net_user.txt"
net accounts >> "C:\VAPT_Output\net_accounts.txt"

:: Open Control Panel items (these are not affected by the output redirection)
appwiz.cpl
slmgr /dlv
Sysdm.cpl
start windowsdefender:
control update