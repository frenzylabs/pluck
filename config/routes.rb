Rails.application.routes.draw do
  resources :tags
  resources :things
  resources :users
  
  namespace :api do 
    namespace :v1 do 
     resources :things
     post 'model_versions/:id/things', to: 'model_versions#things'
     get 'model_versions/:id/:filepath', constraints: { filepath: /.*/ }, to: 'model_versions#show'
    end 
  end 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'
end
