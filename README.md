# README

## Setup

Install posgresql. Try [Postgres.app](https://postgresapp.com/) to make this easy on Mac.

Install posgres so the `pg` ruby gem can compile

    brew install postgresql

Install ruby (use the version in `.ruby-version` in the root of the application. Using chruby on mac:

    brew install chruby ruby-install
    ruby-install "$(cat .ruby-version)"
    chruby "$(cat .ruby-version)"

Bundle install

    gem install bundler
    bundle install

Install node.js and yarn, then install node packages.

    brew install node yarn
    yarn install

Create and seed the database

    bundle exec rake db:create db:schema:load db:seed db:test:prepare

If you encounter an error seeding, trying the following to reset:

    rails db:drop db:create db:schema:load db:seed

Run all the tests (you can checkout the rake tasks with rake -T to run a subset of tests)

    bundle exec rake spec:ci

## Development

Develop locally on feature branches. Merging to main triggers deploy to staging (and currently also production).

The app uses jsbundling-rails to separate webpack from sprockets.
Webpack compiles assets into the app/assets/builds/ directory, then sprockets picks them up as rails assets.
Learn more here: https://github.com/rails/jsbundling-rails/blob/main/docs/switch_from_webpacker.md

Webpack and rails server are started with Foreman using this helper:

    ./bin/dev

The application should now be available [on localhost](https://localhost:3000/)

To test a more production-like version of the app, build the base docker image:

    docker build -t benchmarks_builder -f config/docker/builder/Dockerfile .

Then you can use docker compose to run the app with a fresh database using a postgres alpine image.

    docker compose build
    docker compose up

Docker always runs in production mode because it's currently hardcoded in the Dockerfile.
The docker entrypoint runs a database setup and migration if the database is empty (similar to a fresh Azure deploy)

## Deployment

The application is deployed to the World Health Organization's Azure.

- [Production](https://who-ihrbenchmark.azurewebsites.net/)
- [Staging](https://who-ihrbenchmark-staging.azurewebsites.net/)

There is also a Preview slot used during the production deployment which is swapped with production every deploy.
[Preview](https://who-ihrbenchmark-preview.azurewebsites.net/) becomes production and production becomes preview during each production deploy.
This prevents downtime during the deploy that would otherwise happen during the 7-10 minutes the app would take to warm up after each deploy.
Swap slots waits for the warmup to finish before swapping.

We may want to do the same with staging to mirror production. The slots share the same resources so it would not increase costs, only complexity.

## CI/CD

Continuous builds and deployment are handled by [Azure DevOps](https://dev.azure.com/WHOHQ/IHRBENCHMARK).

The build is defined by the azure-pipelines.yml file with help from the variable set by terraform.
As of this writing, the test run rely on postgres14 alpine in order to support concurrent builds.
This is the same container you get when running `docker compose up`.

The main branch is automatically tested, docker image(s) built, deployed to Staging and deployed to Production.

## Alternative deployment

We've sometimes had long delays getting changes in WHO Azure.
To speed up the process we have the ability to deploy to a Cloud City owned Azure.

The corresponding urls are:

- [CCD Production](https://ccd-ihrbenchmark.azurewebsites.net/)
- [CCD Staging](https://ccd-ihrbenchmark-staging.azurewebsites.net/)
- [CCD Azure DevOps](https://dev.azure.com/cloudcitydev/IHRBENCHMARK/).

There is a separate terraform env at `config/terraform/env/cloudcity` for provisioning this account.

The primary reason for this lately is the Azure Active Directory Authentication, which can't be provisioned by WHO guest azure accounts.

## Database migrations during deploy

Database migrations are handled by the Docker entrypoint, a compromise that I arrived at after finding that Azure has no way to run one off commands within the context of an app's environment or container.
In practice, this works well, but migrations must be backwards compatible or it will cause downtime.

## Seed Data

See [how to update the assessments](#seed-data)

## Infrastructure

We manage whatever infrastructure we can with Terraform.
We are somewhat limited by World Health Organization permissions, which prevent our creation of certain pieces of the infrastructure.
These manually created pieces are mentioned in the terraform config where necessary.

See [config/terraform/README.md](config/terraform/README.md) for more details.

## Configuration Variables

Rails credentials are used to manage secrets.

The file `config/credentials.yml.enc` contains the production and staging configuration (it's all the same right now).
The file `config/master.key` that accompanies this encrypted file. You will need to get it from a previous developer or from the Cloud City Vital Strategies 1Password vault. Never commit it to the repository.

### Variables

These apply mostly to the heroku app.

- `WEBSITE_HOSTNAME`
- `PAPERTRAIL_API_TOKEN`
- `SENDGRID_API_KEY`
- `SENDGRID_PASSWORD`
- `SENDGRID_USERNAME`
- `SENTRY_DSN` (used for server-side ruby and browser-side javascript to report errors)
- `SKYLIGHT_AUTHENTICATION`
- `SECRET_KEY_BASE`

## A note on 3rd party libraries used

Tooltips: We are using bootstrap .tooltip() and not jQuery .tooltip(). It is used the same way `$('.selector').tooltip()`, and has different options.

## Fixtures

TODO: This needs updated, much of it no longer applies.

The application uses four data fixtures. Those fixtures are all considered part of the code, and updating the fixtures requires a new deployment of the application.

- app/fixtures/assessments.json -- this describes the structure of the assessments. It contains all of the technical areas and their associated indicators, and provides the sort order of the technical areas.

  A technical area ID takes the form <assessment*type>\_ta*<technical_area_id>.

  An indicator takes the form <assessment*type>\_ind*<technical_area_id> ("jee2_ind_p33", "spar_2018_ind_c62").

- app/fixtures/benchmarks.json -- this contains all of the capacities, benchmarks, actions, and action type codes. Most of the IDs are simple strings with no particular structure, though they do happen to be numbers at this time and are presented in numberically sorted order.

  benchmarks.json is no longer accessed directly, but is accessed now via the BenchmarksFixture class.

- app/fixtures/crosswalk.json -- this maps an assessment indicator ("jee2_ind_p33", "spar_2018_ind_c62") to a benchmark indicator ID ("14.3", "10.1"). In some cases, the indicator maps to two separate benchmarks, and so it will be used in setting the goal for two different benchmarks.

- app/fixtures/data_dictionary.json -- this is a simple dictionary that maps from various identifiers to corresponding strings. This fixture is slowly being phased out.

Fixtures are generated from spreadsheets in `/data/` with the command `rails gen_fixtures`. This command should bu run on a development machine and the resulting .json files should be commited to the repository.

## Seed Data

Assessments can be updated fairly frequently, so we decided to seed them into the database. We process spreadsheets released from the WHO to populate the database.

- `heroku run -a rtsl-benchmarks-staging.herokuapps.com rails db:seed`
- `heroku run -a rtsl-benchmarks-production.herokuapps.com rails db:seed`

These commands are safe to re-run. The command will generate a bunch of records that combine the assessment type and the country name. A new record that has an assessment type and country name combination will replace records with the same values in the database.

The spreadsheets are located in `/db/seed-data/`. Updated spreadsheets need to follow the same format.

For the JEE 1.0 and 2.0 scores, there must be:

- A spreadsheet named "Sheet4 (JEE 1.0 Indicators)"
- A spreadsheet named "Sheet5 (JEE 2.0 Indicators)"

Each sheet must follow this form:

- Column A: "country"
- Column B: ignored
- Column C: "status"
- Column D - Column AY: technical area identifiers

If Column C has any value other than "Completed", the entire line will be ignored.

for the SPAR scores, there must a single spreadsheet with these columns:

- Column B: "country"
- Columns C - Z: technical area identifiers

## TODOs

- update docs/object_diagram.png with the current object relationships
- update this README with the latest, and remove cruft

## A note on javascript and stylesheets

Note: Some of this may be different now that we're using jsbundling-rails.
In particular, I think the application.css stylesheet is now handled exclusively by webpack so it combines all of the css from all included modules.
Someone with more javascript experience might be able to fix this issue now that webpack is being used directly.
I wonder if the problem actually still exists.

I leave the original comments below in case they help someone clean it up:

You may notice a couple things that seem wasteful across the following files which reference this note:

- `javascript/base.js`
- `javascript/application.js`
- `layouts/application.html.erb`
- `helpers/application_helper.rb`

First, there is both an `import "stylesheets/application.scss"` in `base.js`
and a `<%= stylesheet_pack_tag 'application', media: 'all' %>` in `layouts/application.html.erb`.

If you remove `<%= stylesheet_pack_tag 'application', media: 'all' %>` you will get no styling.

If you remove `import "stylesheets/application.scss"` you will get no tootips due to a JS error `tooltip is not a function`.

Second, you might think you could load `base.js` on every page and remove the `import "./base"` at
the top of `application.js`, so that you are not effectively loading `base.js` twice.

If you remove this import you will again get the JS error `tooltip is not a function`.

This is as optimized as we have been able to get the packs download sizes at this time and still maintain functionality on all pages.
