Rails.application.routes.draw do
  get 'feedbacks/create'
  get 'users/update'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  devise_for :users
  resources :users, except: [:show]
  devise_scope :user do
    get 'users/sign_out' => "devise/sessions#destroy"
  end

  root to: "pages#home"

  # Defines the root path route ("/")
  # root "posts#index"
  get "/new", to: "pages#new"
  get "/test", to: "pages#test"
  get "/fplteams", to: "fplteams#index"
  get "fplteams/:id", to: "fplteams#show", as: :fplteam
  get "/transfers", to: "pages#transfers"
  get "/admin", to: "pages#admin"
  get "/penalties", to: "penalties#index"
  get "/rules", to: "pages#rules"
  resources :penalties

  require "sidekiq/web"
  # Sidekiq::Web.set :sessions, false
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :feedbacks, only: [:create, :destroy]

  post 'pages/update_scores', to: 'pages#update_scores', as: 'update_scores_pages'
end
