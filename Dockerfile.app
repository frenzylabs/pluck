# syntax = docker/dockerfile:experimental
ARG TARGET_ENV=prod

FROM ruby:2.6.6-slim-stretch as base
# FROM ruby:2.6.6-alpine as main

# RUN apk update && \
#   apk add --update --no-cache \
#     build-base \
#     bash \
#     curl \
#     git \
#     less \
#     tzdata \
#     cmake \
#     postgresql-dev \
#     nodejs \
#     npm \
#     vim \
#   && rm -rf /var/cache/apk/*

# RUN apt-get update && apt install -y curl

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    libpq-dev \
    vim \
    libmagic-dev \
    pkg-config \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_10.x |  bash -
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# RUN apt-get update && apt-get install -y cmake npm
# RUN apt-get update && apt-get install -y \
#     build-essential \
#     cmake \
#     curl \
#     nodejs \
#     npm \
#     libpq-dev \
#     vim \
#     libmagic-dev \
#     pkg-config \
#     git
RUN npm install yarn --global


# Set an environment variable where the Rails app is installed to inside of Docker image
ENV RAILS_ROOT ${RAILS_ROOT:-/var/www/pluck}
ENV APP_DIR=${RAILS_ROOT}/app

# RUN mkdir -p $RAILS_ROOT 
RUN mkdir -p ${APP_DIR}
# Set working directory
WORKDIR $RAILS_ROOT

# Setting env up
ARG RAILS_ENV=${RAILS_ENV:-production}
ENV RAILS_ENV=$RAILS_ENV
ENV RACK_ENV=${RAILS_ENV}

RUN mkdir -p $RAILS_ROOT/vendor/bundle
# Adding gems

## DEV BUNDLER
FROM base as gems-dev

COPY Gemfile Gemfile.lock ./
RUN mount=type=cache,target=$RAILS_ROOT/vendor/bundle bundle install --jobs 20 --retry 5 --without test

COPY package.json yarn.lock ./
RUN mount=type=cache,target=${RAILS_ROOT}/yarn_cache yarn install --check-files --update-checksums

## PROD BUNDLER
FROM base as gems-prod

COPY Gemfile Gemfile.lock ./

RUN mount=type=cache,target=${RAILS_ROOT}/vendor/bundle bundle install --deployment --jobs 20 --retry 5 --without test development

RUN find vendor/bundle/ruby/*/extensions \
        -type f -name "mkmf.log" -o -name "gem_make.out" | xargs rm -f \
    && find vendor/bundle/ruby/*/gems -maxdepth 2 \
        \( -type d -name "spec" -o -name "test" -o -name "docs" \) -o \
        \( -name "*LICENSE*" -o -name "README*" -o -name "CHANGELOG*" \
            -o -name "*.md" -o -name "*.txt" -o -name ".gitignore" -o -name ".travis.yml" \
            -o -name ".rubocop.yml" -o -name ".yardopts" -o -name ".rspec" \
            -o -name "appveyor.yml" -o -name "COPYING" -o -name "SECURITY" \
            -o -name "HISTORY" -o -name "CODE_OF_CONDUCT" -o -name "CONTRIBUTING" \
        \) | xargs rm -rf


COPY package.json yarn.lock ./
RUN mount=type=cache,target=${RAILS_ROOT}/yarn_cache yarn install --check-files --production=true



FROM gems-${TARGET_ENV} as assets

COPY package.json yarn.lock ./
COPY bin bin
COPY Rakefile postcss.config.js babel.config.js ./
COPY config/initializers/assets.rb config/initializers/
COPY config/environments/production.rb  config/environments/
COPY config/locales config/locales
COPY config/application.rb \
     config/application.yml \
     config/boot.rb \
     config/environment.rb \
     config/webpacker.yml \
     config/

COPY config/webpack ./config/webpack

COPY app/assets ${APP_DIR}/assets
COPY app/javascript ${APP_DIR}/javascript
COPY vendor/assets vendor/assets


RUN yarn config set cache-folder ${RAILS_ROOT}/yarn_cache

RUN mount=type=cache,target=${RAILS_ROOT}/public SECRET_KEY_BASE=1 PRECOMPILE_ASSETS=true bundle exec rake assets:precompile

RUN rm -rf tmp node_modules yarn_cache


### Dev Final Image
FROM gems-dev as finaldev

COPY . .


## PROD BUILD
FROM base as final

COPY ./ ./

RUN rm -rf vendor/assets app/assets;

# COPY --from=assets /usr/local/bundle /usr/local/bundle
# COPY --from=assets ${RAILS_ROOT}/vendor/bundle vendor/bundle
# COPY --from=assets ${RAILS_ROOT}/public/assets public/assets
# COPY --from=assets ${RAILS_ROOT}/public/packs public/packs

COPY --from=localhost/assets:latest /usr/local/bundle /usr/local/bundle
COPY --from=localhost/assets:latest ${RAILS_ROOT}/vendor/bundle vendor/bundle
COPY --from=localhost/assets:latest ${RAILS_ROOT}/public/assets public/assets
COPY --from=localhost/assets:latest ${RAILS_ROOT}/public/packs public/packs


EXPOSE 3001

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

