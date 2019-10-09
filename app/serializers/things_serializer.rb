class ThingsSerializer
  include FastJsonapi::ObjectSerializer
  set_type :thing  # optional
  set_id :id # optional  
  
  attributes :name, :description, :like_count, :download_count, :thingiverse_id, :image_url, :added_on, :created_at, :updated_at

  attribute :model_version_images, if: Proc.new { |record, params|
    params && params[:model_version_images] == true
  } do |object|
    object.model_version_images.collect{|mi| mi.index }
  end

  attribute :categories, if: Proc.new { |record, params|
    params && params[:details] == true
  } do |object|
    object.categories.map{|c| {name: c["name"] } }
  end

  attribute :tags, if: Proc.new { |record, params|
    params && params[:details] == true
  } do |object|
    object.tags.map(&:name)
  end

  attribute :user, if: Proc.new { |record, params|
    params && params[:details] == true
  } do |object|
    object.user.as_json(only: [:name, :first_name, :last_name])
  end
end
