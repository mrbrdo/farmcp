class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate, except: ['rig', 'data']

protected

  def production?
    Rails.env == 'production'
  end

  def development?
    Rails.env == 'development'
  end

  def authenticate
    if conf = JsonConfig.get
      if conf["password"]
        authenticate_or_request_with_http_basic do |username, password|
          username == conf["username"] && password == conf["password"]
        end
      end
    end
  end
end
