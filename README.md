# DonationPlatform - En sikker og transparent donationsplatform

## Oversigt

DonationPlatform er en donationsplatform bygget med Ruby og Sinatra, designet til at gøre det nemt og sikkert for velgørende organisationer, foreninger og enkeltpersoner at samle ind til deres formål.

## Tech Stack

- **Backend**: Ruby + Sinatra
- **Database**: SQLite (udvikling), PostgreSQL (produktion)
- **Frontend**: HTML, CSS, JavaScript
- **Testing**: RSpec, Rack::Test

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

## Features (i udvikling)

- [ ] Kampagneoprettelse og -styring
- [ ] Donationsflow
- [ ] Brugerauthentification
- [ ] Analytics dashboard
- [ ] Skatterapportering
- [ ] Email-notifikationer
- [ ] GDPR-compliance

## Dokumentation

Se `/docs` for arkitektur-beslutninger, skaleringsplan (v2) og vibecodingproces.

## Seneste lille step

- Tilfoejet `GET /indsamling` som renderer `app/views/indsamling.erb`.
- Tilfoejet isoleret test i `spec/indsamling_route_spec.rb`.