module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    thing_es_settings = {
      index: {
        analysis: {
          normalizer: {
            custom_normalizer: {
              type: "custom",
              char_filter: ["stopword_char_filter", "trim_char_filter"],
              filter: ["lowercase"]
            }
          },
          char_filter: {
            stopword_char_filter: {
              type: "pattern_replace",
              pattern: "( ?a ?| ?and ?| ?the ?)",
              replacement: " "
            },
            trim_char_filter: {
              type: "pattern_replace",
              pattern: "(\\s+)$",
              replacement: ""
            }
          },
          filter: {
            autocomplete_filter: {
              type: "edge_ngram",
              min_gram: 1,
              max_gram: 20
            },
            my_snow: {
              type: "snowball",
              language: "English"
            },
            my_stop: {
              type:       "stop",
              stopwords: "_english_"
            }
          },
          analyzer:{
            my_english_analyzer: {
              type: "standard",
              stopwords: "_english_"
            },
            snowball_analyzer: {
              type: "custom",
              tokenizer: "standard",
              filter: ["lowercase", "my_stop", "my_snow"]
            },
            lower_keyword_analyzer: {
              tokenizer: "keyword",
              filter: ["lowercase"]
            },
            lowercase_analyzer: {
              type: "custom",
              tokenizer: "keyword",
              filter: ["lowercase", "my_stop"]
            },
            camel_analyzer: {
              type: "pattern",
              pattern: "([^\\p{L}\\d]+)|(?<=\\D)(?=\\d)|(?<=\\d)(?=\\D)|(?<=[\\p{L}&&[^\\p{Lu}]])(?=\\p{Lu})|(?<=\\p{Lu})(?=\\p{Lu}[\\p{L}&&[^\\p{Lu}]])"              
            },
            file_analyzer: {
              type: "custom",
              tokenizer: "char_group",
              filter: ["lowercase"]
            },
          },
          tokenizer: {
            char_group: {
              type: 'char_group',
              tokenize_on_chars: [
                "whitespace",
                "digit",
                "punctuation",
                "symbol",
                "-",
                "_"
              ]
            }
          }
        }
      }
    }

    # settings index: {
    #   number_of_shards: 1,
    #   number_of_replicas: 0,
    #   analysis: {
    #     analyzer: {
    #       snowball_analyzer: {
    #         type: "snowball",
    #         language: 'English'
    #       },
    #       lowercase_analyzer: {
    #         type: "standard",
    #         tokenizer: "lowercase"
    #         # filter: [ "replace-whitespaces", "truncate_underscore" ]
    #       }
          
    #       # pattern: {
    #       #   type: 'pattern',
    #       #   pattern: "\\s|_|-|\\.",
    #       #   lowercase: true
    #       # },
    #       # trigram: {
    #       #   tokenizer: 'trigram'
    #       # }
    #     }
    #     # tokenizer: {
    #     #   trigram: {
    #     #     type: 'ngram',
    #     #     min_gram: 3,
    #     #     max_gram: 3,
    #     #     token_chars: ['letter', 'digit']
    #     #   }
    #     # }
    #   } } do
    settings thing_es_settings do
      mapping do
        indexes :name, type: :text, analyzer: :snowball_analyzer do
          # indexes :lower, analyzer: :snowball_analyzer
          indexes :exact, analyzer: :lower_keyword_analyzer
        end
        indexes :description, type: :text, analyzer: :my_english_analyzer
        indexes :download_count, type: :integer
        indexes :like_count, type: :integer
        indexes :added_on, type: :date
        indexes :updated_on, type: :date
        indexes :tags, type: :object do
          indexes :lname, type: :text, analyzer: :standard do
            indexes :exact, type: :text, analyzer: :lower_keyword_analyzer
          end
          indexes :thing_count, type: :integer
        end
        indexes :categories, type: :object do
          indexes :name, type: :text, analyzer: :snowball_analyzer
        end
        indexes :thing_files, type: :object do
          indexes :name, type: :text, analyzer: :camel_analyzer do
            indexes :exact, type: :text, analyzer: :file_analyzer
          end
          indexes :download_count, type: :integer
        end
        indexes :user, type: :object do
          indexes :name, type: :text, analyzer: :lower_keyword_analyzer
        end
      end
    end

    def self.search(query)
      dt = DateTime.now.utc.iso8601
      __elasticsearch__.search(
      {
        query: {
          function_score: {
              score_mode: "avg",
              # boost_mode: "multiply",
              # max_boost: 30,
              query: {
                bool: {
                  must: [
                  {
                    bool: {
                      should: [
                        {
                          multi_match: {
                            query: query,
                            fields: ["name.exact", "user.name"],
                            boost: 10
                          }
                        },
                        {
                          multi_match: {
                            query: query,
                            fields: ["name", "thing_files.name", "thing_files.name.exact"],
                            boost: 5
                          }
                        },
                        {
                          multi_match: {
                            query: query, 
                            fields: ["description", "tags.lname", "categories.name"]
                          }
                        }
                      ]
                    }
                  }
                  ]
                }
              },              
              functions: [
              #   script_score: {
              #     script: {
              #       source: "Math.log(2 + doc['download_count'].value)"
              #     }
              # }
                {
                  gauss: {
                      updated_on: {
                          "origin": "#{dt}",
                          "scale": "84d",
                          "offset": "7d",
                          "decay": 0.1
                      }
                  }
                },
                {
                  filter: {
                    range: {
                      download_count: {
                        from: 1
                      }
                    }
                  }, 
                  field_value_factor: {
                    field: "like_count",
                    # factor: 1.1,
                    modifier: "log1p",
                    missing: 1
                  }
                },
                {
                  filter: {
                    range: {
                      download_count: {
                        from: 1
                      }
                    }
                  }, 
                  field_value_factor: {
                    field: "download_count",
                    # factor: 1.1,
                    modifier: "log1p",
                    missing: 1
                  }
                }                
              ]
          }
        }
      })
      
      # __elasticsearch__.search({
      #   query: {
      #     function_score: {
      #       query: {
      #         bool: {
      #           must: [
      #           {
      #             multi_match: {
      #               query: query,
      #               fields: ["name", "name.lower"]
      #               # fields: ["thing_files.name", "thing_files.name.exact"]
      #             }
      #           }
      #           ]
      #         }
      #       },
      #       script_score: {
      #         script: "_score * Math.log(doc['like_count'].value + doc['download_count'].value + 1)"
      #       }
      #     }
      #   }
      # })

      # __elasticsearch__.search({
      #   query: {
      #     bool: {
      #       must: [
      #       {
      #         multi_match: {
      #           query: query,
      #           fields: ["thing_files.name", "thing_files.name.exact"]
      #           # fields: ["tags.lname"]
      #           # fields: ["categories.name"]
      #           # fields: ["name", "name.lower", "categories.name"]
      #         }
      #       }
      #       ]
      #     }
      #   }
      # })
    end
  end
end

# __elasticsearch__.search({
# query: {
#   function_score: {
#     query: {
#       bool: {
#         must: [
#         {
#           multi_match: {
#             query: query,
#             fields: ["thing_files.name", "thing_files.name.exact"]
#           }
#         }
#         ]
#       }
#     },
#     script_score: {
#       script: "_score * log(doc['like_count'].value + doc['download_count'].value + 1)"
#     }
#   }
# }
# })

# dt = DateTime.now.utc
# __elasticsearch__.search(
# {
#   query: {
#     function_score: {
#         functions: [
#           {
#             gauss: {
#                 updated_on: {
#                     "origin": "#{dt}",
#                     "scale": "12w",
#                     "offset": "1w",
#                     "decay": 0.3
#                 }
#             }
#           },
#           {
#             gauss: {
#               like_count: {
#                   origin: 20000,
#                   scale: 20000
#               }
#             }
#           },
#           {
#             gauss: {
#               download_count: {
#                   origin: 20000,
#                   scale: 20000
#               }
#             }
#           }
#         ]
#     }
#   }
# })

# "query": {
#   "function_score": {
#     "query": {"match": {"_all": "severed"}},
#     "script_score": {
#       "script": "_score * log(doc['likes'].value + doc['views'].value + 1)"
#     }
#   }
# }

# bool: {
#   must: [
#     {
#       multi_match: {
#         query: query,
#         fields: ["thing_files.name", "thing_files.name.exact"]
#               # fields: ["tags.lname"]
#               # fields: ["categories.name"]
#               # fields: ["name", "name.lower", "categories.name"]
#        }
#     },
#     {
#       bool: {

#       }
#     }
#   ]
# }
  

# query: {
#   bool: {
#     must: [
#     {
#       multi_match: {
#         query: query,
#         fields: [:name, :description, :body, :tags]
#       }
#     },
#     {
#       match: {
#         published: true
#       }
#     }
#     ]
#   }
# }

# Thing.__elasticsearch__.delete_index!
# Thing.__elasticsearch__.create_index! force: true
#res = Thing.__elasticsearch__.client.create({index: Thing.index_name, body: { settings: Thing.settings.to_hash, mappings: Thing.mappings.to_hash } })
# t = Thing.find(1)
# t.__elasticsearch__.index_document
# Thing.includes(:categories, :tags, :user, :thing_files).where("id < 100").each {|t| t.__elasticsearch__.index_document }
# User.first.things.includes(:categories, :tags, :user, :thing_files).each {|t| t.__elasticsearch__.index_document }

# Thing.includes(:categories, :tags, :user, :thing_files).where("id < 100").map {|t| t.tags.map(&:lname) }
# Thing.includes(:categories, :tags, :user, :thing_files).where("id < 100").map {|t| t.thing_files.map(&:name) }


# Thing.includes(:categories, :tags, :user, :thing_files).where("id >= 100 and id < 10000").each {|t| t.__elasticsearch__.index_document }
