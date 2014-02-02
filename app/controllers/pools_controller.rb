class PoolsController < ApplicationController
  def index
    @pools = get_rig_pools
  end

  def switch
    if miner = Miner.all.find { |miner| miner.id == params[:rig_id] }
      miner.rpc.cmd_switchpool(params[:pool])
      redirect_to pools_url, flash: { notice: "Successfully switched pool on rig #{miner.to_s}." }
    else
      redirect_to pools_url, flash: { warning: "Cannot find rig." }
    end
  end

  def create
    Miner.all.each do |miner|
      next if miner.rpc.cmd_pools["POOLS"].find { |p| p["URL"] == params[:url] && p["User"] == params[:user] }
      miner.rpc.cmd_addpool(params[:url], params[:user], params[:pass])
    end

    redirect_to pools_url, flash: { notice: "Pool added." }
  end

private
  def get_rig_pools
    Hash.new.tap do |data|
      Miner.all.each do |miner|
        data[miner] = miner.get_pools
      end
    end
  end
end
