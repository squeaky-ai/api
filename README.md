# Squeaky Api!

![Build Status](https://codebuild.eu-west-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiUXA2em9YQlV6TTZhWGdsb0lOTDVCQ2poNVpPUVV5dUg1cFFrYS9OaEw5MGZhL29IYmF4SkVodElmUEsvdjJ5bUFiYXNneXRYUjhFRld4dE1oQlRTckhzPSIsIml2UGFyYW1ldGVyU3BlYyI6IjNNUGIrclZRWThrYUhaKzgiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=main)

### Requirements
- Ruby 3.0.0
- Redis 5.x
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
