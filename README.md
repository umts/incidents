# incidents

[![Build Status](https://travis-ci.org/umts/incidents.svg?branch=master)](https://travis-ci.org/umts/incidents)
[![Code Climate](https://codeclimate.com/github/umts/incidents/badges/gpa.svg)](https://codeclimate.com/github/umts/incidents)
[![Test Coverage](https://codeclimate.com/github/umts/incidents/badges/coverage.svg)](https://codeclimate.com/github/umts/incidents/coverage)

This is a prototype of UMass Transit's incident tracking model, designed for use by the Valley Area Transit Company and Springfield Area Transit Company.

## Development

### Setup
1. `bundle`
2. Create the databases: `rails db:create:all`
3. Run migrations: `rails db:migrate`
4. Create development data: `rails db:seed`

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

### Logging into the Rails server
When you connect to the Rails server you will be prompted to log in.
If you seeded your data you will be able to log in using these credentials:

**Badge number:** 5000  
**Password:** password

### Email

We develop using mailcatcher. They don't recommend listing it in the Gemfile, so install with `gem install mailcatcher`.
Then run `mailcatcher`, daemon by default, to catch mail and to `localhost:1080` to view the sent mail.

### Claims integration

To set up claims integration in your development environment, configure the appropriate database in database.yml under the name `claims_development`.

Then as a mysql user with access to that database, type:

```sql
> USE your_database_name_here;
> source setup-claims.sql;
```
