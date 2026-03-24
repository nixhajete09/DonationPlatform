# ADR 0001: Separat route til indsamling-siden

## Status
Accepted

## Context
Vi har en `indsamling.erb` view-fil, men manglede en direkte GET-route til siden.

## Decision
Vi tilføjer en enkel Sinatra route: `GET /indsamling` som renderer `erb :indsamling`.

## Consequences
- Siden kan tilgås direkte via URL.
- Let at teste isoleret med en simpel route-test.
