CoinProfit::Application.routes.draw do
  resource :profitability do
    get :calculator
    get :pool_data
  end

  resources :pools do
    collection do
      put :switch
    end
  end

  get 'rig/:name' => 'home#rig'

  get 'data' => 'home#data'
  root to: "home#dashboard"
end
