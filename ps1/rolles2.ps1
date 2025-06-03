Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
#schreib bitte - powershell -File PathToFile
# Connecting to Microsoft Graph
Connect-MgGraph -Scopes "RoleManagement.ReadWrite.Directory", "Directory.Read.All"

# Get current user Principal ID
$currentUser = (Get-MgUser | Where-Object { $_.UserPrincipalName -like $(whoami -upn) }).Id
$PrincipalID = $currentUser

Write-Host "`n🧑 User ID: $PrincipalID"

# List of roles to manage
$roles = @(
    "f28a1f50-f6e7-4571-818b-6a12f2af6b6c", # SharePoint-Administrator
    "fe930be7-5e62-47db-91af-98c3a49a38b1", # User Administrator
    "9f06204d-73c1-4d4c-880a-6edb90606fd8", # Entra Joined Device - Local Admin
    "69091246-20e8-4a56-aa4d-066075b2a7a8", # Teams Administrator
    "3a2c62db-5318-420d-8d74-23affee5d9d5", # Intune Administrator
    "c4e39bd9-1100-46d3-8c65-fb160da0071f", # Authentication Administrator
    "b0f54661-2d74-4c50-afa3-1ec803f12efe", # SharePoint Administrator
    "31392ffb-586c-42d1-9346-e59415a2cc4e"  # Exchange Recipient Administrator
)

# Activation function
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

    Write-Host "Activating role: $RoleDefinitionID"
    New-MgRoleManagementDirectoryRoleAssignmentScheduleRequest -BodyParameter $params | Format-List Id, Status, RoleDefinitionId, PrincipalId, CreatedDateTime
}

# Deactivation function
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

    Write-Host "Deactivating role: $RoleDefinitionID"
    New-MgRoleManagementDirectoryRoleAssignmentScheduleRequest -BodyParameter $params | Format-List Id, Status, RoleDefinitionId, PrincipalId, CreatedDateTime
}

# Ask the user for action
Write-Host "`nChoose an action:"
Write-Host "1 - Activate roles"
Write-Host "2 - Deactivate roles"
$choice = Read-Host "Enter 1 or 2"

switch ($choice) {
    "1" {
        Write-Host "Starting role activation..."
        foreach ($roleID in $roles) {
            ActivateRole -PrincipalID $PrincipalID -RoleDefinitionID $roleID
        }
    }
    "2" {
        Write-Host "Starting role deactivation..."
        foreach ($roleID in $roles) {
            DeactivateRole -PrincipalID $PrincipalID -RoleDefinitionID $roleID
        }
    }
    Default {
        Write-Host "❗ Invalid selection. Exiting script."
    }
}
