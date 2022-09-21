Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  post "auth/login", to: "authentication#login"
  get "auth/testing", to: "authentication#testing"
  post "policies/install"
  
end
