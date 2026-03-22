# ADR 0001: Brug Docker til lokal udvikling

## Status
Accepted

## Context
Projektet skal kunne startes ens på tværs af udvikleres computere.

## Decision
Vi bruger en Dockerfile til app-miljøet og docker-compose.yml til at starte web-servicen lokalt.

## Consequences
- Nemmere onboarding for nye udviklere.
- Ens runtime-miljø på tværs af teamet.
- Lidt længere første opstart pga. image build.
