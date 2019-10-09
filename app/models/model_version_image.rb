class ModelVersionImage < ApplicationRecord
  belongs_to :model_version
  belongs_to :thing_file, optional: true
  belongs_to :thing

  include ::ImageUploader::Attachment.new(:image)
end
