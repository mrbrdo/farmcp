require 'socket'
require 'json'
require 'pry'

class CgminerRpc
  def initialize(host, port = 4028)
    @host = host
    @port = port
  end

  def exec(command, *args)
    data = { command: command }
    data[:parameter] = args.map(&:to_s).join(",") if args.length > 0

    sock = TCPSocket.new @host, @port
    sock.write(JSON.dump(data))
    response = ""
    while response.chars.last != "\u0000"
      response += sock.read
    end
    sock.close
    JSON.load(response[0, response.length - 1])
  end

  def pools
    response = exec("pools")
    Hash.new.tap do |pools|
      response["POOLS"].each do |data|
        pools[data["POOL"]] = data
      end
    end
  end

  def add_or_get_pool(url, usr, pass, options = {})
    pool_idx = pools.find do |idx, data|
      data["URL"].upcase == url.upcase &&
        data["User"] == usr
    end
    return pool_idx[0] if pool_idx

    unless options[:auto_add] == false
      cmd_addpool(url, usr, pass)
      add_or_get_pool(url, usr, pass, options.merge(auto_add: false))
    end
  end

  def switch_to_pool(url, usr, pass)
    if idx = add_or_get_pool(url, usr, pass)
      cmd_switchpool(idx)
      true
    else
      false
    end
  end

  def method_missing(name, *args, &block)
    if cmd = name[/\Acmd_(.+)\z/, 1]
      exec(cmd, *args, &block)
    else
      super
    end
  end
end
