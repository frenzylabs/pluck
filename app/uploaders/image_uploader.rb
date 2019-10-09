class ImageUploader < Shrine
  def generate_location(io, context)
    # Rails.logger.info(io)
    # Rails.logger.info(context)

    if context[:record]
      if context[:record][:filepath]
        context[:record][:filepath]
      elsif context[:record][:path]
        context[:record][:path]
      else
        super
      end
    else
      super
    end
  end
end
