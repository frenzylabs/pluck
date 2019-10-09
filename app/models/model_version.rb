class ModelVersion < ApplicationRecord
  has_many :images, class_name: 'ModelVersionImage'
  before_validation :set_version, on: :create
  def set_version
    self.version = (ModelVersion.maximum("version") || 0) + 1
  end
end
