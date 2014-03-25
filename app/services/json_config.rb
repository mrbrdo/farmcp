module JsonConfig
  extend self

  def get
    @config ||= begin
      conf_file = File.expand_path("~/.farmcp")
      if File.exist?(conf_file)
        JSON.load(File.read(conf_file))
      else
        Hash.new
      end
    end
  end
end
