FROM ruby:2.7.2
ARG UNAME=app
ARG UID=1000
ARG GID=1000

LABEL maintainer="mrio@umich.edu"

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  apt-transport-https

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  nodejs \
  vim

RUN gem install bundler:2.1.4


RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir -p /gems && chown ${UID}:${GID} /gems


COPY --chown=${UID}:${GID} Gemfile* /app/
USER $UNAME

ENV BUNDLE_PATH /gems

#Actually a secret
ENV NELNET_SECRET_KEY 'YOUR_NELNET_SECRET_KEY'

#Not that much of a secret

WORKDIR /app
RUN bundle install

COPY --chown=${UID}:${GID} . /app


CMD ["bundle", "exec", "ruby", "nelnet_test.rb", "-o", "0.0.0.0"]
