Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # System Info 
  get '/ping', controller:'system/pings', action: 'index'
  
  # System Administration
  namespace :system, path: '/sys' do
    root controller: 'roots', action: 'index'
    resources :users,     only: [:index,:edit]
    resources :sites,     only: [:index,:edit,:show,:update]
    resources :programs,  only: [:index,:edit]
    resources :connections,  only: [:index,:new,:create,:show]
    resources :jobs, only: [:index,:show]
    resources :clips, only: [:index,:show]
    resource :settings,     only: [:show,:update]
  end

  # API
  namespace :api do
    resource :system, only: [:show]
    resource :user, only: [:show,:update]
    resource :site, only: [:show,:update]
    resources :users
    resources :programs
    resources :channels
    resources :themes
    resources :pages
    resources :domains
    resources :allocations, only: [:index]
    resources :clips, only: [:index,:create]
  end
  
  # Old CMS
  get '/cms(*path)', to: redirect('/hub')

  # Hub
  get '/hub(*path)', controller:'hub/backbones', action: 'show', as: 'hub'

  
  # Security
  devise_for :users, controllers: {
    sessions: 'security/sessions',
    registrations: 'security/registrations',
    confirmations: 'security/confirmations',
    passwords: 'security/passwords',
    unlocks: 'security/unlocks'}  

  # Site Setup
  resource :site, only: [:create,:new], module: :setup

  # Main App Views
  scope module: :presentation do  
    root controller: 'home', action: 'index'
    get 'index', controller: 'home', action: 'index'
    get 'home', controller: 'home', action: 'index'

    resources :users, only: [:show,:index]

    resources :programs, only: [:index,:show] do
      resources :elements, only: [:show]
      resource :playlist, only: [:show]
    end
    resources :channels, only: [:index,:show] do
      resources :programs, only: [:index,:show] do
        resources :elements, only: [:show]
        resource :playlist, only: [:show]
      end
    end
    resources :stations, only: [:index]

    resources :pages, only: [:show]
    resource :search, only: [:show]
  end

  # Catch any other routes and send to our redirector
  get '/(*paths)', controller: 'redirection/redirects', action: 'show'
end
