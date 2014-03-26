class HomeController < ApplicationController
  ALLOW_ALL_TOKEN = 'all'
  skip_before_action :authenticate, only: [:data, :rig]

  def dashboard
    session[:rig_allow] = ALLOW_ALL_TOKEN

    render 'dashboard', layout: 'dashboard'
  end

  def data
    if session[:rig_allow].blank?
      render text: "Forbidden", status: 403
    else
      respond_to do |format|
        format.json { render json: get_data }
      end
    end
  end

  def rig
    session[:rig_allow] = params[:name] unless params[:name] == ALLOW_ALL_TOKEN
    render 'dashboard', layout: 'dashboard'
  end

private
  def get_data
    rig_info = get_rig_info
    data = if rig_info.empty? && development?
      development_data
    else
      {
        btc_value: BtcValue.get,
        rig_info: rig_info
      }
    end

    if session[:rig_allow] != ALLOW_ALL_TOKEN
      data[:rig_info].delete_if { |rig| session[:rig_allow].casecmp(rig[:link].to_s) != 0 }
    end

    data[:rig_overview] = get_rig_overview(data[:rig_info])

    data
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

  def development_data
    deeper_symbolize(JSON.parse(File.read(Rails.root.join('app/data/demo_data.json'))))
  end

  def deeper_symbolize(hash)
    return hash unless hash.kind_of?(Hash)
    hash = hash.deep_symbolize_keys
    hash.each_pair do |k, v|
      if v.kind_of?(Array)
        hash[k] = v.map { |av| deeper_symbolize(av) }
      end
    end
    hash
  end
end
