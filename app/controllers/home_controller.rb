class HomeController < ApplicationController

  before_filter :authenticate_data, only: 'data'

  def dashboard
    render 'dashboard', layout: 'dashboard'
  end

  def data
    respond_to do |format|
      format.json { render json: get_data }
    end
  end

  def rig
    @link = params[:name]
    render 'dashboard', layout: 'dashboard'
  end

private

  def authenticate_data
    authenticate unless params[:link].present?
  end

  def get_data
    # if development?
    #   JSON.parse(File.read(Rails.root.join('app/data/demo_data.json')))
    #else
      rig_info = get_rig_info
      rig_info.delete_if { |rig| rig[:link] != params[:link] } if params[:link].present?

      {
        btc_value: BtcValue.get,
        rig_info: rig_info,
        rig_overview: get_rig_overview(rig_info)
      }
    #end
  end

  def get_rig_info
    Miner.all.map(&:get_info).compact
  end

  def get_rig_overview(rig_info)
    data = {
      temp: 0,
      fan_p: 0,
      mhs: 0,
      accepted: 0,
      rejected: 0,
      max_temp: 0,
      max_fan_p: 0
    }

    gpu_count = 0

    rig_info.each do |rig|
      rig[:devs].each do |dev|
        gpu_count += 1
        data[:temp] += dev[:temp]
        data[:fan_p] += dev[:fan_p]
        data[:mhs] += dev[:mhs]
        data[:accepted] += dev[:accepted]
        data[:rejected] += dev[:rejected]

        data[:max_temp] = dev[:temp] if dev[:temp] > data[:max_temp]
        data[:max_fan_p] = dev[:fan_p] if dev[:fan_p] > data[:max_fan_p]
      end
    end

    if gpu_count > 0
      data[:temp] /= gpu_count.to_f
      data[:fan_p] /= gpu_count.to_f
    end

    data
  end
end
