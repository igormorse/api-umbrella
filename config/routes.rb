ApiUmbrella::Application.routes.draw do
  # Mount the API at both /api/ and /api-umbrella/ for backwards compatibility.
  %w(api api-umbrella).each do |path|
    namespace(:api, :path => path) do
      resources :api_users, :path => "api-users", :only => [:show, :create] do
        member do
          get "validate"
        end
      end

      resources :health_checks, :path => "health-checks", :only => [] do
        collection do
          get :ip
          get :logging
        end
      end

      resource :hooks, :only => [] do
        post "publish_static_site"
      end

      namespace :v1 do
        resources :admin_groups
        resources :admin_scopes
        resources :admins
        resources :apis
        resources :users
        resource :contact, :only => [:create]
      end
    end
  end

  devise_for :admins, :controllers => { :omniauth_callbacks => "admin/admins/omniauth_callbacks" }

  devise_scope :admin do
    get "/admin/login" => "admin/sessions#new", :as => :new_admin_session
    get "/admin/logout" => "admin/sessions#destroy", :as => :destroy_admin_session
  end

  match "/admin" => "admin/base#empty"

  namespace :admin do
    resources :apis, :only => [] do
      member do
        put "move_to"
      end
    end

    resources :stats, :only => [:index] do
      collection do
        get "search"
        get "logs"
        get "users"
        get "map"
      end
    end

    namespace :config do
      get "publish", :action => "show"
      post "publish", :action => "create"

      get "import_export"
      get "export"
      post "import_preview"
      post "import"
    end

    resources :api_users do
      get "page/:page", :action => :index, :on => :collection
    end
  end
end
