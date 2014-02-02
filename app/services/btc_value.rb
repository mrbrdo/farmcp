module BtcValue
  extend self

  def get
    market_data_text = open("http://api.bitcoincharts.com/v1/markets.json") { |f| f.read }
    market_data = JSON.load(market_data_text)

    {
      btcde: market_data.find { |d| d["symbol"] == "btcdeEUR" }.try!(:[], "avg").to_f,
      bitstamp: market_data.find { |d| d["symbol"] == "bitstampUSD" }.try!(:[], "avg").to_f
    }
  end
end
