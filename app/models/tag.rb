class Tag < ApplicationRecord
  has_many :tag_things
  has_many :things, through: :tag_things

  def lname
    name.downcase
  end
end
