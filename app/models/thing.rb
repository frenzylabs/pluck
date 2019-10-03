class Thing < ApplicationRecord
  include Searchable

  belongs_to :job, optional: true
  belongs_to :user

  has_many :tag_things
  has_many :tags, through: :tag_things

  has_many :category_things
  has_many :categories, through: :category_things

  has_many :thing_files

  # mapping do
  #   indexes :name
  # end

  def as_indexed_json(options={})
    self.as_json(
      include: { categories: { only: :name},
                 tags:    { methods: [:lname], only: [:lname, :thing_count] },
                 thing_files:   { only: [:name, :download_count] },
                 user: { only: [:name, :first_name, :last_name]}
               })
  end

  def self.indexme
    binding.pry
    self.__elasticsearch__.create_index! force: true
  end
end
