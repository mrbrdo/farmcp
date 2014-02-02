class Miner
  attr_reader :host, :port

  def initialize(host, port)
    @host = host
    @port = port
  end

  def rpc
    CgminerRpc.new(host, port)
  end

  def to_s
    "#{host}:#{port}"
  end

  def id
    Digest::SHA1.hexdigest(to_s)
  end

  def get_pools
    rpc.cmd_pools["POOLS"].sort_by do |pool|
      pool["Priority"]
    end
  rescue
    nil
  end

  def get_info
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
      host: host,
      port: port,
      devs: devs,
      pool: pool["URL"]
    }
  rescue
    nil
  end

  class << self
    def all
      if conf = JsonConfig.get
        conf["rigs"].map do |rig|
          addr = rig.strip.split(":")
          if addr[0].present?
            new(addr[0], (addr[1] || 4028).to_i)
          end
        end
      else
        []
      end
    end
  end
end
