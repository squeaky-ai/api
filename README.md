# Squeaky Api!

![Build Status](https://codebuild.eu-west-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiSE10NDhJd3B6a0FVVEs4Y1E0VzQ1QkFWbEUwR2RkdHFXVmdBazNCYWhVTEdoM0wwM3FjSnRnNXlPZFJaK1U1NklUeUFNdGdCdlZBNjhZeFVMRlEvU05VPSIsIml2UGFyYW1ldGVyU3BlYyI6IlFJWWlQU3VSMzRsaWRVTzgiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=main)

### Requirements
- Ruby 3.0.0
- Postgres 12.x
- ElasticSearch 7.x

In order to send mail through the API, you will need AWS credentials located at ~/.aws, @lemonjs can create you some if you need them.

### Installation
```shell
$ git clone git@github.com:squeaky-ai/api.git
$ cd api

$ bundle install
$ rails server
```

### Create the database and run migrations
```shell
$ rails db:create
$ rails db:migrate
```

### Running the tests
```shell
$ rspec
```

### Importing recordings
Create a local recording and import it from Redis:
```shell
$ rails c
irb> RecordingSaveJob.perform_now({ site_id: '<site_uuid>', visitor_id: '<visitor_id>', session_id: '<session_id>' }.to_json)
```

### Usage
- [Playground](http://localhost:4000/api/playground/) (disabled in production)
- [GraphQL Endpoint](http://localhost:4000/api/graphql)
