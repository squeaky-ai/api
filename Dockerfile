FROM arm64v8/ruby:3.2.0-alpine

WORKDIR /app

ENV RUBY_YJIT_ENABLE=1

RUN apk --update add build-base ruby-dev postgresql-dev tzdata gcompat

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install

COPY . /app

EXPOSE 4000

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "4000"]
