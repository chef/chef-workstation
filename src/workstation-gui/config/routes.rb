Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  post "auth/login", to: "authentication#login"
  get "auth/testing", to: "authentication#testing"
  namespace :api do
    namespace :v1 do
      get "cookbooks/testing", to: "cookbooks#testing"
      get "repositories/repositories", to: "repositories#repositories"
      get "repositories/link_repository", to: "repositories#link_repository"
    end

  end

end
