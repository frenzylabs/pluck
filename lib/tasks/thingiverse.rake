task :add, [:num1, :num] do |t, args|
  puts args[:num1].to_i + args[:num].to_i
end

namespace :things do
  desc 'Say hello!'
  task :featured => :environment do
    puts "Hello"
    res = Thing.all
    
    
    params = {page: 1, sort: :date, order: :desc}
    create_things("/featured", params)
  end

  task :recent, [:start] => :environment do |t, args|
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::INFO
    startPage = args[:start].to_i || 1 #356 #2705
    
    params = {page: startPage, sort: :date, order: :desc}
    hasError = false
    hasMore = true
    retryCount = 0
    while !hasError && hasMore
      hasMore = false
      # hasError = true
      res = create_things("/newest", params)
      if res.key?(:error)
        if res.key?(:retry) && res[:retry] < 15
          hasMore = true
        else
          hasError = true
        end
      elsif res.key?(:success) && res[:success] > 0
        params[:page] = params[:page] + 1
        puts params[:page] if params[:page] % 100 #== 0
        retryCount = 0
        @retry = 0
        hasMore = true #unless params[:page] - startPage > 2
      elsif retryCount < 3
        puts "retrying"
        retryCount += 1
        hasMore = true
      end
    end
  end

  task :tags => :environment do
    startPage = 2689
    params = {page: startPage, sort: :date, order: :desc}
    hasError = false
    hasMore = true
    retryCount = 0
    while !hasError && hasMore
      hasMore = false
      res = create_tags("/tags", params)
      if res.key?(:error)
        if res.key?(:retry) && res[:retry] < 5
          hasMore = true
        else
          hasError = true
        end
      elsif res.key?(:success) && res[:success] > 0
        params[:page] = params[:page] + 1
        puts params[:page] if params[:page] % 100 #== 0
        retryCount = 0
        @retry = 0
        hasMore = true #unless params[:page] - startPage > 2
      elsif retryCount < 3
        puts "retrying"
        retryCount += 1
        hasMore = true
      end
    end
    puts ("Final page = #{params}")
  end

  task :create_categories => :environment do
    params = {page: 1}
    res = create_categories("/categories", params)
  end

  

  task :by_category, [:cat_id, :start] => :environment do |t, args|
    # Category.each
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::INFO
    Rails.logger.info(Rails.application.config.settings["thingiverse"]["app_token"])
    catid = args[:cat_id] || 0

    # cat = Category.find(catid)
    finish = catid.to_i + 10
    startPage = args[:start].to_i || 0 #356 #2705
    Category.where("id >= #{catid}").find_each(finish: finish) do |cat|
      Rails.logger.info(cat)
      subpath = cat.url.split("https://api.thingiverse.com").last + "/things"
      startPage = 0
      
      startPage = (args[:start].to_i || 0) if cat.id == catid
      params = {page: startPage, sort: :date, order: :desc}
      hasError = false
      hasMore = true
      retryCount = 0
      @retry = 0
      while !hasError && hasMore
        hasMore = false
        # hasError = true
        res = create_things(subpath, params)
        # binding.pry
        
        if res.key?(:error)
          if res.key?(:retry) && res[:retry] < 15
            hasMore = true
          else
            hasError = true
          end
        elsif res.key?(:success) && res[:success] > 0
          if res[:thingiverse_ids]
            begin
              thing_ids = Thing.where(thingiverse_id: res[:thingiverse_ids]).pluck(:id)
              # exist = cat.category_things.select(:thing_id).where(thing_id: res[:thingiverse_ids]).pluck(:thingiverse_ids)
              # things = (res[:thing_ids] - exist).map{|id| {thing_id: id} }
              things = thing_ids.map{|id| [cat.id, id, DateTime.now.utc, DateTime.now.utc] }
              columns = ["category_id", "thing_id", "created_at", "updated_at"]
              res = CategoryThing.import(columns, things, on_duplicate_key_ignore: true)
              if res.failed_instances.count > 0
                Rails.logger.info("Res-CatThing: Failed: #{res.failed_instances},  Num IDS: #{res.ids.count}, , Num Inserts: #{res.num_inserts}, ")
              end
              # cthings = cat.category_things.build(things)
              if !cat.save
                puts "Failed relationships to cat for #{cat.name}  #{params}"
              end
            rescue ActiveRecord::RecordNotUnique => e
              puts "Rescue not unique #{cat.name} #{params}"
              puts "Rescue not unique #{e}"
            end
          end
          params[:page] = params[:page] + 1
          puts params[:page] if params[:page] % 100 #== 0
          retryCount = 0
          hasMore = true #unless params[:page] - startPage > 2
        elsif retryCount < 3
          puts "retrying"
          retryCount += 1
          hasMore = true
        end
      end
    end
  end

  task :details, [:start] => :environment do |t, args|
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::INFO
    params = {page: 1}
    job = Job.last
    # start_id = 196
    start_id = args[:start].to_i || 0 #356 #2705
    end_id  = start_id + 25000
    # start_id = 1196
    # end_id  = start_id + 804 #1000
    currentID = start_id
    begin
      Thing.where("id >= #{start_id}").where("id < #{end_id}").where("like_count = 0").where("description IS NULL").each do |thing|
        currentID = thing.id
        thing.job = job
        res = create_details(thing, params, [:tags, :files, :categories] )
        if !res.key?(:error) && thing.save
          puts "Updated thing #{thing.id}"
        else
          puts "Failed thing #{thing.id}:  #{res}: #{thing.errors}"
        end
        # binding.pry
      end
    rescue => e
      puts "Failed on id: #{currentID}"
      raise
    end
  end

  task :fetch_files, [:start_id, :end_id] => :environment do |t, args|
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::INFO
    params = {page: 1}

    start_id = args[:start_id].to_i || 0    
    batch_size = 500
    offset = 0
    thingquery = Thing.includes(:thing_files).where("id >= #{start_id}")
    end_id = args[:end_id].to_i || 0  
    thingquery = thingquery.where("id <= #{end_id}") if end_id > 0

    Rails.logger.info("Starting ID #{start_id}")
    cnt = 0
    hasMore = true
    while hasMore
      hasMore = false
      cnt += 1
      Rails.logger.info("Starting Cnt #{cnt}")
      doccnt = thingquery.limit(batch_size).offset(offset).each do |t|
        fresp = fetch_thing_files(t)
        # t.thing_files
      end 
      # {|t| t.__elasticsearch__.index_document }.count
      if doccnt == batch_size
        offset += batch_size
        hasMore = true
      end
    end
  end

  task :download_files, [:start_id, :end_id] => :environment do |t, args|
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::INFO
    params = {page: 1}

    start_id = args[:start_id].to_i || 0    
    batch_size = 500
    offset = 0
    thingquery = ThingFile.where("thing_id >= #{start_id}")
    end_id = args[:end_id].to_i || 0  
    thingquery = thingquery.where("thing_id <= #{end_id}") if end_id > 0

    Rails.logger.info("Starting ID #{start_id}")
    cnt = 0
    hasMore = true
    while hasMore
      hasMore = false
      cnt += 1
      Rails.logger.info("Starting Cnt #{cnt}")
      doccnt = thingquery.limit(batch_size).offset(offset).each do |tf|
        # fresp = fetch_thing_files(t)
        unless tf.image_url.blank?
          ext = tf.image_url.split(".").last
          trainimage = "#{tf.thingiverse_id}-#{tf.name}.#{ext}"
          open(tf.image_url) do |image|
            File.open("/Users/kmussel/Development/metismachine/visual-search-model/input_images/#{trainimage}", "wb") do |file|
              file.write(image.read)
            end
          end
        end
        # t.thing_files
      end 
      # {|t| t.__elasticsearch__.index_document }.count
      if doccnt == batch_size
        offset += batch_size
        hasMore = true
      end
    end
  end

end

def build_user(ujson)
  {
    name: ujson["name"],
    thingiverse_id: ujson["id"],
    first_name: ujson["first_name"],
    last_name: ujson["last_name"]
  }  
end

def build_thing(tjson, thing = nil)
  
  th = {
    name: tjson["name"],
    thingiverse_id: tjson["id"],    
    image_url: tjson["thumbnail"],
    added_on: tjson["added"],
    updated_on: tjson["modified"]
  }
  th["description"] = tjson["description"] if tjson["description"]
  th["like_count"] = tjson["like_count"] if tjson["like_count"]
  th["download_count"] = tjson["download_count"] if tjson["download_count"]

  
  # return th if thing && thing.user_id
  # if tjson["creator"] && tjson["creator"].is_a?(Hash)
  #   creator = tjson["creator"]
  #   userhash = build_user(creator)
  #   user = User.find_or_initialize_by(thingiverse_id: creator["id"])
  #   updated = user.update_attributes(userhash)
  #   if updated
  #     th[:user_id] = user.id
  #   end
  # end
  th

end

def build_tag(tjson)
  {
    name: tjson["name"].downcase,
    thing_count: tjson["count"]
  }  
end

# def create_details(thing)

# end

def create_details(thing, params, includes = [])
  path = "/things/#{thing.thingiverse_id}"
  resp = fetch_from_thingiverse(path, params)
  if resp[:error]
    puts ("Failed Fetching Details: #{path} #{params}: #{resp[:error]}")
    return resp
  else
    
    if resp.body["id"]
      thingresp =  resp.body
      
      # sthing = Thing.find_or_initialize_by(:thingiverse_id => thingresp["id"])
      thing.assign_attributes(build_thing(thingresp, thing))
      if thing.valid?
        if includes.include?(:files)
          fresp = fetch_thing_files(thing)  
        end
        if includes.include?(:tags)
          fresp = fetch_thing_tags(thing)  
        end
        if includes.include?(:categories)
          fresp = fetch_thing_categories(thing)  
        end
        
      else
          puts ("Failed Updating Thing #{thing["id"]} #{sthing.errors}")
      end
    end
    return {success: thing.valid?}
  end
end

def build_thing_file(f, thing = nil)
  # {
  #   name: f["name"],
  #   thingiverse_id: f["id"],
  #   download_count: f["download_count"]
  # }
  image_url = ""
  if f["default_image"] && f["default_image"]["sizes"]
    
    dfimage = f["default_image"]["sizes"].find { |im| im["size"] == "large" && im["type"] == "preview" }
    if dfimage && dfimage["url"]
      image_url = dfimage["url"]
    end
    # binding.pry
    # Rails.logger.info(image_url)
  end
  [f["name"], f["id"], f["download_count"], thing.id, image_url, DateTime.now.utc, DateTime.now.utc]
end


def fetch_thing_files(thing, params = {})
  path = "/things/#{thing.thingiverse_id}/files"
  resp = fetch_from_thingiverse(path, params)
  if resp[:error]
    puts ("Failed Fetching File For #{thing.id} tvid: #{thing.thingiverse_id}: #{path} #{params}: #{resp[:error]}")
    return resp
  else
    
    if resp.body.length > 0
      columns = ["name", "thingiverse_id", "download_count", "thing_id", "image_url", "created_at", "updated_at"]
      hm = resp.body.map {|v| [v["id"], build_thing_file(v, thing)] }.to_h
      filethingids = hm.keys 
      exist = thing.thing_files.select(:thingiverse_id).where(thingiverse_id: filethingids).pluck(:thingiverse_id)
      thingfiles = (filethingids).map{|id| hm[id] }

      # binding.pry
      res = ThingFile.import(columns, thingfiles, on_duplicate_key_update: {conflict_target: [:thingiverse_id], columns: [:download_count, :updated_at, :image_url]})
      # thing.thing_files.build(thingfiles)
      # binding.pry
      return res
      # if !thing.valid?
      #     puts ("Failed Creating ThingFiles #{thing["id"]} #{thing.errors}")        
      # end
    end
    return {success: thing.valid?}
  end
end

def fetch_thing_tags(thing, params = {})
  path = "/things/#{thing.thingiverse_id}/tags"
  resp = fetch_from_thingiverse(path, params)
  if resp[:error]
    puts ("Failed Fetching File For #{thing.id} tvid: #{thing.thingiverse_id}: #{path} #{params}: #{resp[:error]}")
    return resp
  else
    
    if resp.body.length > 0
      columns = ["tag_id", "thing_id", "created_at", "updated_at"]
      hm = resp.body.map {|v| [v["name"].downcase, build_tag(v)] }.to_h
      tagnames = hm.keys 
      curtags = thing.tags.where(manual: false).to_a
      curtnames = curtags.map {|t| t.name.downcase }
      deletetags = curtags.select {|t| !tagnames.include?(t.name.downcase) }

      inserttagnames = (tagnames - curtnames)

      tagexists = Tag.where(name: inserttagnames)
      exist = tagexists.map {|t| t.name.downcase }
      tagnamesneedcreated = (inserttagnames - exist)
      tagsneedcreated = tagnamesneedcreated.map{|id| hm[id] }      
      thing.tags.build(tagsneedcreated)
      thing.tags.delete(deletetags)
      # thing.tags << tagexists
      res = TagThing.import(columns, tagexists.map{|t| [t.id, thing.id, DateTime.now.utc, DateTime.now.utc] }, on_duplicate_key_ignore: true)
      
      # binding.pry
      if res.failed_instances.count > 0
        Rails.logger.info("Res: Failed: #{res.failed_instances},  Num IDS: #{res.ids.count}, , Num Inserts: #{res.num_inserts}, ")
      end
      return res
      # if !thing.valid?
      #     puts ("Failed Creating ThingTags #{thing["id"]} #{thing.errors}")        
      # end
    end
    return {success: thing.valid? }
  end
end

def fetch_thing_categories(thing, params = {})
  path = "/things/#{thing.thingiverse_id}/categories"
  resp = fetch_from_thingiverse(path, params)
  if resp[:error]
    puts ("Failed Fetching Category For #{thing.id} tvid: #{thing.thingiverse_id}: #{path} #{params}: #{resp[:error]}")
    return resp
  else
    
    if resp.body.length > 0
      columns = ["category_id", "thing_id", "created_at", "updated_at"]
      catnames = resp.body.map {|c| c["name"].downcase }
      cats = Category.where(name: catnames)
      curcats = thing.categories
      deletecats = curcats.select {|t| !catnames.include?(t.name.downcase) }

      thing.categories.delete(deletecats)
      res = CategoryThing.import(columns, (cats - curcats).map{|t| [t.id, thing.id, DateTime.now.utc, DateTime.now.utc] }, on_duplicate_key_ignore: true)
      
      # thing.categories << (cats - curcats)
      
      return res
      # if !thing.valid?
      #     puts ("Failed Creating ThingCategories #{thing["id"]} #{thing.errors}")        
      # end
    end
    return {success: thing.valid?}
  end
end

def create_categories(path, params)  
  resp = fetch_from_thingiverse(path, params)
  if resp[:error]
    puts("Failed Fetching Categories: #{path} #{params}: #{resp[:error]}")
    resp
  else
    if resp.body.length > 0
      resp.body.each do |tg|
        cat = Category.find_or_initialize_by(:name => tg["name"])        
        updated = cat.update_attributes({url: tg["url"]})
        if !updated
          puts ("Failed Creating Category #{tg["name"]} #{cat.errors}")
        else
          subpath = tg["url"].split("https://api.thingiverse.com").last
          create_sub_categories(subpath, {})
        end
      end
    else
      puts "REs: #{resp.body}"
      puts "REs: #{resp.headers}"
    end
    { success: resp.body.length }
  end
end

def create_sub_categories(path, params)  
  resp = fetch_from_thingiverse(path, params)
  if resp[:error]
    puts("Failed Fetching SubCAts: #{path} #{params}: #{resp[:error]}")
    resp
  else
    # binding.pry
    if resp.body["children"] 
      if resp.body["children"].length > 0
        parcat = Category.find_by(name: resp.body["name"])
        resp.body["children"].each do |tg|
          cat = parcat.children.find_or_initialize_by(:name => tg["name"])        
          updated = cat.update_attributes({url: tg["url"]})
          if !updated
            puts ("Failed Creating Category #{tg["name"]} #{cat.errors}")
          # else
          #   subpath = tg["url"].split("https://api.thingiverse.com").last
          #   create_sub_categories(path, {})
          end
        end
      end
      { success: resp.body["children"].length }
    else
      puts "REs: #{resp.body}"
      puts "REs: #{resp.headers}"
      { success: 0 }
    end
    
  end

end

def create_tags(path, params)  
  resp = fetch_from_thingiverse(path, params)
  if resp[:error]
    puts("Failed Fetching Tags: #{path} #{params}: #{resp[:error]}")
    resp
  else
    if resp.body.length > 0
      resp.body.each do |tg|
        stag = Tag.find_or_initialize_by(:name => tg["name"])
        updated = stag.update_attributes(build_tag(tg))
        if !updated
          puts ("Failed Creating Tag #{tg["name"]} #{stag.errors}")
        end
      end
    else
      puts "REs: #{resp.body}"
      puts "REs: #{resp.headers}"
    end
    { success: resp.body.length }
  end
end

def create_things(path, params)

  resp = fetch_from_thingiverse(path, params)
  if resp[:error]
    puts ("Failed Fetching: #{path} #{params}: #{resp[:error]}")
    return resp
  else
    thingiverse_ids = []
    users = []
    user_ids = []
    if resp.body.length > 0
      things = resp.body.map do |t| 
        thing = Thing.new(build_thing(t))
        thingiverse_ids << thing.thingiverse_id
        if t["creator"] && t["creator"].is_a?(Hash)
          creator = t["creator"]
          users << thing.build_user(build_user(creator))
          user_ids << creator["id"]          
        end
        thing
      end
      ures = User.bulk_import(users, on_duplicate_key_ignore: true)
      
      cusers = User.where(thingiverse_id: users.pluck(:thingiverse_id)).map {|u| [u.thingiverse_id, u] }.to_h
      
      validthings = things.select do |t|
        next unless t.user
        t.user = cusers[t.user.thingiverse_id]
        t
      end
      # things.each {|t| t.user = cusers[t.user.thingiverse_id]}
      # binding.pry
      # cusers = User.find_by(thingiverse_id: user_ids)

      res = Thing.bulk_import(validthings, on_duplicate_key_ignore: true, returning: :id)
      if res.failed_instances.count > 0
        Rails.logger.info("Thing Res: Failed: #{res.failed_instances},  Num IDS: #{res.ids.count}, , Num Inserts: #{res.num_inserts}, ")
      end
    end
    return {success: resp.body.length, thingiverse_ids: thingiverse_ids}
  end
end

def fetch_from_thingiverse(path, params) 
  # puts "Conn: #{@conn}"
  @conn ||= Faraday.new(:url => "https://api.thingiverse.com") do |con|
    # binding.pry
    con.options[:open_timeout] = 20
    con.options[:timeout] = 300
    con.response :json, :content_type => /\bjson$/
    con.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    
    # con.options[:open_timeout] = 20,   # opening a connection
    # con.options[:timeout] = 30         # waiting for response
  end
  
  resp = @conn.get do |req|
    req.options.timeout = 50           # open/read timeout in seconds
    req.options.open_timeout = 20      # connection open timeout in seconds
    req.url path #"/things/#{params[:thing_id]}"
    req.params = params
    req.headers['Authorization'] = "Bearer #{Rails.application.config.settings["thingiverse"]["app_token"]}"
  end
  
  # binding.pry
  # Rails.logger.info(resp.body)
  
  error_msg = "Error Retrieving From Thingiverse"
  if resp.body.is_a?(Hash)
    error_msg += ": #{resp.body["error"]}" if resp.body["error"]
    error_msg += ": #{resp.headers["x-error"]}" if resp.headers["x-error"]    
    if resp.body["error"] || resp.headers["x-error"]
      return {error: error_msg, url: path}
    end  
    resp
  else 
    resp
  end

rescue Faraday::ConnectionFailed => e
  @conn = nil
  @retry ||= 0
  @retry += 1
  {error: "ConnectionFailed", retry: @retry}
rescue Exception => e
  {error: "#{e}"}
end
