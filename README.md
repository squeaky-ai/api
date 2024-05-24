# Squeaky API!

**NOTE**: Squeaky was sunsetted at the end of May 2024.

### Requirements
- Ruby 3.1.2
- Postgres 12.x
- ClickHouse

In order to send mail through the API, you will need AWS credentials located at ~/.aws, @lemonjs can create you some if you need them.

### Installation
```shell
$ git clone git@github.com:squeaky-ai/api.git
$ cd api

$ bundle install
$ bundle exec rails server
```

### Create the ClickHouse database
```shell
$ bundle exec rake click_house:create
```

### Create the Postgres database and run migrations
```shell
$ bundle exec rails db:create
$ bundle exec rails db:migrate
```

### Running the tests
```shell
$ bundle exec rspec
```

### Run the typechecker
```shell
$ bundle exec srb tc
```

### Importing recordings
Create a local recording and import it from Redis:
```shell
$ rails c
irb> RecordingSaveJob.perform_now('site_id' => '<site_uuid>', 'visitor_id' => '<visitor_id>', 'session_id' => '<session_id>')
```

### Running the stripe webhook locally
```shell
$ stripe listen --forward-to localhost:4000/webhooks/stripe
```

### Usage
- [Playground](http://api.squeaky.test/playground/) (disabled in production unless you're a superuser)
- [GraphQL Endpoint](http://api.squeaky.test/graphql)
- [Sidekiq](http://api.squeaky.test/sidekiq)

### Accessing the Rails console in production
You'll need jq installed (`brew install jq`), then run the following:
```shell
aws ecs execute-command \
  --cluster squeaky \
  --task $(aws ecs list-tasks --cluster squeaky --service-name api --region eu-west-1 | jq '.taskArns[0]' --raw-output) \
  --container api \
  --interactive \
  --command '/bin/sh' \
  --region eu-west-1
```
