class HomeController < ApplicationController
  def index
    @per_page = [params.fetch("per_page", 20).to_i, 50].min
    @page     = params.fetch("page", 1)

    @things = 
      if params[:q].blank?
        Thing.includes(:categories, :tags, :user).where(deleted: false).order("updated_at desc").
          page(@page).per(@per_page).collect do |t|
            {"id": t["id"], "attributes": t.as_json(
              include: { categories: { only: :name},
                       tags:    { methods: [:lname], only: [:lname, :thing_count] },
                       user: { only: [:name, :first_name, :last_name]}
                      })
            }
          end
      else
        Thing.search(params[:q]).page(@page).per(@per_page).collect do |t|
          {"id": t["_source"]["id"], "attributes": t["_source"] }
        end
      end

    @paginatedthings = Kaminari.paginate_array(@things, total_count: (@page.to_i * @things.count) + 2).page(@page).per(@per_page)
  end
end
