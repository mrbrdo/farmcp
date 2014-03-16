class HomeController < ApplicationController

  def dashboard
    render 'dashboard', layout: 'dashboard'
  end

  def data

    data = if development?
      JSON.parse(File.read('lib/demo_data.json'))
    else
      rig_info = get_rig_info

      {
        btc_value: BtcValue.get,
        rig_info: rig_info,
        rig_overview: get_rig_overview(rig_info)
      }
    end

    respond_to do |format|
      format.json { render json: data }
    end
  end

private
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
