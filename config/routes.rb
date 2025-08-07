
Rails.application.routes.draw do
  get '/cart_all_items', to: 'carts#all_items'
    post '/carts/add_item', to: 'carts#add_item'
  get "/products" ,to: "dashboards#summary"
  post "/add_products" , to: "dashboards#create"
  #patch "/products/:id", to: "dashboards#update"
  put "/products/:id", to: "dashboards#update"  
  get "/products/:id/edit", to: "dashboards#edit"
  delete "/products/:id", to: "dashboards#destroy"
  post '/api/auth/google', to: 'api/sessions#google_login'
  post "/create-checkout-session", to: "payments#create"
post '/webhooks/stripe', to: 'webhooks#stripe'
get '/success', to: 'payments#success'
get '/cancel', to: 'payments#cancel'
  get '/users/auth/failure', to: redirect('/')
    resources :cart_items, only: [:update, :destroy]
   resources :orders, only: [:create, :index] do
    resource :payment, only: [:create]
  end
  resources :carts, only: [:show] do
  post :add_item, on: :collection
  delete :remove_item, on: :collection
  end

  devise_for :users , 
  controllers:{
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  },
   defaults: { format: :json }
    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
# config/routes.rb
match '*path', via: [:options], to: lambda { |_| [204, {}, ['']] }


  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
