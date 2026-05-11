Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Cria o mapeamento Devise sem gerar rotas padrão
  devise_for :users, skip: :all

  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post   "auth/signup",       to: "registrations#create"
        post   "auth/sign_in",      to: "sessions#create"
        delete "auth/sign_out",     to: "sessions#destroy"
        post   "auth/password",     to: "passwords#create"
        put    "auth/password",     to: "passwords#update"
        post   "auth/confirmation", to: "confirmations#create"
        get    "auth/confirmation", to: "confirmations#show"
      end

      scope :users do
        get   "me", to: "users#me"
        patch "me", to: "users#update_me"
      end
    end
  end
end
