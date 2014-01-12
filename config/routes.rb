CoinProfit::Application.routes.draw do
  # mount Dashing::Engine, at: Dashing.config.engine_path
  resources :coins, only: [:index]
  
  root to: "coins#index"
end
