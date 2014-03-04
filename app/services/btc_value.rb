module BtcValue
  extend self

  def get
    market_data_text = open("http://api.bitcoincharts.com/v1/markets.json") { |f| f.read }
    market_data = JSON.load(market_data_text)

    {
      btcde: calc_price(market_data.find { |d| d["symbol"] == "btcdeEUR" }),
      bitstamp: calc_price(market_data.find { |d| d["symbol"] == "bitstampUSD" })
    }
  rescue
    return {
      btcde: 0.0,
      bitstamp: 0.0
    }
  end

private
  def calc_price(data)
    return 0 unless data

    bid = data["bid"].to_f
    diff = data["ask"].to_f - bid

    if diff > 0
      bid + diff / 2
    else
      bid
    end
  end
end
