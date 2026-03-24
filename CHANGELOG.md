# Changelog

Alle vigtige aendringer i projektet dokumenteres her.

## [Unreleased]

### Added
- Simpel model-validering: `Donation#valid_amount?` accepterer kun beloeb stoerre end 0.
- Isoleret RSpec-test i `spec/donation_spec.rb` for ugyldige beloeb (nil og 0).
- To Azure scripts: et script til at oprette/starte VM med fast public IP, og et script til at stoppe VM uden at miste IP.
- Dockerfile og .dockerignore til container build.
- GitHub Actions workflow til PR->main merge: build/push til GHCR og deploy til Azure VM via SSH.

### Changed
- Auth-siden renderes nu som Sinatra view (`erb :opret`) via `/auth` og `/opret`.
- Down-scriptet sletter nu VM helt og fortsatter kun cleanup, hvis public IP stadig er den samme.
- Down-scriptet kan nu auto-detektere korrekt resource group for VM og venter pa bekraeftet VM-sletning i Azure.
- Up-scriptet opretter nu automatisk SSH-nogler, hvis angivet public key-fil ikke findes.
