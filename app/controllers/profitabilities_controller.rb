class ProfitabilitiesController < ApplicationController
  def calculator
  end

  def pool_data
    data = Mpos.data(params[:pool_url])
    render json: { reward: data[0], diff: data[1] }
  end
end
