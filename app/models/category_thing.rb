class CategoryThing < ApplicationRecord
  belongs_to :category
  belongs_to :thing

  validates_uniqueness_of :thing, :scope => [:category_id, :thing_id]
end
