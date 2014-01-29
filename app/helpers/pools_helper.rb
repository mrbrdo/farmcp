module PoolsHelper
  def pool_select_options(pool_data)
    current_pool = pool_data.max_by do |pool|
      pool["Last Share Time"] || 0
    end
    data = pool_data.map { |d| pool_to_option(d) }
    options_from_collection_for_select(data, "value", "title", current_pool["POOL"])
  end

  def pool_to_option(pool)
    OpenStruct.new(
      title: "#{pool["Priority"]}: #{pool["URL"]} (#{pool["User"]})",
      value: pool["POOL"]
      )
  end
end
