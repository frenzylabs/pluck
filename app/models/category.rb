class Category < ApplicationRecord
  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id'

  has_many :category_things
  has_many :things, through: :category_things
end
