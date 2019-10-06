Rails.application.routes.draw do
  resources :tags
  resources :things
  resources :users
  
  namespace :api do 
    namespace :v1 do 
     resources :things
    end 
  end 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'
end
