# ####################### Install ######################
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

Add-WindowsCapability -Online -Name OpenSSH.Server*
Add-WindowsCapability -Online -Name OpenSSH.Client*

# Start the sshd service
# Start-Service sshd
Start-Service ssh-agent

# OPTIONAL but recommended:
# Set-Service -Name sshd -StartupType 'Automatic'
Set-Service -Name ssh-agent -StartupType 'Automatic'

# Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
# if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
#     Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
#     New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
# } else {
#     Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
# }


# ####################### Uninstall ######################
# # Uninstall the OpenSSH Client
# Remove-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# # Uninstall the OpenSSH Server
# Remove-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
