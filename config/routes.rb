CoinProfit::Application.routes.draw do
  get 'data' => 'home#data'
  root to: "home#dashboard"
end
