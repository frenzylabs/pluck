module ApplicationHelper
  def current_env
    Rails.application.config.settings["env"]
  end
end
