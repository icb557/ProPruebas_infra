#Requires -Version 5
param(
    [string]$WebServerPublicIp,
    [string]$SshPrivateKeyPath,
    [string]$RemoteUser,
    [string]$RemoteAngularAppPath,
    [string]$LocalFrontendProjectRoot, # Path to the parent of 'Frontend' directory, e.g., ../ProPruebas
    [string]$BackendAppUrlForFrontendBuild # e.g., http://<app_server_ip>:3000
)

Write-Host "Starting frontend deployment process for server: $WebServerPublicIp"
Write-Host "Backend URL for frontend build: $BackendAppUrlForFrontendBuild"

# 1. Navigate to the Frontend project directory
$frontendPath = Join-Path -Path $LocalFrontendProjectRoot -ChildPath "FrontEnd"
Write-Host "Frontend project path: $frontendPath"

if (-not (Test-Path $frontendPath)) {
    Write-Error "Frontend project path not found: $frontendPath"
    exit 1
}

Push-Location $frontendPath

# 2. Set the appUrl environment variable for the Angular build
#Write-Host "Setting APP_URL environment variable to $BackendAppUrlForFrontendBuild"
#$env:APP_URL = $BackendAppUrlForFrontendBuild

# 3. Execute the Angular build
#Write-Host "Building Angular application in $frontendPath ..."
# Ensure Angular CLI is globally installed or use npx
# Assuming Angular CLI is available in the PATH or you can use npx
# For npx: npx -p @angular/cli ng build --configuration=production
# If ng is globally available:
#ng build --configuration=production

# if ($LASTEXITCODE -ne 0) {
#     Write-Error "Angular build failed! APP_URL was $env:APP_URL"
#     Pop-Location
#     exit 1
# }
# Write-Host "Angular build successful."

# 4. Define the local path to the built artifacts
# Adjust this path if your angular.json 'outputPath' is different
$localDistPath = Join-Path -Path $frontendPath -ChildPath "dist\front-end\browser"

if (-not (Test-Path $localDistPath)) {
    Write-Error "Local dist path not found after build: $localDistPath. Check angular.json outputPath and project name."
    Pop-Location
    exit 1
}

Write-Host "Local artifacts path: $localDistPath"

# Add a delay to allow the EC2 instance to fully initialize SSH
$initialDelaySeconds = 60 # Adjust as needed, 30-60 seconds is often a good starting point
Write-Host "Waiting for $initialDelaySeconds seconds for SSH service to be ready on $WebServerPublicIp ..."
Start-Sleep -Seconds $initialDelaySeconds

# 5. Execute the SCP command
$scpSourcePath = "$localDistPath\*" # Copy all contents of the browser directory
$scpDestination = "${RemoteUser}@${WebServerPublicIp}:${RemoteAngularAppPath}/"

Write-Host "Copying files via SCP from $scpSourcePath to $scpDestination ..."

# SCP command. -o options for non-interactive execution.
# Ensure ssh.exe and scp.exe are in your PATH on Windows or provide full paths.
scp -i "$SshPrivateKeyPath" -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL -r "$scpSourcePath" "$scpDestination"

if ($LASTEXITCODE -ne 0) {
    Write-Error "SCP command failed!"
    Pop-Location
    exit 1
}

Write-Host "SCP command successful. Files copied to $RemoteAngularAppPath on the server."

Pop-Location
Write-Host "Frontend deployment script finished."
exit 0 