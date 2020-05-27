# incidents

[![Build Status](https://travis-ci.org/umts/incidents.svg?branch=master)](https://travis-ci.org/umts/incidents)
[![Code Climate](https://codeclimate.com/github/umts/incidents/badges/gpa.svg)](https://codeclimate.com/github/umts/incidents)
[![Test Coverage](https://codeclimate.com/github/umts/incidents/badges/coverage.svg)](https://codeclimate.com/github/umts/incidents/coverage)

This is a prototype of UMass Transit's incident tracking model, designed for use by the Valley Area Transit Company and Springfield Area Transit Company.

## Development

### Setup
1. `bundle`
2. `yarn`
3. Create your database.yml: `cp config/database.yml.example config/database.yml`
4. Create the databases: `rails db:create:all`
5. Setup database: `rails db:schema:load`
6. Create development data: `rails db:seed`
7. Create claims data: `mysql -u root --database=claims_development -e "SOURCE db/setup-claims.sql;"`

Alternatively you can import your data from Hatus:
```
rails users:import users.xml
rails reason_codes:import reason_codes.xml
```
Note that Hastus will import all supervisors as the same with no distinction between dispatchers and staff members.
To elevate the appropriate administrative staff, record their full names in a .txt file and run e.g.:
```
rails users:elevate_staff staff.txt
```

### Email

We develop using mailcatcher. They don't recommend listing it in the Gemfile, so install with `gem install mailcatcher`.
Then run `mailcatcher`, daemon by default, to catch mail and to `localhost:1080` to view the sent mail.

