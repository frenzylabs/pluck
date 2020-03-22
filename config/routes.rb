Rails.application.routes.draw do
  resources :tags
  resources :things
  resources :users
  
  namespace :api do 
    namespace :v1 do 
     resources :things
     post 'image_search', to: 'model_versions#image_search'
     get 'model_versions/latest', to: 'model_versions#latest'
     post 'model_versions/:id/image_search', to: 'model_versions#image_search'
     post 'model_versions/:id/things', to: 'model_versions#things'
     get 'model_versions/:id/:filepath', constraints: { filepath: /.*/ }, to: 'model_versions#show'
    end 
  end 

  get 'things/:id', to: 'things#show'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'
end
