# DonationPlatform - En sikker og transparent donationsplatform

[![Pull Request Checks](https://github.com/nixhajete09/DonationPlatform/actions/workflows/pr-checks.yml/badge.svg)](https://github.com/nixhajete09/DonationPlatform/actions/workflows/pr-checks.yml)

[![Build And Deploy On PR To Main](https://github.com/nixhajete09/DonationPlatform/actions/workflows/deploy-main-pr.yml/badge.svg)](https://github.com/nixhajete09/DonationPlatform/actions/workflows/deploy-main-pr.yml)

## Oversigt

DonationPlatform er en donationsplatform bygget med Ruby og Sinatra, designet til at gøre det nemt og sikkert for velgørende organisationer, foreninger og enkeltpersoner at samle ind til deres formål.

## Tech Stack

- **Backend**: Ruby + Sinatra
- **Database**: SQLite (udvikling), PostgreSQL (produktion)
- **Frontend**: HTML, CSS, JavaScript
- **Testing**: RSpec, Rack::Test
- **Code Smell Review**: Reek (korer i pull requests)

## Projektstruktur

```
DonationPlatform/
├── app.rb                 # Hovedapplikation
├── Gemfile               # Ruby dependencies
├── .gitignore
├── README.md
├── app/
│   ├── models/           # Database models
│   ├── routes/           # API og web routes
│   └── views/            # ERB templates
├── public/
│   └── css/              # Stylesheets
└── spec/                 # Tests (TDD)
```

## Installation & Kørsel

```bash
# Install dependencies
bundle install

# Kør applikationen
ruby app.rb
```

Besøg: `http://localhost:4567`

## Pre-commit Code Review

Aktiver pre-commit hook lokalt (kør én gang):

```bash
git config core.hooksPath .githooks
```

Hooks kører automatisk før commit:
- `bundle exec rubocop --fail-level E --display-only-fail-level-offenses`
- `bundle exec rspec`

Reek korer kun i pull request workflow (advisory), ikke i pre-commit.

## Lokal CI-check (uden act)

Koer hele den lokale check-sekvens med en kommando:

```powershell
.\scripts\local-ci-check.ps1
```

Valgfrie flags:
- `-SkipBundleInstall` (hvis gems allerede er installeret)
- `-SkipDockerBuild` (hvis du kun vil koere Ruby checks)
- `-RunDockerSmokeTest` (starter container kort og laver HTTP smoke test)

## Features (i udvikling)

- [ ] Kampagneoprettelse og -styring
- [ ] Donationsflow
- [ ] Brugerauthentification
- [ ] Analytics dashboard
- [ ] Skatterapportering
- [ ] Email-notifikationer
- [ ] GDPR-compliance

## Dokumentation

Se `documentation.md` for samlet dokumentation.

## Seneste lille step (TDD light)

- Tilfoejet `Donation#valid_amount?`, som kun accepterer beloeb > 0.
- Tilfoejet isoleret test i `spec/donation_spec.rb`.
- Auth-siden er flyttet til Sinatra view: `app/views/opret.erb` (aabnes pa `/auth` eller `/opret`).

Koer kun denne test:

```bash
bundle exec rspec spec/donation_spec.rb
```

## Azure VM (simpel projektdrift)

Forudsat at Azure CLI er installeret og du er logget ind:

```powershell
az login
```

Byg/start VM (bevarer fast public IP mellem genstarter):

```powershell
./scripts/azure-vm-up.ps1
```

Luk VM ned uden at miste IP:

```powershell
./scripts/azure-vm-down.ps1
```

Løbende beslutninger og ændringer:
- ADR: `docs/adr/`
- Changelog: `CHANGELOG.md`

## CI/CD (PR -> main)

Workflow: `.github/workflows/deploy-main-pr.yml`

Naar en PR til `main` bliver merged:
- Docker image bygges
- Image pushes til `ghcr.io`
- Azure VM opdateres via SSH

Noedvendige GitHub Secrets:
- `AZURE_VM_HOST` (VM public IP eller DNS)
- `AZURE_VM_USER` (SSH bruger)
- `AZURE_VM_SSH_KEY` (privat SSH noegle)
- `GHCR_USERNAME` (GitHub brugernavn)
- `GHCR_PAT` (PAT med mindst `read:packages`)