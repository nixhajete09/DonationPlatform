FROM ruby:3.2-slim

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock* ./
RUN bundle install

COPY . .
RUN mkdir -p db

EXPOSE 4567

CMD ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0", "-p", "4567"]
