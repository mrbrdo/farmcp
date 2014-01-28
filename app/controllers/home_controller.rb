class HomeController < ApplicationController
  def dashboard
  end

  def data
    rig_info = get_rig_info

    data = {
      btc_value: get_btc_value,
      rig_info: get_rig_info,
      rig_overview: get_rig_overview(rig_info)
    }

    respond_to do |format|
      format.json { render json: data }
    end
  end

private
  def get_btc_value
    mtgox_data = open("https://www.bitstamp.net/api/ticker/") { |f| f.read }
    JSON.load(mtgox_data)["last"].to_f
  end

  def miners
    if conf = json_config
      conf["rigs"].map do |rig|
        addr = rig.strip.split(":")
        if addr[0].present?
          OpenStruct.new(host: addr[0], port: (addr[1] || 4028).to_i)
        end
      end
    else
      []
    end
  end

  def get_rig_info
    rig_data = miners.map do |miner|
      begin
        rpc = CgminerRpc.new(miner.host, miner.port)
        dev_keys = {
          temp: "Temperature",
          fan_p: "Fan Percent",
          mhs: "MHS 5s",
          accepted: "Accepted",
          rejected: "Rejected"
        }
        devs = rpc.cmd_devs["DEVS"].map do |dev|
          Hash.new.tap do |h|
            dev_keys.each_pair do |k, v|
              h[k] = dev[v]
            end
          end
        end
        pool = rpc.cmd_pools["POOLS"].max_by do |pool|
          pool["Last Share Time"] || 0
        end
        {
          host: miner.host,
          port: miner.port,
          devs: devs,
          pool: pool["URL"]
        }
      rescue StandardError
        nil
      end
    end

    rig_data.compact
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
