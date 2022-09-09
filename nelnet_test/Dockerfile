FROM ruby:3.1
ARG UNAME=app
ARG UID=1000
ARG GID=1000

LABEL maintainer="mrio@umich.edu"

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  apt-transport-https \
  vim-tiny

RUN gem install bundler:2.3.22

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir -p /gems && chown ${UID}:${GID} /gems

COPY --chown=${UID}:${GID} Gemfile* /app/
USER $UNAME

ENV BUNDLE_PATH /gems

WORKDIR /app
RUN bundle install

COPY --chown=${UID}:${GID} . /app

CMD ["bundle", "exec", "ruby", "nelnet_test.rb", "-o", "0.0.0.0"]
