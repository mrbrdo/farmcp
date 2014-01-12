class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate

protected
  def json_config
    conf_file = File.expand_path("~/.farmcp")
    if File.exist?(conf_file)
      JSON.load(File.read(conf_file))
    end
  end

  def authenticate
    if conf = json_config
      if conf["password"]
        authenticate_or_request_with_http_basic do |username, password|
          username == conf["username"] && password == conf["password"]
        end
      end
    end
  end
end
