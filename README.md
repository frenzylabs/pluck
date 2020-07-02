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
1. Login to aws in order to decrypt the keys.
2. Set ENV: AWS_PROFILE=all


Need postgres and elasticsearch services running.  You can also use kubectl port-forward to connect to remote instances.
If you connect to staging you'll need to update values.local.yaml environment variables
1. PG_HOST = host.docker.internal
2. PG_PASSWORD     
    `echo $(sops -d --extract '["pluck"]["postgres"]["password"]' secrets/secrets.staging.yaml)`
3. Set ELASTICSEARCH_URL = "https://elastic:$(ELASTIC_PWD)@host.docker.internal:9200"
4. Set ELASTIC_PWD
    You need to get it from the correct cluster with the command:
    `echo $(kubectl get secret layerkeep-es-elastic-user -n elastic-system --template={{.data.elastic}} | base64 -d )`

5. Forward the ports.
    Inside ../layerkeep-infra run 2 terminals with the commands:
    `make staging run forward-pluck-db`
    `make staging run forward-pluck-es`

6. If you are inside vscode remote container then you'll need to forward the db and es pors.
   Hit `fn F1` and select forward a port:  9200 for es and 5432 for postgres.  

   If you have local instances running then you can forward different ports and map them to the correct ones.  You'll just need to update the values.local.yaml file with the correct ports.


7.  `skaffold dev --port-forward`



<!-- 
asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby 2.6.4

bundle config build.pg --with-pg-config=/usr/pgsql-9.1/bin/pg_config

 -->
