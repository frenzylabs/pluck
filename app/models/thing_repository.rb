class ThingRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  mappings do
    # indexes :title, analyzer: 'snowball' 
    indexes :name, type: 'text', analyzer: 'snowball_analyzer'
  end
  settings do
    {
      index: {
        analysis: {
          filter: {
            autocomplete_filter: {
              type: "edge_ngram",
              min_gram: 1,
              max_gram: 20
            },
            my_snow: {
              type: "snowball",
              language: "English"
            }
          },
          analyzer:{
            snowball_analyzer: {
              type: "custom",
              tokenizer: "standard",
              filter: ["lowercase", "my_snow"]
            },
            autocomplete: {
              type: "custom",
              tokenizer: "standard",
              filter: ["lowercase", "autocomplete_filter"]
            }
          }
        }
      }
    }
  end
  # settings number_of_shards: 1
end