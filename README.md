# Squeaky Api!

![Build Status](https://codebuild.eu-west-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiSE10NDhJd3B6a0FVVEs4Y1E0VzQ1QkFWbEUwR2RkdHFXVmdBazNCYWhVTEdoM0wwM3FjSnRnNXlPZFJaK1U1NklUeUFNdGdCdlZBNjhZeFVMRlEvU05VPSIsIml2UGFyYW1ldGVyU3BlYyI6IlFJWWlQU3VSMzRsaWRVTzgiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=main)

### Requirements
- Ruby 3.0.0
- Postgres 12.x
- Or, Docker and docker-compose

In order to send mail through the API, you will need AWS credentials located at ~/.aws, @lemonjs can create you some if you need them.

### Installation
```shell
$ git clone git@github.com:squeaky-ai/api.git
$ cd api

# Start bare metal
$ bundle install
$ rails server

# Or, start with docker
$ docker-compose build
$ docker-compose up
```

### Create the database and run migrations
```shell
# If using docker, first run:
# $ docker-compose exec server sh

$ rails db:create
$ rails db:migrate
```

### Usage
- [Playground](http://localhost:4000/) (disabled in production)
- [GraphQL endpoint](http://localhost:4000/api/graphql)