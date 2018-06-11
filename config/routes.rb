Rails.application.routes.draw do
  namespace :api do
    namespace :system do
      resource :status, only: :show
    end

    namespace :v1 do
      match 'split_registry', to: '/api/v1/cors#allow', via: :options
      resource :split_registry, only: :show

      match 'assignment_event', to: '/api/v1/cors#allow', via: :options
      resource :assignment_event, only: :create

      match 'identifier', to: '/api/v1/cors#allow', via: :options
      resource :identifier, only: :create

      match 'visitors/:id', to: '/api/v1/cors#allow', via: :options
      resources :visitors, only: :show

      resources :identifier_types, only: [], param: :name do
        resources :identifiers, only: [], param: :value do
          resource :visitor, only: :show, controller: 'identifier_visitors'
          resource :visitor_detail, only: :show
        end
      end

      # Shared secret-based assignment override for chrome extension
      match 'assignment_override', to: '/api/v1/cors#allow', via: :options
      resource :assignment_override, only: :create

      # Server-side authenticated endpoints
      resources :split_details, only: :show
      resources :split_configs, only: [:create, :destroy]
      resource :identifier_type, only: :create
    end

    namespace :v2 do
      resource :split_registry, only: :show
    end
  end

  if ENV['SAML_ISSUER'].present?
    devise_for :admins, controllers: { omniauth_callbacks: "admins/omniauth_callbacks" }

    devise_scope :admin do
      get 'admins/sign_in', to: 'admin/sessions#new', as: :new_admin_session
      delete 'admins/sign_out', to: 'devise/sessions#destroy', as: :destroy_admin_session
    end
  else
    devise_for :admins
  end


  namespace :admin do
    root 'splits#index'
    resources :splits, only: [:show] do
      resource :details, only: [:edit, :update], controller: 'split_details'
      resource :split_config, only: [:new, :create]
      resources :bulk_assignments, only: [:new, :create]
      resources :decisions, only: [:new, :create]
      resources :variants, only: [] do
        resource :retirement, only: [:create], controller: 'variant_retirements'
      end
      resources :variant_details, only: [:edit, :update]
    end
  end
end
