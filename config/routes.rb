Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  devise_for :users
  root to: "pages#home"

  # Defines the root path route ("/")
  # root "posts#index"
  get "/new", to: "pages#new"
  get "/test", to: "pages#test"
  get "/fplteams", to: "fplteams#index"
  get "fplteams/:id", to: "fplteams#show", as: :fplteam
  require "sidekiq/web"
  # Sidekiq::Web.set :sessions, false
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
