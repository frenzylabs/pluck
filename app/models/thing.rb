class Thing < ApplicationRecord
  include Searchable
  index_name    "things3"

  belongs_to :job, optional: true
  belongs_to :user

  has_many :tag_things
  has_many :tags, through: :tag_things

  has_many :category_things
  has_many :categories, through: :category_things

  has_many :thing_files

  has_many :model_version_images


  def as_indexed_json(options={})
    self.as_json(
      include: { categories: { only: :name},
                 tags:    { methods: [:lname], only: [:lname, :thing_count] },
                 thing_files:   { only: [:name, :download_count] },
                 user: { only: [:name, :first_name, :last_name]}
               })
  end

  def self.indexme
    self.__elasticsearch__.create_index! force: true
  end
end
