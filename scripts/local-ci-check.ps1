param(
    [switch]$SkipBundleInstall,
    [switch]$SkipDockerBuild,
    [switch]$RunDockerSmokeTest
)

$ErrorActionPreference = 'Stop'

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Assert-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Missing required command: $Name"
    }
}

Assert-Command bundle

if (-not $SkipDockerBuild -or $RunDockerSmokeTest) {
    Assert-Command docker
}

if (-not $SkipBundleInstall) {
    Write-Step "Installing gems"
    bundle install
}

Write-Step "Running RuboCop"
bundle exec rubocop --fail-level E --display-only-fail-level-offenses

Write-Step "Running Reek (advisory)"
bundle exec reek app app.rb
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Reek found smells (advisory only). Continuing..."
}

Write-Step "Running RSpec"
bundle exec rspec

if (-not $SkipDockerBuild) {
    Write-Step "Building Docker image"
    docker build -t donationplatform:local .
}

if ($RunDockerSmokeTest) {
    Write-Step "Running Docker smoke test"

    $containerName = "donationplatform-local-check"

    if (docker ps -a --format '{{.Names}}' | Select-String -Pattern "^$containerName$") {
        docker rm -f $containerName | Out-Null
    }

    docker run -d --name $containerName -p 4567:4567 donationplatform:local | Out-Null

    try {
        Start-Sleep -Seconds 6
        $response = Invoke-WebRequest -Uri "http://localhost:4567" -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -lt 200 -or $response.StatusCode -ge 400) {
            throw "Smoke test failed with HTTP status: $($response.StatusCode)"
        }
        Write-Host "Smoke test passed with status $($response.StatusCode)." -ForegroundColor Green
    }
    finally {
        docker rm -f $containerName | Out-Null
    }
}

Write-Host ""
Write-Host "Local CI checks completed successfully." -ForegroundColor Green
