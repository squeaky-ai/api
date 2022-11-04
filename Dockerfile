FROM arm64v8/ruby:3.1.2

WORKDIR /app

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install

COPY . /app

EXPOSE 4000

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "4000"]
