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
end
