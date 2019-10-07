class Api::V1::ThingsController < ApplicationController
  before_action :set_thing, only: [:show, :edit, :update, :destroy]

  # GET /things
  # GET /things.json
  def index
    per_page = [params.fetch("per_page", 20).to_i, 50].min
    page = params.fetch("page", 1)
    @things = 
      if params[:q].blank?
        Thing.includes(:categories, :tags, :user).order("added_on desc").
          page(page).per(per_page).collect do |t|
            t.as_json(
              include: { categories: { only: :name},
                       tags:    { methods: [:lname], only: [:lname, :thing_count] },
                       user: { only: [:name, :first_name, :last_name]}
                      })
          end
      else
        Thing.search(params[:q]).page(page).per(per_page).collect do |t|
          t["_source"]
        end
      end
    # @things = @things.page(params["page"]).per(params["per_page"])
    # @things = Thing.page(params[:page])
    render json: {data: @things, meta: {page: page, per_page: per_page}}
  end

  # GET /things/1
  # GET /things/1.json
  def show
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
    @thing = Thing.new(thing_params)

    respond_to do |format|
      if @thing.save
        format.html { redirect_to @thing, notice: 'Thing was successfully created.' }
        format.json { render :show, status: :created, location: @thing }
      else
        format.html { render :new }
        format.json { render json: @thing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /things/1
  # PATCH/PUT /things/1.json
  def update
    respond_to do |format|
      if @thing.update(thing_params)
        format.html { redirect_to @thing, notice: 'Thing was successfully updated.' }
        format.json { render :show, status: :ok, location: @thing }
      else
        format.html { render :edit }
        format.json { render json: @thing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /things/1
  # DELETE /things/1.json
  def destroy
    @thing.destroy
    respond_to do |format|
      format.html { redirect_to things_url, notice: 'Thing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_thing
      @thing = Thing.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def thing_params
      params.require(:thing).permit(:name, :thing_id, :created_at, :updated_at)
    end
end
