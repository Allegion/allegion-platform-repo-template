# ============================================================
# setup-repo-variables.ps1
# ============================================================
# Run this ONCE after creating a repo from the Allegion template.
# Requires GitHub CLI (gh) installed and authenticated: gh auth login
#
# USAGE:
#   .\scripts\setup-repo-variables.ps1 -Repo "Allegion/<your-repo-name>"
#
# OPTIONAL - supply values directly to skip interactive prompts:
#   .\scripts\setup-repo-variables.ps1 `
#     -Repo "Allegion/<your-repo-name>" `
#     -AzureClientId "<client-id>" `
#     -AzureTenantId "<tenant-id>" `
#     -AzureSubscriptionId "<subscription-id>"
# ============================================================

param(
    [Parameter(Mandatory = $true)]
    [string]$Repo,
    [string]$AzureClientId,
    [string]$AzureTenantId,
    [string]$AzureSubscriptionId
)

function Set-RepoVariable {
    param([string]$Repo, [string]$Name, [string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) {
        Write-Host "  Skipping $Name (no value provided - set it later in Settings > Variables)" -ForegroundColor Yellow
        return
    }
    gh variable set $Name --repo $Repo --body $Value
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK $Name set" -ForegroundColor Green
    } else {
        Write-Host "  FAILED to set $Name" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Setting up repo variables for: $Repo" -ForegroundColor Cyan
Write-Host "------------------------------------------"

if (-not $AzureClientId) {
    $AzureClientId = Read-Host "  AZURE_CLIENT_ID (App Registration Client ID) [leave blank to skip]"
}
if (-not $AzureTenantId) {
    $AzureTenantId = Read-Host "  AZURE_TENANT_ID (Azure AD Tenant ID) [leave blank to skip]"
}
if (-not $AzureSubscriptionId) {
    $AzureSubscriptionId = Read-Host "  AZURE_SUBSCRIPTION_ID (Azure Subscription ID) [leave blank to skip]"
}

Write-Host ""
Write-Host "Setting repository variables..." -ForegroundColor Cyan
Set-RepoVariable -Repo $Repo -Name "AZURE_CLIENT_ID"       -Value $AzureClientId
Set-RepoVariable -Repo $Repo -Name "AZURE_TENANT_ID"       -Value $AzureTenantId
Set-RepoVariable -Repo $Repo -Name "AZURE_SUBSCRIPTION_ID" -Value $AzureSubscriptionId

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Add secrets in GitHub UI: Settings > Secrets and variables > Actions > Secrets"
Write-Host "       - BLACKDUCK_API_TOKEN"
Write-Host "       - SONARQUBE_TOKEN"
Write-Host "  2. Run the 'Setup Repository' workflow in Actions tab to create GitHub environments"
Write-Host "  3. Update the TODO items in .github/workflows/dotnet-ci-cd.yml (or angular-ci-cd.yml)"
Write-Host ""