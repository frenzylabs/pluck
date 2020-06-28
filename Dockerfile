FROM ruby:2.6.6-slim-stretch as main

RUN apt-get update && apt install -y curl

RUN curl -sL https://deb.nodesource.com/setup_10.x |  bash -
# RUN apt-get update && apt-get install -y cmake npm
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    npm \
    libpq-dev \
    vim \
    libmagic-dev \
    pkg-config \
    git
RUN npm install yarn --global


# Set an environment variable where the Rails app is installed to inside of Docker image
ENV RAILS_ROOT ${RAILS_ROOT:-/var/www/pluck}
ENV APP_DIR=${RAILS_ROOT}/app

RUN mkdir -p $RAILS_ROOT 
RUN mkdir ${APP_DIR}
# Set working directory
WORKDIR $RAILS_ROOT

# Setting env up
ARG RAILS_ENV=${RAILS_ENV:-production}
ENV RAILS_ENV=$RAILS_ENV
ENV RACK_ENV=${RAILS_ENV}

RUN mkdir -p $RAILS_ROOT/vendor/bundle
# Adding gems
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
# RUN bundle install --jobs 20 --retry 5 --without test 

COPY ./vendor ./vendor
RUN if [ "$RAILS_ENV" = "production" ] ; then bundle install --deployment --jobs 20 --retry 5 --without test development; else bundle install --jobs 20 --retry 5 --without test ; fi
# Adding project files

COPY package.json yarn.lock ./
COPY node_module_cache ./node_modules

RUN if [ "$RAILS_ENV" = "production" ] ; then yarn install --check-files --production=true ; else echo "DEv" && yarn install --check-files --update-checksums ; fi

ARG SECRET_KEY_BASE
# ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}

# COPY config/environment.rb ./config/environment.rb
COPY app/assets ${APP_DIR}/assets
COPY app/javascript ${APP_DIR}/javascript
# COPY vendor ${RAILS_ROOT}/vendor
# COPY config/webpack config/webpacker.yml ${RAILS_ROOT}/config/

# RUN mkdir -p ${RAILS_ROOT}/config/initializers
# RUN mkdir ${RAILS_ROOT}/config/webpack
# RUN mkdir ${RAILS_ROOT}/config/environments
COPY bin ./bin
# COPY config/webpack ./config/webpack
# COPY config/webpacker.yml ./config/webpacker.yml
# COPY config/initializers ./config/initializers
# COPY config/environments ./config/environments
# COPY config/application.rb ./config/application.rb
# COPY config/application.yml ./config/application.yml
# COPY config/boot.rb ./config/boot.rb

COPY config ./config
COPY Rakefile package.json postcss.config.js babel.config.js ./

# ENV SECRET_KEY_BASE=${SECRET_KEY_BASE:-1}
# ENV PRECOMPILE_ASSETS=true
COPY public public

RUN if [ "$RAILS_ENV" = "production" ] ; then SECRET_KEY_BASE=1 PRECOMPILE_ASSETS=true bundle exec rake assets:precompile; else echo "dev assets"; fi

COPY . .

# RUN yarn install --check-files --production=true
RUN git config --global user.email web@layerkeep.com && git config --global user.name LayerKeep

# RUN chmod +x "${APP_DIR}/services/scripts/scad.sh"


# ENV PATH="${RAILS_ROOT}/bin:${PATH}"

# VOLUME [ "${APP_DIR}", "${RAILS_ROOT}/config" ]

# VOLUME [ "${RAILS_ROOT}/public"]


EXPOSE 3000


CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]




# RUN PRECOMPILE_ASSETS=true RAILS_ENV=${RAILS_ENV} bundle exec rake assets:precompile

# ENV PRECOMPILE_ASSETS=false
# RUN yarn install --check-files --production=true


