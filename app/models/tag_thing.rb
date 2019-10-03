class TagThing < ApplicationRecord
  belongs_to :tag
  belongs_to :thing
end
