# ADR 0001: Azure VM uden Nginx med fast public IP

## Status
Accepted

## Context
Projektet er et studieprojekt og skal vaere simpelt at drifte.

## Decision
Vi bruger en enkelt Azure VM med Docker Compose og en separat statisk public IP.
Vi bruger ikke Nginx i denne fase.

## Consequences
- Simpel deployment for begyndere.
- Samme IP-adresse bevares mellem opstarter.
- Mindre produktionshaerdning end en fuld reverse-proxy setup.
