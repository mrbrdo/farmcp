class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate

protected
  def get_btc_value

    market_data_text = open("http://api.bitcoincharts.com/v1/markets.json") { |f| f.read }
    market_data = JSON.load(market_data_text)

    {
      btcde: market_data.find { |d| d["symbol"] == "btcdeEUR" }.try!(:[], "avg").to_f,
      bitstamp: market_data.find { |d| d["symbol"] == "bitstampUSD" }.try!(:[], "avg").to_f
    }
  end
  helper_method :get_btc_value

  def miners
    @miners ||= if conf = json_config
      conf["rigs"].map do |rig|
        addr = rig.strip.split(":")
        if addr[0].present?
          Miner.new(addr[0], (addr[1] || 4028).to_i)
        end
      end
    else
      []
    end
  end

  def json_config
    conf_file = File.expand_path("~/.farmcp")
    if File.exist?(conf_file)
      JSON.load(File.read(conf_file))
    end
  end

  def authenticate
    if conf = json_config
      if conf["password"]
        authenticate_or_request_with_http_basic do |username, password|
          username == conf["username"] && password == conf["password"]
        end
      end
    end
  end
end
