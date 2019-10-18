# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.

Elasticsearch::Model.client = Elasticsearch::Client.new url: ENV.fetch("ELASTICSEARCH_URL", "localhost:9200"), transport_options: {
  request: { open_timeout: 1 },
  ssl:     { verify: false } 
}