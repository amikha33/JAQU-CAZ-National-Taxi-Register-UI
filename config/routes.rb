# frozen_string_literal: true

Rails.application.routes.draw do
  scope controller: :application do
    get :build_id, constraints: { format: :json }, defaults: { format: :json }
    get :health, constraints: { format: :json }, defaults: { format: :json }
  end

  devise_for :users, controllers: { sessions: 'sessions' }

  constraints(CheckRequestFormat) do
    authenticated(:user) { root 'upload#index', as: :authenticated_root }
    devise_scope(:user) { root to: 'devise/sessions#new' }

    resources :vehicles, only: %i[index] do
      collection do
        get :search
        post :search, to: 'vehicles#submit_search'
        get :historic_search
        get :not_found
      end
    end

    resources :upload, only: %i[] do
      collection do
        post :import
        get :processing
        get :success
        get :data_rules
      end
    end

    resources :la_request, only: %i[index] do
      collection do
        post :index, to: 'la_request#submit_la_request'
        get :review
        post :review, to: 'la_request#submit_review'
      end
    end

    resources :passwords, only: %i[new create] do
      collection do
        get '/', to: redirect('/')
        get :success
        get :reset
        get :email_send
        get :invalid_or_expired
        post :submit_reset_your_password
        get :confirm_reset
        post :change
      end
    end

    scope controller: 'static_pages' do
      get :accessibility_statement
      get :cookies
      get :privacy_notice
    end

    scope controller: 'errors' do
      get :service_unavailable
    end

    match '/404', to: 'errors#not_found', via: :all
    match '/422', to: 'errors#internal_server_error', via: :all
    match '/500', to: 'errors#internal_server_error', via: :all
    match '/503', to: 'errors#service_unavailable', via: :all
  end
  match '*unmatched', to: 'errors#not_found', via: :all
end
