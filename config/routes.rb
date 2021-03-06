Rails.application.routes.draw do

  root 'photos#index'
  get 'add' => 'pages#add'
  get 'settings' => 'pages#settings'

  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  get 'logout' => 'sessions#destroy'
  delete 'logout' => 'sessions#destroy'
  get 'search' => 'searches#index'

  resources :users do
    member do
      put 'reset_password'
    end
  end

  resources :categories
  resources :uploads do
    get 'nodesc', on: :member
  end
  resources :photos, except: :new do
      get 'nodesc', on: :collection
      get 'download', on: :member
  end
end
