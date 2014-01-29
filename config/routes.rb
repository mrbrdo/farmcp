CoinProfit::Application.routes.draw do
  resources :pools do
    collection do
      put :switch
    end
  end
  get 'data' => 'home#data'
  root to: "home#dashboard"
end
