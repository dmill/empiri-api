Rails.application.routes.draw do
  root to: "publications#index"

  match "/401" => "default_errors#unauthenticated", via: [:get, :post, :put, :delete, :patch]
  match "/404" => "default_errors#not_found", via: [:get, :post, :put, :delete, :patch]
  match "/400" => "default_errors#bad_format", via: [:get, :post, :put, :delete, :patch]
  match "/500" => "default_errors#exception", via: [:get, :post, :put, :delete, :patch]

  resources :experiments, only: [ :show ]
  resources :publications, only: [ :index, :show ]
end
