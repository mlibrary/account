FROM ruby:3.1
ARG UNAME=app
ARG UID=1000
ARG GID=1000

LABEL maintainer="mrio@umich.edu"

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  apt-transport-https

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  nodejs \
  vim-tiny

RUN gem install bundler:2.3

RUN curl -qL https://www.npmjs.com/install.sh | sh

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir -p /gems && chown ${UID}:${GID} /gems


USER $UNAME

ENV BUNDLE_PATH /gems

WORKDIR /app
