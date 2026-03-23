# DonationPlatform Documentation

## Oversigt

DonationPlatform er en donationsplatform bygget med Ruby og Sinatra, designet til at gore det nemt og sikkert for velgorende organisationer, foreninger og enkeltpersoner at samle ind til deres formal.

## Tech Stack

- Backend: Ruby + Sinatra
- Database: SQLite (udvikling), PostgreSQL (produktion)
- Frontend: HTML, CSS, JavaScript
- Testing: RSpec, Rack::Test
- CI: GitHub Actions (RuboCop + RSpec pa pull requests)
- Code smell review: Reek (advisory pa pull requests)

## Projektstruktur

```text
DonationPlatform/
|-- app.rb                 # Hovedapplikation
|-- Gemfile                # Ruby dependencies
|-- .gitignore
|-- documentation.md
|-- app/
|   |-- models/            # Database models
|   |-- routes/            # API og web routes
|   `-- views/             # ERB templates
|-- public/
|   `-- css/               # Stylesheets
|-- .github/
|   `-- workflows/
|       `-- pr-checks.yml
`-- spec/                  # Tests (TDD)
```

## Installation og Korsel

```bash
bundle install
ruby app.rb
```

Besog: http://localhost:4567

## Pre-commit code review

Aktiver hooks lokalt (kor en gang):

```bash
git config core.hooksPath .githooks
```

Pre-commit korer:
- bundle exec rubocop --fail-level E --display-only-fail-level-offenses
- bundle exec rspec

Reek korer kun i pull request workflow (advisory), ikke i pre-commit.

## Lokal CI-check (uden act)

Der er et helper-script til lokal validering af samme checks som i PR-flowet.

Koer:

```powershell
.\scripts\local-ci-check.ps1
```

Valgfrie flags:
- `-SkipBundleInstall`
- `-SkipDockerBuild`
- `-RunDockerSmokeTest`

## Features (i udvikling)

- [ ] Kampagneoprettelse og -styring
- [ ] Donationsflow
- [ ] Brugerauthentification
- [ ] Analytics dashboard
- [ ] Skatterapportering
- [ ] Email-notifikationer
- [ ] GDPR-compliance

## Changelog

### Unreleased

#### Added
- GitHub Actions workflow for pull request checks (rubocop --fail-level E + rspec).
- ADR 0001 documenting the pull request checks decision.
- .rubocop.yml baseline config (NewCops: disable).
- Reek advisory check pa pull requests (ikke i pre-commit).

## ADR 0001: Pull Request Workflow Checks

- Date: 2026-03-19
- Status: Accepted

### Decision
We run automated checks on every pull request using GitHub Actions.
The checks are:
- bundle exec rubocop --fail-level E --display-only-fail-level-offenses
- bundle exec reek app app.rb (advisory)
- bundle exec rspec

### Why
- Catch style and test issues early.
- Keep reviews focused on functionality and architecture.
- Support small, safe commits in a beginner-friendly workflow.

### Consequences
- Pull requests get fast feedback before merge.
- Contributors must fix lint and test failures before merge.
- Existing style debt does not block new pull requests immediately.
