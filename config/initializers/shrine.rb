require "shrine"
return if ENV.fetch("PRECOMPILE_ASSETS", false)


# use S3 for production and local file for other environments
# if Rails.env.production?
  require "shrine/storage/s3"


  s3_options = {
    access_key_id:     Rails.application.config.settings["digitalocean"]["access_key"],
    secret_access_key: Rails.application.config.settings["digitalocean"]["secret_access_key"],
    region:            Rails.application.config.settings["digitalocean"]["region"],
    bucket:            Rails.application.config.settings["digitalocean"]["bucket"],
    endpoint:          Rails.application.config.settings["digitalocean"]["endpoint"]
  }

  # both `cache` and `store` storages are needed
  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: "cache", **s3_options),
    store: Shrine::Storage::S3.new(**s3_options),
  }
# else
#   require "shrine/storage/file_system"

#   # both `cache` and `store` storages are needed
#   Shrine.storages = {
#     cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
#     store: Shrine::Storage::FileSystem.new("public", prefix: "uploads"),
#   }
# end

Shrine.plugin :activerecord
Shrine.plugin :instrumentation
# Shrine.plugin :determine_mime_type, analyzer: :marcel
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data

# Shrine.plugin :presign_endpoint, presign: -> (id, options, request) do
#   # return a Hash with :method, :url, :fields, and :headers keys
#   request.update_param("signed_id", id)
#   Shrine.storages[:cache].presign(id, options)
# end
# # if Rails.env.production?
#   Shrine.plugin :presign_endpoint, presign_options: -> (request) {
#     params = JSON.parse(request.body.read)
#     params.each{|k, v| request.update_param(k, v) }

#     filename = params["blob"]["filename"]
#     contenttype     = params["blob"]["content_type"]
#     request.update_param("filename", filename)
#     request.update_param("content_type", contenttype)

#     {
#       method: :put,
#       content_md5: params["blob"]["checksum"],
#       # content_disposition:    ContentDisposition.inline(filename), # set download filename
#       content_type:           contenttype,                                # set content type
#     }
#   }
# else
#   Shrine.plugin :upload_endpoint
# end

# Shrine.plugin :presign_endpoint, presign_location: -> (request) do
#   "#{SecureRandom.hex}/#{request.params["filename"]}"
# end

# Shrine.plugin :presign_endpoint, rack_response: -> (data, request) do
#   body = {
#     signed_id: request.params["signed_id"],
#     direct_upload: data
#   }.to_json
#   [201, { "Content-Type" => "application/json" }, [body]]
# end


Shrine.plugin :pretty_location

# Shrine.plugin :derivation_endpoint,
#   secret_key: "secret",
#   download_errors: [defined?(Shrine::Storage::S3) ? Aws::S3::Errors::NotFound : Errno::ENOENT]

# delay promoting and deleting files to a background job (`backgrounding` plugin)
# Shrine.plugin :backgrounding
# Shrine::Attacher.promote { |data| PromoteJob.perform_async(data) }
# Shrine::Attacher.delete { |data| DeleteJob.perform_async(data) }