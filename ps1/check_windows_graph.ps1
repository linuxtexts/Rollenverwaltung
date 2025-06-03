# Check if the Microsoft.Graph module is installed
$module = Get-Module -ListAvailable -Name Microsoft.Graph

if (-not $module) {
    Write-Host "The 'Microsoft.Graph' module is not installed."

    # Ask the user if they want to install the module
    $install = Read-Host "Do you want to install the 'Microsoft.Graph' module? (Y/N)"

    if ($install -match '^[YyАаДд]') {
        try {
            # Attempt to install the module for the current user
            #Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
			Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force -Confirm:$false

            Write-Host "'Microsoft.Graph' module was successfully installed." -ForegroundColor Green
        } catch {
            # Handle installation errors
            Write-Host "Error during module installation: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Module installation was canceled by the user."
    }
} else {
    Write-Host "'Microsoft.Graph' module is already installed." -ForegroundColor Green
}
