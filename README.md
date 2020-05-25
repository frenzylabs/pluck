# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

Requirements:

Need postgres and elasticsearch services running.  You can also use kubectl port-forward to connect to remote instances.



asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby 2.6.4

bundle config build.pg --with-pg-config=/usr/pgsql-9.1/bin/pg_config


