# ADR 0002: PR-merge til main udloeser build, push og deploy

## Status
Accepted

## Context
Teamet vil have enkel automatisering efter PR merge til main.

## Decision
Vi bruger et GitHub Actions workflow, der ved merge af PR til main:
1. bygger Docker image
2. pusher image til ghcr.io
3. deployer ny container pa Azure VM via SSH

## Consequences
- Ensartet deployment-flow ved merge til main.
- Hurtigere release uden manuelle deploy-trin.
- Kraver GitHub Secrets for VM-SSH og GHCR pull.
