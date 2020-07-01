# syntax = docker/dockerfile:experimental
ARG TARGET_ENV=prod

FROM ruby:2.6.6-slim-stretch as main
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
    git

RUN curl -sL https://deb.nodesource.com/setup_10.x |  bash -
RUN apt-get update && apt-get install -y \
    nodejs \
    npm

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

FROM main as gems-dev

COPY Gemfile Gemfile.lock .
# COPY Gemfile.lock Gemfile.lock
# RUN bundle install --jobs 20 --retry 5 --without test 
RUN echo ""
RUN which bundle
RUN echo ${pwd}

RUN mount=type=cache,target=$RAILS_ROOT/vendor/bundle bundle install --jobs 20 --retry 5 --without test


FROM main as gems-prod

RUN echo "Hey"
COPY Gemfile Gemfile.lock ./
# COPY Gemfile.lock Gemfile.lock
# RUN bundle install --jobs 20 --retry 5 --without test 

RUN which bundle
RUN echo "$(pwd)"
RUN ls "$(pwd)"

RUN mount=type=cache,target=/var/www/pluck/vendor/bundle cd /var/www/pluck && bundle install --deployment --jobs 20 --retry 5 --without test development
# COPY ./vendor/bundle ./vendor/bundle
# RUN if [ "$RAILS_ENV" = "production" ] ; then echo "prod" && bundle install --deployment --jobs 20 --retry 5 --without test development; else bundle install --jobs 20 --retry 5 --without test ; fi
# # Adding project files

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

FROM gems-${TARGET_ENV} as asset-files

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


FROM asset-files as assets-dev

RUN mount=type=cache,target=$RAILS_ROOT/yarn_cache yarn install --check-files --update-checksums



FROM asset-files as assets-prod

RUN mount=type=cache,target=${RAILS_ROOT}/yarn_cache yarn install --check-files --production=true
RUN mount=type=cache,target=${RAILS_ROOT}/public SECRET_KEY_BASE=1 PRECOMPILE_ASSETS=true bundle exec rake assets:precompile

# FROM gems as asset

# # RUN export YARN_CACHE_DIR=$(yarn cache dir)
# # ENV YARN_CACHE_DIR `yarn cache dir`
# COPY package.json yarn.lock ./
# COPY yarn_cache yarn_cache
# # RUN mv -rf yarn_cache/* `yarn cache dir`

# # RUN echo $YARN_CACHE_DIR

# RUN yarn config set cache-folder $RAILS_ROOT/yarn_cache/v6

# RUN mount=type=cache,target=$RAILS_ROOT/yarn_cache/v6 yarn install --check-files --production=true

# # RUN if [ "$RAILS_ENV" = "production" ] ; then yarn install --check-files --production=true ; else echo "DEv" && yarn install --check-files --update-checksums ; fi

# COPY bin bin
# COPY Rakefile postcss.config.js babel.config.js ./
# COPY config/initializers/assets.rb config/initializers/
# COPY config/environments/production.rb  config/environments/
# COPY config/locales config/locales
# COPY config/application.rb \
#      config/application.yml \
#      config/boot.rb \
#      config/environment.rb \
#      config/webpacker.yml \
#      config/

# COPY config/webpack ./config/webpack

# COPY app/assets ${APP_DIR}/assets
# COPY app/javascript ${APP_DIR}/javascript
# COPY vendor/assets vendor/assets

# COPY public public

# RUN mount=type=cache,target=./public/assets,target=/public/packs SECRET_KEY_BASE=1 PRECOMPILE_ASSETS=true bundle exec rake assets:precompile

# RUN if [ "$RAILS_ENV" = "production" ] ; then SECRET_KEY_BASE=1 PRECOMPILE_ASSETS=true bundle exec rake assets:precompile; else echo "dev assets"; fi

FROM assets-${TARGET_ENV} as assets
RUN rm -rf tmp

FROM assets-dev as finaldev

COPY . .


FROM main as final

WORKDIR $RAILS_ROOT

RUN echo "Rails root = ${RAILS_ROOT}"

COPY ./ ./

RUN rm -rf vendor/assets app/assets node_modules yarn_cache;
# RUN if [ "$RAILS_ENV" = "production" ] ; then rm -rf vendor/assets app/assets node_modules yarn_cache; fi

COPY --from=assets /usr/local/bundle /usr/local/bundle
COPY --from=assets ${RAILS_ROOT}/vendor/bundle vendor/bundle
COPY --from=assets ${RAILS_ROOT}/public/assets public/assets
COPY --from=assets ${RAILS_ROOT}/public/packs public/packs

# COPY --from=localhost/assets:latest /usr/local/bundle /usr/local/bundle
# COPY --from=localhost/assets:latest ${RAILS_ROOT}/vendor/bundle vendor/bundle
# COPY --from=localhost/assets:latest ${RAILS_ROOT}/public/assets public/assets
# COPY --from=localhost/assets:latest ${RAILS_ROOT}/public/packs public/packs


EXPOSE 3001

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]


# Copy assets and cache from the latest build
# COPY --from=demoapp/app:latest-build /app/tmp/cache/assets /app/tmp/cache/assets
# COPY --from=demoapp/app:latest-build /app/public/assets /app/public/assets

# ARG SECRET_KEY_BASE
# # ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}

# # COPY config/environment.rb ./config/environment.rb
# COPY app/assets ${APP_DIR}/assets
# COPY app/javascript ${APP_DIR}/javascript
# # COPY vendor ${RAILS_ROOT}/vendor
# # COPY config/webpack config/webpacker.yml ${RAILS_ROOT}/config/

# # RUN mkdir -p ${RAILS_ROOT}/config/initializers
# # RUN mkdir ${RAILS_ROOT}/config/webpack
# # RUN mkdir ${RAILS_ROOT}/config/environments
# COPY bin ./bin
# # COPY config/webpack ./config/webpack
# # COPY config/webpacker.yml ./config/webpacker.yml
# # COPY config/initializers ./config/initializers
# # COPY config/environments ./config/environments
# # COPY config/application.rb ./config/application.rb
# # COPY config/application.yml ./config/application.yml
# # COPY config/boot.rb ./config/boot.rb

# COPY config ./config
# COPY Rakefile package.json postcss.config.js babel.config.js ./

# # ENV SECRET_KEY_BASE=${SECRET_KEY_BASE:-1}
# # ENV PRECOMPILE_ASSETS=true
# COPY public public

# RUN if [ "$RAILS_ENV" = "production" ] ; then SECRET_KEY_BASE=1 PRECOMPILE_ASSETS=true bundle exec rake assets:precompile; else echo "dev assets"; fi

# COPY . .

# # RUN yarn install --check-files --production=true
# RUN git config --global user.email web@layerkeep.com && git config --global user.name LayerKeep

# # RUN chmod +x "${APP_DIR}/services/scripts/scad.sh"


# # ENV PATH="${RAILS_ROOT}/bin:${PATH}"

# # VOLUME [ "${APP_DIR}", "${RAILS_ROOT}/config" ]

# # VOLUME [ "${RAILS_ROOT}/public"]


# EXPOSE 3001


# CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]




# # RUN PRECOMPILE_ASSETS=true RAILS_ENV=${RAILS_ENV} bundle exec rake assets:precompile

# # ENV PRECOMPILE_ASSETS=false
# # RUN yarn install --check-files --production=true


