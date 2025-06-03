$maxAttempts = 5
$attempt = 0
$success = $false

while (-not $success -and $attempt -lt $maxAttempts) {
    $attempt++

    Write-Host "Attempt $attempt of $maxAttempts"
    $securePassword = Read-Host -AsSecureString "Enter administrator password"
    
    # Universal username construction
    $usernameParts = $env:USERNAME -split '\.'
    $adminUser = if ($usernameParts.Count -gt 1) { "admin.$($usernameParts[1])" } else { "admin" }
    $username = "immo-nrw\$adminUser"

    $cred = New-Object System.Management.Automation.PSCredential($username, $securePassword)

    try {
        <## Start PowerShell script
        $proc = Start-Process powershell `
            -Credential $cred `
            -ArgumentList "-File \\fs1.immo-nrw.net\Trans$\#VERKNUEPFUNGEN\Rollen\ps1\check_windows_graph.ps1" `
            -WorkingDirectory "C:\Rollen\ps1" `
            -PassThru

        $proc.WaitForExit()

        Start-Process powershell `
			-Credential $cred `
			-ArgumentList "-File C:\Rollen\ps1\RoleManager.ps1" `
			-WorkingDirectory "C:\Rollen\ps1"
			Start-Sleep -Seconds 10
			Wait-Process -Id $proc.Id
			exit
		#>
        
		
		# Start the first .exe file
		$proc1 = Start-Process -FilePath "\\fs1.immo-nrw.net\Trans$\#VERKNUEPFUNGEN\Rollen\ps1\check_windows_graph.exe" `
			-Credential $cred `
			-WorkingDirectory "C:\Rollen\ps1" `
			-PassThru

		# Wait for the first process to complete
		$proc1.WaitForExit()

		# Start the second .exe file
		$proc2 = Start-Process -FilePath "C:\Rollen\ps1\RoleManager.exe" `
			-Credential $cred `
			-WorkingDirectory "C:\Rollen\ps1" `
			-PassThru

		# Pause for 10 seconds before completing
		Start-Sleep -Seconds 10

		# Wait for the second process to complete
		#Wait-Process -Id $proc2.Id

		# Exit the script
		exit
		$success = $true
		
    }
    catch {
        $errorMessage = $_.Exception.Message

        # Check for common access-related error messages in multiple languages
        $knownAccessErrors = @(
            "Access is denied",
            "Zugriff verweigert",
            "Benutzername.*falsch",
            "Kennwort.*falsch",
            "username.*incorrect",
            "password.*incorrect",
            "Der Benutzername oder das Kennwort ist falsch"
        )

        $matched = $false
        foreach ($pattern in $knownAccessErrors) {
            if ($errorMessage -match $pattern) {
                Write-Warning "Access denied. Wrong password or insufficient permissions. Please try again."
                $matched = $true
                break
            }
        }

        if (-not $matched) {
            Write-Error "Unexpected error: $_"
            break
        }
    }
}

if (-not $success) {
    Write-Host "Too many failed attempts. Exiting." -ForegroundColor Red
}
