class Miner
  attr_reader :host, :port, :name, :tags, :link

  def initialize(host, port, name, tags, link)
    @host = host
    @port = port
    @name = name
    @tags = tags
    @link = link
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

  def beta_id(pools = rpc.cmd_pools["POOLS"])
    pools.each do |pool|
      if pool["URL"].include?("betarigs.com") && pool["User"].include?('-')
        return pool["User"].split('-')[1]
      end
    end
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

      pools = rpc.cmd_pools["POOLS"]
      pool = pools.max_by do |pool|
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
        link: link,
        tags: tags,
        devs: devs,
        pool: pool["URL"],
        beta_id: beta_id(pools)
      }
    end
  rescue Timeout::Error
    error(name || host, "timeout", tags, link)
  rescue
    error(name || host, $!.message, tags, link)
  end

  class << self
    def all
      if conf = JsonConfig.get
        names = Array(conf["names"])
        tags = Array(conf["tags"])
        links = Array(conf["links"])
        Array(conf["rigs"]).each_with_index.map do |rig, num|
          addr = rig.strip.split(":")
          if addr[0].present?
            new(addr[0], (addr[1] || 4028).to_i, names[num], Array(tags[num]), links[num])
          end
        end
      else
        []
      end
    end
  end

  private

    def error(host, msg, tags, link)
      {
        host: "#{host} - #{msg}",
        devs: [],
        pool: "",
        link: link,
        tags: tags
      }
    end

end
