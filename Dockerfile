FROM ruby:2.7.2

LABEL maintainer="mrio@umich.edu"

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  apt-transport-https

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  nodejs

COPY Gemfile* /usr/src/app/
WORKDIR /usr/src/app

RUN gem install bundler:2.1.4
ENV BUNDLE_PATH /gems

RUN bundle install

COPY . /usr/src/app/

RUN npm install
RUN npm run compile

CMD ["bundle", "exec", "ruby", "my_account.rb", "-o", "0.0.0.0"]
