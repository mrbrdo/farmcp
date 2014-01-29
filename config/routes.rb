CoinProfit::Application.routes.draw do
  resources :pools
  get 'data' => 'home#data'
  root to: "home#dashboard"
end
