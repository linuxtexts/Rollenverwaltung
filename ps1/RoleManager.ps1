Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Write-Host "Starting, please wait 5-10 seconds"


Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Identity.Governance


# Configuration file path
$configPath = "C:\Rollen\role_config.json"

# Function to save configuration
function Save-RoleConfig {
    $config = @{}
    foreach ($checkbox in $checkboxes.Values) {
        $config[$checkbox.Tag] = $checkbox.Checked
    }
    $config | ConvertTo-Json | Set-Content $configPath
}

# Function to load configuration
function Load-RoleConfig {
    if (Test-Path $configPath) {
        $config = Get-Content $configPath | ConvertFrom-Json
        foreach ($checkbox in $checkboxes.Values) {
            if ($config.$($checkbox.Tag) -ne $null) {
                $checkbox.Checked = $config.$($checkbox.Tag)
            }
        }
    }
}

# Connecting to Microsoft Graph
Connect-MgGraph -Scopes "RoleManagement.ReadWrite.Directory", "Directory.Read.All"

# Get current user Principal ID
$currentUser = (Get-MgUser | Where-Object { $_.UserPrincipalName -like $(whoami -upn) }).Id
$PrincipalID = $currentUser

# List of roles with their names
$roles = @{
	"29232cdf-9323-42fd-ade2-1d097af3e4de" = "Exchange-Administrator"
    "194ae4cb-b126-40b2-bd5b-6091b380977d" = "SecurityAdmin"
    "62e90394-69f5-4237-9190-012177145e10" = "GlobalAdmin"
    "f28a1f50-f6e7-4571-818b-6a12f2af6b6c" = "SharePoint-Administrator"
    "fe930be7-5e62-47db-91af-98c3a49a38b1" = "BenutzerAdministrator"
    "9f06204d-73c1-4d4c-880a-6edb90606fd8" = "Microsoft Entra verknupftes Gerat lokaler Administrator"
    "69091246-20e8-4a56-aa4d-066075b2a7a8" = "Teams-Administrator"
    "3a2c62db-5318-420d-8d74-23affee5d9d5" = "Intune-Administrator"
    "c4e39bd9-1100-46d3-8c65-fb160da0071f" = "Authentifizierungsadministrator"
    "b0f54661-2d74-4c50-afa3-1ec803f12efe" = "SharePoint-Administrator"
    "31392ffb-586c-42d1-9346-e59415a2cc4e" = "Exchange-Empfanger-Administrator"
}

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Rollenverwaltung"
$form.Size = New-Object System.Drawing.Size(600,400)
$form.StartPosition = "CenterScreen"

# Create panel with checkboxes
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(550,300)
$panel.Location = New-Object System.Drawing.Point(20,20)
$panel.AutoScroll = $true

# Create checkboxes for each role
$checkboxes = @{}
$y = 10
foreach ($role in $roles.GetEnumerator()) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $role.Value
    $checkbox.Location = New-Object System.Drawing.Point(10,$y)
    $checkbox.Size = New-Object System.Drawing.Size(500,20)
    $checkbox.Tag = $role.Key
    $panel.Controls.Add($checkbox)
    $checkboxes[$role.Key] = $checkbox
    $y += 25
}

# Load saved configuration
Load-RoleConfig

# Role activation function
function ActivateRole {
    param (
        [string]$PrincipalID,
        [string]$RoleDefinitionID
    )

    $params = @{
        "PrincipalId"      = $PrincipalID
        "RoleDefinitionId" = $RoleDefinitionID
        "Justification"    = "Activate assignment"
        "DirectoryScopeId" = "/"
        "Action"           = "SelfActivate"
        "ScheduleInfo"     = @{
            "StartDateTime" = Get-Date
            "Expiration"    = @{
                "Type"     = "AfterDuration"
                "Duration" = "PT8H"
            }
        }
    }

    New-MgRoleManagementDirectoryRoleAssignmentScheduleRequest -BodyParameter $params
}

# Role deactivation function
function DeactivateRole {
    param (
        [string]$PrincipalID,
        [string]$RoleDefinitionID
    )

    $params = @{
        "PrincipalId"      = $PrincipalID
        "RoleDefinitionId" = $RoleDefinitionID
        "Justification"    = "Deactivate assignment"
        "DirectoryScopeId" = "/"
        "Action"           = "SelfDeactivate"
        "ScheduleInfo"     = @{
            "StartDateTime" = Get-Date
        }
    }

    New-MgRoleManagementDirectoryRoleAssignmentScheduleRequest -BodyParameter $params
}

# Create buttons
$btnActivate = New-Object System.Windows.Forms.Button
$btnActivate.Text = "Ausgewählte aktivieren"
$btnActivate.Location = New-Object System.Drawing.Point(20,330)
$btnActivate.Size = New-Object System.Drawing.Size(150,30)
$btnActivate.Add_Click({
    foreach ($checkbox in $checkboxes.Values) {
        if ($checkbox.Checked) {
            ActivateRole -PrincipalID $PrincipalID -RoleDefinitionID $checkbox.Tag
        }
    }
    [System.Windows.Forms.MessageBox]::Show("Rollen aktiviert", "Erfolg")
})

$btnDeactivate = New-Object System.Windows.Forms.Button
$btnDeactivate.Text = "Ausgewählte deaktivieren"
$btnDeactivate.Location = New-Object System.Drawing.Point(180,330)
$btnDeactivate.Size = New-Object System.Drawing.Size(150,30)
$btnDeactivate.Add_Click({
    foreach ($checkbox in $checkboxes.Values) {
        if ($checkbox.Checked) {
            DeactivateRole -PrincipalID $PrincipalID -RoleDefinitionID $checkbox.Tag
        }
    }
    [System.Windows.Forms.MessageBox]::Show("Rollen deaktiviert", "Erfolg")
})

# Add form closing event handler
$form.Add_FormClosing({
    Save-RoleConfig
})

# Add controls to form
$form.Controls.Add($panel)
$form.Controls.Add($btnActivate)
$form.Controls.Add($btnDeactivate)

# Show form
$form.ShowDialog() 