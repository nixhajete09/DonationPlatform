# ADR 0003: Simpel validering af donationsbeloeb

## Status
Accepted

## Context
Vi vil arbejde i sma, sikre steps og beskytte mod ugyldige donationer.

## Decision
Vi indfoerer en lille model-metode i `Donation`: `valid_amount?`.
Metoden returnerer kun true for beloeb stoerre end 0.

## Consequences
- Ugyldige beloeb (nil og 0) afvises tidligt.
- Koden er enkel og let at teste isoleret.
