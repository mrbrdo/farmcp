class Miner
  attr_reader :host, :port, :name, :tags

  def initialize(host, port, name, tags)
    @host = host
    @port = port
    @name = name
    @tags = tags
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
    Timeout::timeout(2) do
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
            h[k] = k == :temp && !dev[v].nil? ? dev[v].round : dev[v]
          end
        end
      end
      pool = rpc.cmd_pools["POOLS"].max_by do |pool|
        pool["Last Share Time"] || 0
      end

      avg = devs.count.zero?? 0 : devs.sum { |d| d[:mhs] } / devs.count
      devs.each do |dev|
        dev[:low_hash] = dev[:mhs] < (0.8 * avg)
      end

      {
        host: host,
        port: port,
        name: name,
        tags: tags,
        devs: devs,
        pool: pool["URL"]
      }
    end
  rescue Timeout::Error
    error(name || host, "timeout")
  rescue
    error(name || host, $!.message)
  end

  class << self
    def all
      if conf = JsonConfig.get
        names = Array(conf["names"])
        tags = Array(conf["tags"])
        conf["rigs"].each_with_index.map do |rig, num|
          addr = rig.strip.split(":")
          if addr[0].present?
            new(addr[0], (addr[1] || 4028).to_i, names[num], Array(tags[num]))
          end
        end
      else
        []
      end
    end
  end

  private

    def error(host, msg)
      {
        host: "#{host} - #{msg}",
        devs: [],
        pool: ""
      }
    end

end
