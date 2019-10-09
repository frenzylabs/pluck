class Api::V1::ModelVersionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_model_version, only: [:show, :edit, :update, :destroy, :things]
  

  # GET /things
  # GET /things.json
  def index
    # @things = Thing.all
    # indexarr = params[:indices]
    # # indexarr = [60, 59, 62, 61, 70, 94, 72, 71, 85, 32, 16, 6, 27, 38, 14, 90, 48, 39, 74, 66]
    # # mi = indexarr.map.with_index(0).to_a
    
    # res = Thing.joins(:model_version_images).where('model_version_images.index' => indexarr).group("things.id")

    # mindex = indexarr.each_with_index.map {|m, i| "(#{m},#{i})" }.join(",")
    # # r = Thing.select("things.*, MIN(x.ordering) as imgorder").joins(:model_version_images).joins("INNER JOIN ( values #{mindex}) as x (index, ordering) ON model_version_images.index = x.index").group("things.id").order("imgorder").includes(:model_version_images).page(1).per(2)
    # r = Thing.select("things.*, MIN(x.ordering) as imgorder").joins("model_version_images as images ON things.id = images.thing_id").joins(:model_version_images).joins("INNER JOIN ( values #{mindex}) as x (index, ordering) ON model_version_images.index = x.index").group("things.id").order("imgorder").includes(:model_version_images)
    # res = Thing.joins(:model_version_images).joins("INNER JOIN ( values #{mindex}) as x (index, ordering) ON model_version_images.index = x.index").group("things.id")
  end

  # GET /things/1
  # GET /things/1.json
  def show
    redirect_to Shrine.storages[:store].url("models/#{@model_version.id}/artifacts/#{params["filepath"]}")
  end

  def things
    indexarr = params[:indices]
    mindex = indexarr.each_with_index.map {|m, i| "(#{m},#{i})" }.join(",")
    things = Thing.select("things.*, MIN(x.ordering) as imgorder").joins(:model_version_images).
              joins("INNER JOIN ( values #{mindex}) as x (index, ordering) ON model_version_images.index = x.index").
              where("model_version_images.model_version_id = ?", @model_version.id).
              group("things.id").order("imgorder").
              page(params[:page]).per(params[:per_page]).
              includes(:categories, :tags, :user)
    ActiveRecord::Associations::Preloader.new.preload(things, :model_version_images, @model_version.images)
    options = {meta: { total: things.total_count, last_page: things.total_pages, current_page: things.current_page } }
    options[:params] = { model_version_images: true, details: true }
    thingshash = ThingsSerializer.new(things, options).serializable_hash
    render status: 200, json: thingshash  
    # products.each do |product|
    # res = Thing.joins(:model_version_images).where('model_version_images.index' => indexarr).group("things.id")
  end

  # GET /things/new
  def new
    @thing = Thing.new
  end

  # GET /things/1/edit
  def edit
  end

  # POST /things
  # POST /things.json
  def create
    # @thing = Thing.new(thing_params)

    # respond_to do |format|
    #   if @thing.save
    #     format.html { redirect_to @thing, notice: 'Thing was successfully created.' }
    #     format.json { render :show, status: :created, location: @thing }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @thing.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /things/1
  # PATCH/PUT /things/1.json
  def update
    # respond_to do |format|
    #   if @thing.update(thing_params)
    #     format.html { redirect_to @thing, notice: 'Thing was successfully updated.' }
    #     format.json { render :show, status: :ok, location: @thing }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @thing.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /things/1
  # DELETE /things/1.json
  def destroy
    # @thing.destroy
    # respond_to do |format|
    #   format.html { redirect_to things_url, notice: 'Thing was successfully destroyed.' }
    #   format.json { head :no_content }
    # end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_model_version
      @model_version = ModelVersion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def thing_params
      params.require(:thing).permit(:name, :thing_id, :created_at, :updated_at)
    end
end
