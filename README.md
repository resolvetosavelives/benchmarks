# README

## Branching and deployment

Branches:

* master -- always deployment to the staging server
* feature branches -- Sid and I will create branches for developing and testing new features. These branches get merged into master with a pull request and code review.

Servers:

* staging -- will be showing the latest code on the master branch (unless some need to feature freeze arises)
* production -- ???

## Local development

We run the application in a docker container that will be pre-populated with a known version of Ruby and with the dependencies from `Gemfile`. To start development, install docker and then in the project root, run these commands:

```
docker-compose run dev
rake db:create
rake db:migrate
exit
docker-compose up web
```

The first time you run this command, it will take quite a long time to start. Once started, though, the application will be available on `localhost:3000`. Your project directory is mirrored in the container, so changes should be quickly reflected in the webapp.

If at any point you need to change the Gemfile, changes will be quickly reflected in the containers. But it will still be best to rebuild the images:

```
docker-compose build web dev
docker-compose up web
```

The dev image is for getting a command line with the same environment as the web app for running commands like `rake db:create` or `rake db:migrate`.
