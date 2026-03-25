FROM ruby:3.2-slim

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential libsqlite3-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 4567

ENV PORT=4567
ENV RACK_ENV=development

CMD ["sh", "-c", "bundle exec ruby app.rb -o 0.0.0.0 -p ${PORT}"]
