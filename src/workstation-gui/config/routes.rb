Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  post "policies/install"
  # post "policies/push", to: "policies#push"
  post "policies/push"
  namespace :api do
    namespace :v1 do
      post "auth/login", to: "authentication#login"

      resource :cookbook, only: [:create]
      get "repositories/list_repositories", to: "repositories#repositories"
      get "repositories/link_repository", to: "repositories#link_repository" # todo - this is post call, but only get call is working in app so change later
      get "repositories/cookbooks", to: "cookbooks#cookbooks"
      get "cookbook/recipes", to: "recipes#recipes"
    end
  end
end
