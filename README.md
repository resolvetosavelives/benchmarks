# README

## Deployment

The application is currently developed to heroku in both staging and master releases:

*   [Staging](https://rtsl-benchmarks-staging.herokuapps.com/)
*   [Production](https://rtsl-benchmarks-production.herokuapps.com/)

Continuous builds and deployment to staging are handled in [SemaphoreCI](https://semaphoreci.com/resolvetosavelives/benchmarks). The master branch is automaticallly pushed to Staging on a successful deployment. Promote to Production by clicking on the "Promote to Production" button on [the app dashboard](https://dashboard.heroku.com/pipelines/a8edf761-58ea-4ff2-96fc-f2abc8c08097).

Any deployment or promotion to production may require a database migration:

*   `heroku run -a rtsl-benchmarks-staging.herokuapps.com rails db:migrate`
*   `heroku run -a rtsl-benchmarks-production.herokuapps.com rails db:migrate`

See also [how to update the assessments](#seed-data)

### A Note on Configuration Variables

There are basically two ways that Rails apps' configuration can be managed:
* [12 Factor](12factor.net) -- initially developed by and for Heroku, its widely accepted as a best practice: put your config variables as environment variables
* Rails own take on configuration variables: put them in a YML file, encrypt the file, commit to source, deploy along with code, decrypt at runtime to access the variables (https://guides.rubyonrails.org/v5.2/security.html#custom-credentials)
  * Basically the opposite of 12 Factor, DHH apparently prefers this.

This app uses the 12-Factor approach which works great considering that we currently run on Heroku.

At the time of this writing, this repo does contain a file `config/credentials.yml.enc` which contains the default contents generated by Rails. We could probably remove it and it would have no effect. There is a `master.key` that accompanies this encrypted file, which the previous developers can provide, since it should NOT be committed to the repo.

### Configuration Variables

The configuration variables this app depends on, NOT inclusive of RAILS_ENV/RACK_ENV and other configuration variables that Heroku adds:
* `BENCHMARKS_HOST`
* `PAPERTRAIL_API_TOKEN`
* `SENDGRID_API_KEY`
* `SENDGRID_PASSWORD`
* `SENDGRID_USERNAME`
* `SENTRY_DSN`
* `SKYLIGHT_AUTHENTICATION`
* `SECRET_KEY_BASE`


## Development

For development, we only used the master branch and feature branches.

The master branch is constantly deployed to staging. All work done on a feature branch is merged directly into the master branch after a pull request and code review.

Locally, development requires only a working Postgres database and Ruby 2.6.3. We provide a docker-compose file that will launch the database in a docker container. Set up to develop with the following commands:

```
docker-compose up -d db
bundle install
rails db:create
rails db:migrate
rails db:seed
rails server -b 0.0.0.0
```

The application should now be available [on localhost](https://localhost:3000/)

## Fixtures

TODO: This needs updated, much of it no longer applies.

The application uses four data fixtures. Those fixtures are all considered part of the code, and updating the fixtures requires a new deployment of the application.

*   app/fixtures/assessments.json -- this describes the structure of the assessments. It contains all of the technical areas and their associated indicators, and provides the sort order of the technical areas.

    A technical area ID takes the form <assessment_type>_ta_<technical_area_id>.

    An indicator takes the form <assessment_type>_ind_<technical_area_id> ("jee2_ind_p33", "spar_2018_ind_c62").

*   app/fixtures/benchmarks.json -- this contains all of the capacities, benchmarks, activities, and activity type codes. Most of the IDs are simple strings with no particular structure, though they do happen to be numbers at this time and are presented in numberically sorted order.

    benchmarks.json is no longer accessed directly, but is accessed now via the BenchmarksFixture class.

*   app/fixtures/crosswalk.json -- this maps an assessment indicator ("jee2_ind_p33", "spar_2018_ind_c62") to a benchmark indicator ID ("14.3", "10.1"). In some cases, the indicator maps to two separate benchmarks, and so it will be used in setting the goal for two different benchmarks.

*   app/fixtures/data_dictionary.json -- this is a simple dictionary that maps from various identifiers to corresponding strings. This fixture is slowly being phased out.

Fixtures are generated from spreadsheets in `/data/` with the command `rails gen_fixtures`. This command should bu run on a development machine and the resulting .json files should be commited to the repository.

## Seed Data

Assessments can be updated fairly frequently, so we decided to seed them into the database. We process spreadsheets released from the WHO to populate the database.

*   `heroku run -a rtsl-benchmarks-staging.herokuapps.com rails db:seed`
*   `heroku run -a rtsl-benchmarks-production.herokuapps.com rails db:seed`

These commands are safe to re-run. The command will generate a bunch of records that combine the assessment type and the country name. A new record that has an assessment type and country name combination will replace records with the same values in the database.

The spreadsheets are located in `/db/seed-data/`. Updated spreadsheets need to follow the same format.

For the JEE 1.0 and 2.0 scores, there must be:

*   A spreadsheet named "Sheet4 (JEE 1.0 Indicators)"
*   A spreadsheet named "Sheet5 (JEE 2.0 Indicators)"

Each sheet must follow this form:

*   Column A: "country"
*   Column B: ignored
*   Column C: "status"
*   Column D - Column AY: technical area identifiers

If Column C has any value other than "Completed", the entire line will be ignored.

for the SPAR scores, there must a single spreadsheet with these columns:

*   Column B: "country"
*   Columns C - Z: technical area identifiers
