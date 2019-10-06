FROM ruby:2.6.1

RUN curl -sL https://deb.nodesource.com/setup_10.x |  bash -
# RUN apt-get update && apt-get install -y cmake npm
RUN apt-get update && apt-get install -y build-essential cmake npm libpq-dev nodejs vim libmagic-dev
RUN npm install yarn --global


# Set an environment variable where the Rails app is installed to inside of Docker image
ENV RAILS_ROOT ${RAILS_ROOT:-/var/www/thingsearch}
ENV APP_DIR=${RAILS_ROOT}/app

RUN mkdir -p $RAILS_ROOT 
RUN mkdir ${APP_DIR}

RUN mkdir ${RAILS_ROOT}/config
# Set working directory
WORKDIR $RAILS_ROOT

# Setting env up
ARG RAILS_ENV=${RAILS_ENV:-production}
ENV RAILS_ENV=$RAILS_ENV
ENV RACK_ENV=${RAILS_ENV}

# Adding gems
RUN gem install bundler:2.0.1

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install --jobs 20 --retry 5 --without test 
# # Adding project files
COPY bin ./bin

COPY app/assets ${APP_DIR}/assets
COPY app/javascript ${APP_DIR}/javascript
COPY vendor ${RAILS_ROOT}/vendor
# COPY config/webpack config/webpacker.yml ${RAILS_ROOT}/config/
COPY config ./config
COPY Rakefile package.json postcss.config.js babel.config.js ./



ENV SECRET_KEY_BASE=${SECRET_KEY_BASE:-c959724279db5ca746e7a88}

RUN yarn install --check-files --production=true
RUN bundle exec rake assets:precompile

COPY . .

# RUN yarn install --check-files --production=true


# VOLUME [ "${APP_DIR}", "${RAILS_ROOT}/config" ]

# VOLUME [ "${RAILS_ROOT}/public", "/var/www/repos" ]

# ENV SECRET_KEY_BASE=${SECRET_KEY_BASE:-c959724279db5ca746e7a88}

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

# bundle exec puma -C config/puma.rb